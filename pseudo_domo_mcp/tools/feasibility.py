"""lakeflow_feasibility — score each source for Lakeflow Connect ingestion."""

from __future__ import annotations

from typing import Any, Dict

from ..core.domo_client import get_provider
from ..core import feasibility as feas

__all__ = ["lakeflow_feasibility"]


def lakeflow_feasibility(source_system: str = "") -> Dict[str, Any]:
    """Score Domo source systems for Lakeflow Connect ingestion feasibility.

    For each upstream source feeding the Domo estate, returns GREEN/AMBER/RED
    plus the recommended Databricks ingestion pattern (managed connector vs
    Auto Loader vs Lakebase re-platform) and a rationale — the input to
    sequencing the 28-source migration.

    Args:
        source_system: optional — score just one source (e.g. "SQL Server");
            omit to score every source discovered in the tenant, ranked
            GREEN-first.

    Returns a ranked feasibility list. The connector matrix is a maintained
    reference — verify against the current Lakeflow Connect connector list
    before customer distribution.
    """
    if source_system:
        rec = feas.score_source(source_system)
        return {"feasibility": [rec]}

    p = get_provider()
    ranked = feas.score_all(p.source_systems())
    counts = {"GREEN": 0, "AMBER": 0, "RED": 0}
    for r in ranked:
        counts[r["rating"]] = counts.get(r["rating"], 0) + 1
    return {
        "feasibility": ranked,
        "rollup": counts,
        "note": ("RED sources are typically writeback/app layers — those are a "
                 "Databricks Apps + Lakebase re-platform, not an ingestion "
                 "problem, and are the sticky shadow-IT wedge competitors miss."),
    }
