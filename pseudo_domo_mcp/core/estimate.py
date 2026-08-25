"""estimate — future-state estimation (Lakebridge Profiler-style TCO).

Rolls the Assess effort scores + rationalization decisions into a directional
picture of the target state: migration effort (FTE-weeks), the target
consumption t-shirt size, and where the estate lands by surface. All figures are
**directional** — size precisely with the Databricks sizing tools once scope is
fixed. Customer $ is never invented: pass `domo_annual_spend` to frame savings,
otherwise savings stay qualitative.
"""

from __future__ import annotations

from typing import Any, Dict, List, Optional

# Directional planning rate — tune per delivery norms. Effort is 1-5 per asset.
FTE_WEEKS_PER_EFFORT_POINT = 0.4


def estimate(active_assets: List[Dict[str, Any]],
             all_dispositions: Optional[List[Dict[str, Any]]] = None,
             domo_annual_spend: Optional[float] = None) -> Dict[str, Any]:
    """Estimate the target state.

    Effort is summed over `active_assets` (the transforms that carry effort
    scores). Decision counts (by disposition / target surface) come from
    `all_dispositions` — every saved rationalization across ALL asset types
    (cards, pages, connectors, …), so the estimate reflects what was actually
    decided, not just the dataflow subset.
    """
    total_points = 0
    by_effort_band = {"LOW": 0, "MEDIUM": 0, "HIGH": 0}
    for a in active_assets:
        eff = a.get("effort") or {}
        total_points += int(eff.get("effort_1_5") or 0)
        b = eff.get("band")
        if b in by_effort_band:
            by_effort_band[b] += 1

    surfaces: Dict[str, int] = {}
    by_disposition: Dict[str, int] = {}
    for d in (all_dispositions or []):
        disp = d.get("disposition")
        if disp:
            by_disposition[disp] = by_disposition.get(disp, 0) + 1
        surf = d.get("target_surface")
        if surf and surf != "none":
            surfaces[surf] = surfaces.get(surf, 0) + 1

    n = len(active_assets)
    high = by_effort_band["HIGH"]
    if n <= 10 and high <= 2:
        cons = ("SMALL", "Serverless SQL + a handful of pipelines; AI/BI + Genie for consumption")
    elif n <= 30:
        cons = ("MEDIUM", "Multiple Lakeflow pipeline jobs + AI/BI + Genie at team scale")
    else:
        cons = ("LARGE", "Enterprise pipeline fleet + broad AI/BI + Genie + Apps/Lakebase")

    out: Dict[str, Any] = {
        "active_assets": n,
        "migration_effort": {
            "total_effort_points": total_points,
            "est_fte_weeks": round(total_points * FTE_WEEKS_PER_EFFORT_POINT, 1),
            "by_effort_band": by_effort_band,
            "basis": f"{FTE_WEEKS_PER_EFFORT_POINT} FTE-week per effort point (directional)",
        },
        "target_surfaces": surfaces,
        "by_disposition": by_disposition,
        "target_consumption": {
            "band": cons[0], "rationale": cons[1],
            "note": ("Directional t-shirt size — size precisely with the Databricks "
                     "sizing tools (Quicksizer / Lakemeter) once scope is fixed."),
        },
        "note": "Future-state estimate is directional until discovery runs on the live tenant.",
    }
    if domo_annual_spend:
        out["savings"] = {
            "domo_annual_spend": domo_annual_spend,
            "framing": ("Consolidation floor: retiring Domo (plus any Alteryx / legacy "
                        "DWH) removes per-seat licensing; the platform is DBU-based. "
                        "Net savings depend on final scope and commit."),
        }
    return out
