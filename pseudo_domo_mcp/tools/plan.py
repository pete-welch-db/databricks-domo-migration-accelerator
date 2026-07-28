"""migration_plan — the customer-facing assessment deliverable, as JSON.

Aggregates discover + assess + feasibility into one prioritized, value-driven
migration wave plan: what to move first (highest value, manageable complexity),
the governed vs. shadow-IT (40/60) breakdown, and the per-source ingestion
strategy.
"""

from __future__ import annotations

from typing import Any, Dict, List

from ..core.domo_client import get_provider
from ..core import classifier
from ..core import feasibility as feas
from .assessment import domo_assess
from .discovery import domo_discover

__all__ = ["migration_plan"]

# band -> sort rank (value desc, complexity asc)
_VALUE_RANK = {"HIGH": 0, "MEDIUM": 1, "LOW": 2}
_CX_RANK = {"LOW": 0, "MEDIUM": 1, "HIGH": 2}


def migration_plan() -> Dict[str, Any]:
    """Produce the prioritized Domo->Databricks migration plan.

    Combines the tenant census, per-dataflow assessment, and per-source
    Lakeflow Connect feasibility into a wave-sequenced plan ranked by business
    value then migration complexity. This is the structured "assessment
    deliverable" a customer engagement produces.

    Returns waves, the governance split, source feasibility rollup, and the
    recommended pilot. All figures are draft-grade until live tenant data.
    """
    census = domo_discover("summary")
    assessments = domo_assess("dataflows")["assessments"]
    p = get_provider()
    source_feas = feas.score_all(p.source_systems())

    # Rank: value band desc, then complexity band asc, then $/yr value.
    ranked = sorted(
        assessments,
        key=lambda a: (_VALUE_RANK.get(a["value"]["band"], 3),
                       _CX_RANK.get(a["complexity"]["band"], 3),
                       -_value_num(a["value"]["value_per_year"])),
    )

    waves = _bucket_waves(ranked)
    pilot = ranked[0] if ranked else None

    return {
        "summary": {
            "census": census["counts"],
            "dataflow_types": census["dataflow_types"],
            "governance_split": census["governance_split"],
        },
        "recommended_pilot": _pilot_view(pilot),
        "waves": waves,
        "source_feasibility": source_feas,
        "value_thesis": (
            "Sequence by business value, not object count. Like-for-like card "
            "porting is a low-value cost story; lead with the highest-value "
            "domains and elevate static cards to Genie / AI-BI. Governed IT "
            "pipelines migrate cleanly to Lakeflow Declarative Pipelines; the "
            "shadow-IT writeback apps/forms re-platform to Databricks Apps + "
            "Lakebase."
        ),
        "note": "Draft-grade; grounded in synthetic fixtures + illustrative "
                "value defaults. Tighten with live tenant discovery + your own "
                "value model.",
    }


def _bucket_waves(ranked: List[Dict[str, Any]]) -> List[Dict[str, Any]]:
    """3 waves: (1) high-value quick wins, (2) governed remainder, (3) shadow IT."""
    w1, w2, w3 = [], [], []
    for a in ranked:
        entry = {
            "name": a["name"], "data_domain": a["data_domain"],
            "value": a["value"], "complexity_band": a["complexity"]["band"],
            "governance": a["governance"], "has_triplet": a["has_triplet"],
        }
        if a["governance"] == "shadow":
            w3.append(entry)
        elif a["value"]["band"] == "HIGH" and a["complexity"]["band"] != "HIGH":
            w1.append(entry)
        else:
            w2.append(entry)
    return [
        {"wave": 1, "theme": "High-value quick wins (governed, high value, manageable complexity)", "items": w1},
        {"wave": 2, "theme": "Governed remainder (SQL DataFlows, higher complexity)", "items": w2},
        {"wave": 3, "theme": "Shadow IT — Databricks Apps + Lakebase re-platform", "items": w3},
    ]


def _pilot_view(a):
    if not a:
        return None
    return {
        "name": a["name"], "data_domain": a["data_domain"],
        "value": a["value"], "complexity": a["complexity"],
        "has_triplet": a["has_triplet"],
        "triplet_lineage_id": a["triplet_lineage_id"],
        "why": ("Highest business value at manageable complexity, with a full "
                "triplet available — prove the mechanism end-to-end here first."),
    }


def _value_num(value: str) -> float:
    """'$200K' -> 200000.0 (best-effort, for tie-break ordering)."""
    s = value.replace("$", "").replace(",", "").strip().upper()
    mult = 1.0
    if s.endswith("K"):
        mult, s = 1_000.0, s[:-1]
    elif s.endswith("M"):
        mult, s = 1_000_000.0, s[:-1]
    try:
        return float(s) * mult
    except ValueError:
        return 0.0
