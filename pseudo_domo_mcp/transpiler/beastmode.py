"""BeastModeAgent — Stage 4 of the transpiler (HIGHEST-RISK LAYER).

AGENT ROLE
==========
Beast Modes are Domo's CARD-LEVEL calculated fields, written in Domo's calc
language (a SQL analog, NOT DAX). The critical gotcha: **Beast Modes live on the
Card, not in Magic ETL.** So you can reconcile the base gold dataset perfectly
and STILL render wrong numbers on the dashboard, because the card is applying
aggregations/logic that never appear in the DataFlow export.

This agent translates each Card Beast Mode expression into a Spark SQL
metric/column expression, so the card's numbers reproduce on top of the gold
view. It emits `gold_semantic_metrics.sql`: a metrics view that materializes
every Beast Mode as a named aggregate over the gold table, honoring the card's
own filters (e.g. region IN ('North America')).

Functions handled (exactly what the fixture uses):
    SUM, COUNT, COUNT(DISTINCT ...), AVG, NULLIF, CASE WHEN, IN, arithmetic.

Because this is the highest-risk translation, every expression is emitted with
the ORIGINAL Domo expression inline as a comment for human verification, and any
expression this agent cannot fully translate is flagged (not silently dropped).
"""

from __future__ import annotations

import os
import re
from dataclasses import dataclass, field
from typing import Dict, List, Tuple

from ingest import Lineage


@dataclass
class TranslatedMetric:
    name: str                 # Beast Mode display name
    alias: str                # SQL-safe column alias
    domo_expr: str            # original Domo expression (for the comment)
    spark_expr: str           # translated Spark SQL aggregate expression
    fully_translated: bool = True
    notes: List[str] = field(default_factory=list)


@dataclass
class BeastModeResult:
    metrics: List[TranslatedMetric]
    sql: str
    metrics_view_fqn: str
    where_clause: str
    file_path: str = ""

    @property
    def coverage(self) -> Tuple[int, int]:
        done = sum(1 for m in self.metrics if m.fully_translated)
        return done, len(self.metrics)


class BeastModeAgent:
    # Known Domo calc functions that map 1:1 onto Spark SQL. Presence of only
    # these (plus CASE/IN/arithmetic/NULLIF) means a clean, verified translation.
    _KNOWN_FUNCS = {"SUM", "COUNT", "AVG", "MIN", "MAX", "NULLIF", "COALESCE",
                    "DISTINCT", "CASE", "WHEN", "THEN", "ELSE", "END", "IN",
                    "AND", "OR", "NOT", "NULL"}

    def __init__(self, out_dir: str):
        self.out_dir = out_dir

    # -- public API -------------------------------------------------------- #
    def translate(self, lineage: Lineage, gold_view_fqn: str) -> BeastModeResult:
        metrics = [self._translate_one(bm.name, bm.expression)
                   for bm in lineage.card.beast_modes]
        where = self._card_filter_where(lineage)
        view_fqn = gold_view_fqn.replace(".gold.", ".gold.") + "_semantic_metrics"
        sql = self._emit_sql(metrics, view_fqn, gold_view_fqn, where, lineage)
        path = self._write(sql)
        return BeastModeResult(
            metrics=metrics, sql=sql, metrics_view_fqn=view_fqn,
            where_clause=where, file_path=path,
        )

    # -- translation core -------------------------------------------------- #
    def _translate_one(self, name: str, expr: str) -> TranslatedMetric:
        spark = expr.strip()
        notes: List[str] = []

        # 1) COUNT(DISTINCT ...) — identical in Spark, normalize spacing.
        spark = re.sub(r"COUNT\s*\(\s*DISTINCT\s+", "COUNT(DISTINCT ",
                       spark, flags=re.IGNORECASE)

        # 2) NULLIF, CASE WHEN, IN (...), SUM/AVG/COUNT, arithmetic operators,
        #    and backtick identifiers are all valid Spark SQL as-is. Domo's
        #    calc language is a SQL analog, so the body passes through.
        #    We only need to confirm we recognize every function token.
        unknown = self._unknown_functions(spark)
        fully = not unknown
        if unknown:
            notes.append(
                f"Contains function(s) not in the verified map: "
                f"{sorted(unknown)} — REQUIRES HUMAN REVIEW before trusting."
            )

        return TranslatedMetric(
            name=name,
            alias=self._alias(name),
            domo_expr=expr.strip(),
            spark_expr=spark,
            fully_translated=fully,
            notes=notes,
        )

    def _unknown_functions(self, expr: str) -> set:
        """Any IDENT immediately followed by '(' that we don't recognize."""
        calls = re.findall(r"([A-Za-z_][A-Za-z0-9_]*)\s*\(", expr)
        found = {c.upper() for c in calls}
        return found - self._KNOWN_FUNCS

    # -- card filters -> WHERE --------------------------------------------- #
    def _card_filter_where(self, lineage: Lineage) -> str:
        preds = []
        for f in lineage.card.filters:
            col = f"`{f['column']}`"
            op = f["operator"].upper()
            if op == "IN":
                vals = ", ".join(self._lit(v) for v in f.get("values", []))
                preds.append(f"{col} IN ({vals})")
            elif op == "EQUALS":
                preds.append(f"{col} = {self._lit(f.get('value'))}")
            else:
                preds.append(f"/* TODO card filter op {op} */ TRUE")
        return " AND ".join(preds) if preds else ""

    # -- SQL emission ------------------------------------------------------ #
    def _emit_sql(self, metrics, view_fqn, gold_fqn, where, lineage) -> str:
        lines = [
            "-- ============================================================",
            "-- GOLD SEMANTIC METRICS — Card Beast Modes folded into Spark SQL",
            "-- ============================================================",
            "-- WHY THIS FILE EXISTS (the #1 migration gotcha):",
            "--   Beast Modes are CARD-LEVEL calc fields; they are NOT in the",
            "--   Magic ETL export. Reconciling the base gold dataset can pass",
            "--   while the CARD still renders wrong numbers. This view folds",
            f"--   every Beast Mode from card '{lineage.card.title}' into Spark",
            "--   SQL so the dashboard's numbers reproduce post-migration.",
            "--",
            "--   Each metric shows its ORIGINAL Domo expression for review.",
            f"--   Card filters applied: {where or '(none)'}",
            "-- ============================================================",
            "",
            f"CREATE OR REPLACE VIEW {view_fqn} AS",
            "SELECT",
        ]
        metric_lines = []
        for m in metrics:
            flag = "" if m.fully_translated else "   -- !! REVIEW REQUIRED"
            metric_lines.append(
                f"  -- Beast Mode: {m.name}{flag}\n"
                f"  -- Domo:  {m.domo_expr}\n"
                f"  {m.spark_expr} AS {m.alias}"
            )
        lines.append(",\n".join(metric_lines))
        lines.append(f"FROM {gold_fqn}")
        if where:
            lines.append(f"WHERE {where}")
        return "\n".join(lines) + ";\n"

    # -- util -------------------------------------------------------------- #
    def _write(self, sql: str) -> str:
        os.makedirs(self.out_dir, exist_ok=True)
        p = os.path.join(self.out_dir, "gold_semantic_metrics.sql")
        with open(p, "w", encoding="utf-8") as fh:
            fh.write(sql)
        return p

    @staticmethod
    def _alias(name: str) -> str:
        return re.sub(r"[^a-z0-9]+", "_", name.lower()).strip("_")

    @staticmethod
    def _lit(v):
        if isinstance(v, str):
            return "'" + v.replace("'", "''") + "'"
        return str(v)
