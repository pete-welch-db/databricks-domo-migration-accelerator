"""Estimation tool — future-state target estimate from assess + dispositions."""

from __future__ import annotations

from typing import Any, Dict

from ..core import estimate as estmod
from ..core import store
from .assessment import domo_assess

__all__ = ["estimate_migration"]


def estimate_migration(domo_annual_spend: float = 0.0) -> Dict[str, Any]:
    """Directional future-state estimate: migration effort (FTE-weeks), target
    consumption size, and surface split — from the Assess scores and any saved
    rationalization decisions (retired assets excluded).

    Args:
        domo_annual_spend: optional current Domo $/yr, to frame the savings floor.
    """
    assessed = domo_assess("dataflows")["assessments"]
    disp = {r["asset_id"]: r for r in store.get_store().list("rationalizations")}
    for a in assessed:
        d = disp.get(a["dataflow_id"])
        if d:
            a["disposition"] = d
    active = [a for a in assessed
              if (disp.get(a["dataflow_id"]) or {}).get("disposition") != "Retire"]
    # Decision counts span ALL asset types (cards/pages/connectors), not just
    # dataflows — effort is summed over the active transforms only.
    all_dispositions = list(disp.values())
    return estmod.estimate(active, all_dispositions, domo_annual_spend or None)
