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
from ..core import store
from ..core import rationalize as ratmod
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

    # Human dispositions (if any) take precedence over the auto heuristic:
    # annotate each dataflow, and drop anything explicitly marked Retire.
    disp = {r["asset_id"]: r for r in store.get_store().list("rationalizations")}
    for a in assessments:
        d = disp.get(a["dataflow_id"])
        if d:
            a["disposition"] = d
    active = [a for a in assessments
              if (disp.get(a["dataflow_id"]) or {}).get("disposition") != "Retire"]
    retired = [a["name"] for a in assessments
               if (disp.get(a["dataflow_id"]) or {}).get("disposition") == "Retire"]

    # Rank: value band desc, then complexity band asc, then $/yr value.
    ranked = sorted(
        active,
        key=lambda a: (_VALUE_RANK.get(a["value"]["band"], 3),
                       _CX_RANK.get(a["complexity"]["band"], 3),
                       -_value_num(a["value"]["value_per_year"])),
    )

    waves = _bucket_waves(ranked, disp)
    pilot = ranked[0] if ranked else None

    return {
        "summary": {
            "census": census["counts"],
            "dataflow_types": census["dataflow_types"],
            "governance_split": census["governance_split"],
            "rationalization": ratmod.rollup(list(disp.values())),
            "retired_excluded": retired,
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


def _bucket_waves(ranked: List[Dict[str, Any]],
                  disp: Dict[str, Any] | None = None) -> List[Dict[str, Any]]:
    """Bucket active assets into waves.

    If humans have assigned any waves (via rationalization), group by the
    explicit `assigned_wave` — decisions drive the plan. Otherwise fall back to
    the auto heuristic: shadow IT is its own wave (an Apps + Lakebase
    re-platform, not a pipeline transpile), and governed assets split by rank
    into Wave 1 (start here) / Wave 2.
    """
    disp = disp or {}

    def entry(a):
        d = disp.get(a.get("dataflow_id")) or a.get("disposition") or {}
        return {
            "name": a["name"], "data_domain": a["data_domain"],
            "value": a["value"], "complexity_band": a["complexity"]["band"],
            "governance": a["governance"], "has_triplet": a["has_triplet"],
            "disposition": d.get("disposition"),
            "target_surface": d.get("target_surface"),
        }

    def auto_waves(assets, start_wave=1):
        """Value/complexity auto-buckets: governed split in half + shadow last."""
        governed = [a for a in assets if a["governance"] != "shadow"]
        shadow = [a for a in assets if a["governance"] == "shadow"]
        cut = (len(governed) + 1) // 2
        waves, w = [], start_wave
        if governed[:cut]:
            waves.append({"wave": w, "theme": "Start here — highest-priority governed pipelines (best value-to-effort)",
                          "items": [entry(a) for a in governed[:cut]]}); w += 1
        if governed[cut:]:
            waves.append({"wave": w, "theme": "Governed remainder — larger or more complex pipelines",
                          "items": [entry(a) for a in governed[cut:]]}); w += 1
        if shadow:
            waves.append({"wave": w, "theme": "Shadow IT — Databricks Apps + Lakebase re-platform",
                          "items": [entry(a) for a in shadow]})
        return waves

    # Assets a human explicitly placed go into their assigned wave; the rest keep
    # the value/complexity auto-buckets (numbered after the assigned ones) — so
    # assigning one asset never collapses the whole plan.
    assigned = {a["dataflow_id"]: (disp.get(a["dataflow_id"]) or {}).get("assigned_wave")
                for a in ranked}
    if any(assigned.values()):
        by_wave: Dict[int, List[Dict[str, Any]]] = {}
        unassigned = []
        for a in ranked:
            w = assigned.get(a["dataflow_id"])
            if w:
                by_wave.setdefault(int(w), []).append(entry(a))
            else:
                unassigned.append(a)
        # Human-assigned waves first (in their chosen order), then the
        # auto-bucketed remainder; renumber contiguously so there are no gaps.
        out = [{"wave": None, "theme": "Assigned in rationalization", "items": by_wave[w]}
               for w in sorted(by_wave)]
        out += auto_waves(unassigned, start_wave=1)
        for i, wv in enumerate(out, 1):
            wv["wave"] = i
        return out

    return auto_waves(ranked, start_wave=1)


def _pilot_view(a):
    if not a:
        return None
    return {
        "name": a["name"], "data_domain": a["data_domain"],
        "value": a["value"], "complexity": a["complexity"],
        "has_triplet": a["has_triplet"],
        "triplet_lineage_id": a["triplet_lineage_id"],
        "why": ("Top of the priority ranking (business value vs. migration "
                "effort) with a full lineage available — prove the mechanism "
                "end-to-end here first."),
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
