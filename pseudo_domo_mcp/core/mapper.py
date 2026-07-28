"""mapper — draft-map Domo dataset columns onto an industry-model table.

This is the "conform to the canonical silver layer" step the industry-models
blog leaves as an exercise. Given a Domo DataSet schema (name + Domo type per
column) and a target IndustryModel, we:

  1. pick the best-fit target TABLE (by column-name overlap across all tables
     in the relevant domain, then across the whole model), and
  2. map each Domo column to the best target column via a transparent score:
        name similarity (token overlap)   0.60
        type compatibility                 0.25
        comment/token hint overlap         0.15
     Unmapped columns are flagged (never silently dropped).

All scores are explainable and human-reviewable — DRAFT-grade suggestions.
"""

from __future__ import annotations

import re
from typing import Any, Dict, List, Optional, Tuple

from .industry_model import IndustryModel, ModelTable, ModelColumn

# Domo type -> compatible Spark type family (for the type-compat sub-score).
_DOMO_FAMILY = {
    "STRING": "string", "LONG": "int", "DECIMAL": "num", "DOUBLE": "num",
    "DATE": "date", "DATETIME": "date",
}
_SPARK_FAMILY = {
    "STRING": "string", "BIGINT": "int", "INT": "int", "INTEGER": "int",
    "DECIMAL": "num", "DOUBLE": "num", "FLOAT": "num",
    "DATE": "date", "TIMESTAMP": "date", "BOOLEAN": "bool",
}


def _tokens(name: str) -> set:
    return set(t for t in re.split(r"[^a-z0-9]+", name.lower()) if t)


def _name_sim(a: str, b: str) -> float:
    ta, tb = _tokens(a), _tokens(b)
    if not ta or not tb:
        return 0.0
    inter = len(ta & tb)
    return inter / max(len(ta | tb), 1)


def _type_compat(domo_type: str, spark_type: str) -> float:
    fam = spark_type.split("(")[0].upper()
    return 1.0 if _DOMO_FAMILY.get(domo_type.upper()) == _SPARK_FAMILY.get(fam) else 0.0


def _comment_hint(domo_col: str, target: ModelColumn) -> float:
    # Does the Domo column name appear (token-wise) in the target's comment?
    ct = _tokens(target.comment)
    dt = _tokens(domo_col)
    if not dt:
        return 0.0
    return len(dt & ct) / len(dt)


def _col_score(domo_col: str, domo_type: str, target: ModelColumn) -> float:
    return round(
        0.60 * _name_sim(domo_col, target.name)
        + 0.25 * _type_compat(domo_type, target.spark_type)
        + 0.15 * _comment_hint(domo_col, target),
        3,
    )


def pick_table(model: IndustryModel, domo_columns: List[str],
               prefer_domain: Optional[str] = None) -> Tuple[Optional[ModelTable], float]:
    """Choose the target table whose columns best cover the Domo columns."""
    candidates = model.tables
    if prefer_domain:
        in_domain = [t for t in model.tables if t.domain == prefer_domain]
        if in_domain:
            candidates = in_domain

    best: Optional[ModelTable] = None
    best_score = -1.0
    for t in candidates:
        # coverage = mean best-name-sim of each domo col against this table
        if not t.columns:
            continue
        total = 0.0
        for dc in domo_columns:
            total += max(_name_sim(dc, tc.name) for tc in t.columns)
        cov = total / max(len(domo_columns), 1)
        if cov > best_score:
            best_score, best = cov, t
    return best, round(best_score, 3)


def map_columns(model: IndustryModel, domo_schema: List[Dict[str, str]],
                prefer_domain: Optional[str] = None,
                threshold: float = 0.34,
                force_table_fqn: Optional[str] = None,
                overrides: Optional[Dict[str, str]] = None,
                candidate_limit: int = 8) -> Dict[str, Any]:
    """Map a Domo DataSet schema onto an industry-model table.

    domo_schema     : list of {"name","type"} (Domo column contract).
    force_table_fqn : pin the target table (else auto-pick best fit).
    overrides       : {domo_column: target_column_name | ""} human choices that
                      win over the suggestion ("" = deliberately unmapped).

    Returns a unified per-column view with the suggested target, confidence,
    review flag, and a ranked candidate list (for a UI dropdown), plus the
    model's table catalog + the chosen table's columns so the UI can offer
    table/column re-selection. Back-compat keys (target_table, mappings,
    mapped_count) are preserved.
    """
    overrides = overrides or {}
    domo_cols = [c["name"] for c in domo_schema]
    if force_table_fqn:
        table = model.table_by_fqn(force_table_fqn)
        table_cov = 0.0
    else:
        table, table_cov = pick_table(model, domo_cols, prefer_domain)
    if table is None:
        return {"target_table": None, "columns": [], "mappings": [],
                "unmapped": domo_cols, "table_coverage": 0.0,
                "model_tables": _model_tables(model), "table_columns": []}

    columns: List[Dict[str, Any]] = []
    mappings: List[Dict[str, Any]] = []
    unmapped: List[str] = []
    for col in domo_schema:
        scored = [
            (tc, _col_score(col["name"], col.get("type", "STRING"), tc))
            for tc in table.columns
        ]
        scored.sort(key=lambda x: x[1], reverse=True)
        best_tc, best = scored[0]
        candidates = [{"name": tc.name, "spark_type": tc.spark_type,
                       "confidence": s, "comment": tc.comment[:120]}
                      for tc, s in scored[:candidate_limit]]

        ov = overrides.get(col["name"])
        if ov is not None:                      # explicit human choice
            chosen = ov or None
            conf = 1.0 if ov else 0.0
            source = "override"
        elif best >= threshold:
            chosen, conf, source = best_tc.name, best, "suggested"
        else:
            chosen, conf, source = None, best, "low"

        tcol = next((c for c in table.columns if c.name == chosen), None)
        entry = {
            "domo_column": col["name"],
            "domo_type": col.get("type", "STRING"),
            "target_column": chosen,
            "target": f"{table.fqn}.{chosen}" if chosen else None,
            "target_type": tcol.spark_type if tcol else None,
            "confidence": round(conf, 3),
            "needs_review": (source != "override") and (chosen is None or conf < 0.55),
            "source": source,
            "candidates": candidates,
        }
        columns.append(entry)
        if chosen:
            mappings.append(entry)
        else:
            unmapped.append(col["name"])

    return {
        "industry": model.industry,
        "target_table": table.fqn,
        "target_domain": table.domain,
        "target_table_comment": _table_comment(table),
        "table_coverage": table_cov,
        "mapped_count": len(mappings),
        "unmapped_count": len(unmapped),
        "columns": columns,
        "mappings": mappings,
        "unmapped": unmapped,
        "model_tables": _model_tables(model),
        "table_columns": [{"name": c.name, "spark_type": c.spark_type}
                          for c in table.columns],
    }


def _model_tables(model: IndustryModel) -> List[Dict[str, str]]:
    return [{"fqn": t.fqn, "domain": t.domain, "table": t.table,
             "columns": len(t.columns)} for t in model.tables]


def _table_comment(table: ModelTable) -> str:
    # No table-level comment captured in ModelTable; summarize from columns.
    return f"{len(table.columns)} columns in domain '{table.domain}'"
