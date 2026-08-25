"""Rationalization tools — per-asset disposition + target surface, persisted.

Thin MCP wrappers over `core.rationalize` + the state store. Suggestions come
from the Assess signals; humans confirm/override; decisions persist to the
`rationalizations` collection and flow into the wave plan and estimate.
"""

from __future__ import annotations

import datetime
from typing import Any, Dict, List

from ..core import rationalize as rat
from ..core import filters as filtermod
from ..core import store
from . import discovery

__all__ = ["suggest_dispositions", "rationalize_asset", "rationalize_bulk",
           "list_rationalizations"]


def _assets_by_id() -> Dict[str, Dict[str, Any]]:
    return {a["id"]: a for a in discovery.domo_inventory()["assets"]}


def suggest_dispositions(criteria: Dict[str, Any] | None = None) -> Dict[str, Any]:
    """Suggested disposition + target surface for each asset (optionally filtered).

    Merges any already-saved decisions so the caller sees current state, and
    fills the rest with `core.rationalize.suggest_disposition` recommendations.
    """
    assets = discovery.domo_inventory()["assets"]
    if criteria:
        assets = filtermod.apply_filter(criteria, assets)
    saved = {r["asset_id"]: r for r in store.get_store().list("rationalizations")}
    rows = []
    for a in assets:
        cur = saved.get(a["id"])
        suggestion = rat.suggest_disposition(a)
        rows.append({
            "asset_id": a["id"], "asset_type": a["asset_type"], "name": a.get("name"),
            "governance": a.get("governance"),
            "value_band": (a.get("value") or {}).get("band"),
            "complexity_band": (a.get("complexity") or {}).get("band"),
            "effort_1_5": (a.get("effort") or {}).get("effort_1_5"),
            "usage_score": (a.get("usage") or {}).get("usage_score"),
            "suggested": suggestion,
            "decided": cur,  # None until a human saves one
            "available_target_surfaces": rat.surfaces_for(a["asset_type"]),
        })
    return {"rows": rows, "dispositions": rat.DISPOSITIONS,
            "target_surfaces": rat.TARGET_SURFACES, "count": len(rows)}


def rationalize_asset(asset_id: str, disposition: str, target_surface: str = "",
                      rationale: str = "", assigned_wave: int = 0,
                      decided_by: str = "") -> Dict[str, Any]:
    """Persist one asset's disposition decision. Returns the saved record."""
    if disposition not in rat.DISPOSITIONS:
        return {"error": f"disposition must be one of {rat.DISPOSITIONS}"}
    asset = _assets_by_id().get(asset_id, {})
    rec = {
        "asset_id": asset_id,
        "asset_type": asset.get("asset_type"),
        "name": asset.get("name"),
        "disposition": disposition,
        "target_surface": target_surface or "none",
        "effort_1_5": (asset.get("effort") or {}).get("effort_1_5"),
        "value_band": (asset.get("value") or {}).get("band"),
        "rationale": rationale,
        "assigned_wave": assigned_wave or None,
        "decided_by": decided_by,
        "decided_at": datetime.datetime.now(datetime.timezone.utc).isoformat(),
    }
    store.get_store().put("rationalizations", asset_id, rec)
    return {"saved": True, "record": rec}


def rationalize_bulk(criteria: Dict[str, Any], disposition: str,
                     target_surface: str = "", assigned_wave: int = 0,
                     rationale: str = "", decided_by: str = "") -> Dict[str, Any]:
    """Apply one disposition to every asset matching `criteria` (wave-at-once)."""
    if disposition not in rat.DISPOSITIONS:
        return {"error": f"disposition must be one of {rat.DISPOSITIONS}"}
    assets = filtermod.apply_filter(criteria or {}, discovery.domo_inventory()["assets"])
    saved = [rationalize_asset(a["id"], disposition, target_surface, rationale,
                               assigned_wave, decided_by)["record"] for a in assets]
    return {"saved": len(saved), "asset_ids": [r["asset_id"] for r in saved]}


def list_rationalizations() -> Dict[str, Any]:
    """List all saved dispositions plus a rollup by disposition/surface/wave."""
    recs: List[Dict[str, Any]] = store.get_store().list("rationalizations")
    return {"rationalizations": recs, "rollup": rat.rollup(recs)}
