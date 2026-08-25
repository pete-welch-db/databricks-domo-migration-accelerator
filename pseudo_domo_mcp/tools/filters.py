"""Filter tools — filtered discovery + saved filter sets (= migration waves).

Thin MCP wrappers over `core.filters` + the state store. A saved filter set is a
named slice of the estate; applying it returns the matching assets, which is how
a wave is scoped before rationalization.
"""

from __future__ import annotations

import datetime
import uuid
from typing import Any, Dict, List

from ..core import filters as filtermod
from ..core import store
from . import discovery

__all__ = ["filter_inventory", "save_filter_set", "list_filter_sets", "apply_saved_filter"]


def filter_inventory(criteria: Dict[str, Any] | None = None) -> Dict[str, Any]:
    """Return the asset inventory narrowed by `criteria` (see core.filters).

    criteria keys (all optional, str or list): asset_type, governance,
    data_domain, source_system, owner, value_band, complexity_band, effort_band,
    usage_band, disposition; plus min_usage/max_usage, effort_min/effort_max,
    has_triplet, search. Also returns `facets` (distinct values in the estate).
    """
    inv = discovery.domo_inventory()
    matched = filtermod.apply_filter(criteria or {}, inv["assets"])
    return {"assets": matched, "matched": len(matched),
            "total": len(inv["assets"]), "facets": filtermod.facets(inv["assets"]),
            "criteria": criteria or {}}


def save_filter_set(name: str, criteria: Dict[str, Any],
                    description: str = "") -> Dict[str, Any]:
    """Persist a named filter set (a migration-wave candidate) and return it."""
    rec = {
        "filter_set_id": f"fs_{uuid.uuid4().hex[:8]}",
        "name": name,
        "description": description,
        "criteria": criteria or {},
        "created_at": datetime.datetime.now(datetime.timezone.utc).isoformat(),
    }
    store.get_store().put("filter_sets", rec["filter_set_id"], rec)
    return rec


def list_filter_sets() -> Dict[str, Any]:
    """List all saved filter sets, each with its current matched count."""
    inv = discovery.domo_inventory()
    sets: List[Dict[str, Any]] = store.get_store().list("filter_sets")
    for fs in sets:
        fs["matched_count"] = len(filtermod.apply_filter(fs.get("criteria", {}), inv["assets"]))
    return {"filter_sets": sets}


def apply_saved_filter(filter_set_id: str) -> Dict[str, Any]:
    """Apply a saved filter set by id and return the matching assets."""
    sets = {fs["filter_set_id"]: fs for fs in store.get_store().list("filter_sets")}
    fs = sets.get(filter_set_id)
    if not fs:
        return {"error": f"filter set {filter_set_id} not found", "assets": []}
    inv = discovery.domo_inventory()
    matched = filtermod.apply_filter(fs.get("criteria", {}), inv["assets"])
    return {"filter_set": fs, "assets": matched, "matched": len(matched)}
