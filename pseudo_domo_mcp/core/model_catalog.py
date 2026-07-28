"""model_catalog — the full list of Databricks Industry Data Models.

The user picks which industry model(s) to draft-map onto. That choice should
offer EVERY model in the open-source repo
(databricks-industry-solutions/lakehouse-industry-data-models), not only the
ones vendored locally under models/.

This module returns a catalog entry per model:
    {"key", "label", "vendored"}
where `vendored` = the DDL is present under models/<key>/ (so mapping works
fully offline right now). Non-vendored models are still selectable; their DDL
is fetched on demand when first mapped (or the user can vendor them).

The list is refreshed from the repo's `data-models/` directory listing (GitHub
API) and cached; a built-in fallback (the models present at authoring time)
keeps it working fully offline.
"""

from __future__ import annotations

import json
import os
import urllib.request
from typing import Any, Dict, List

from . import industry_model

_REPO_ROOT = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
_CACHE = os.path.join(_REPO_ROOT, ".pseudo_domo_models.json")

_REPO = "databricks-industry-solutions/lakehouse-industry-data-models"
_CONTENTS_URL = f"https://api.github.com/repos/{_REPO}/contents/data-models"

# Built-in fallback: every model directory present in the repo at authoring
# time. Keeps the selector complete offline. Refresh updates it live.
_FALLBACK: List[str] = [
    "advertising", "agriculture", "airlines", "apparel_fashion", "automotive",
    "banking", "chemical_mfg", "clinical_trials", "construction",
    "consumer_goods", "ecommerce", "education", "energy_utilities",
    "food_beverage", "gaming", "genomics_biotech", "grocery", "health_insurance",
    "healthcare", "legal", "life_insurance", "manufacturing",
    "media_broadcasting", "mining", "ngo", "oil_gas", "payments_fintech",
    "pharmaceuticals", "real_estate", "restaurants", "retail", "semiconductors",
    "shipping_ports", "sports_entertainment", "staffing_hr", "telecommunication",
    "transport_shipping", "travel_hospitality", "waste_management",
    "water_utilities",
]

# Directory entries in data-models/ that are not models.
_NON_MODELS = {"images", "models-info.csv", ".gitignore"}


def _label(key: str) -> str:
    return key.replace("_", " ").title()


def _model_keys() -> List[str]:
    """Cached repo list if present, else the built-in fallback."""
    if os.path.exists(_CACHE):
        try:
            with open(_CACHE, "r", encoding="utf-8") as fh:
                keys = json.load(fh).get("models", [])
            if keys:
                return keys
        except (json.JSONDecodeError, OSError):
            pass
    return _FALLBACK


def catalog() -> List[Dict[str, Any]]:
    """Every selectable model, flagged with whether it's vendored locally."""
    vendored = set(industry_model.available_industries())
    return [{"key": k, "label": _label(k), "vendored": k in vendored}
            for k in _model_keys()]


def refresh(timeout: int = 10) -> Dict[str, Any]:
    """Fetch the live model list from the repo. Offline-safe."""
    try:
        req = urllib.request.Request(
            _CONTENTS_URL, headers={"User-Agent": "pseudo-domo-mcp",
                                    "Accept": "application/vnd.github+json"})
        with urllib.request.urlopen(req, timeout=timeout) as resp:
            items = json.loads(resp.read().decode())
        keys = sorted(i["name"] for i in items
                      if i.get("type") == "dir" and i["name"] not in _NON_MODELS)
        if keys:
            with open(_CACHE, "w", encoding="utf-8") as fh:
                json.dump({"models": keys}, fh, indent=2)
            return {"ok": True, "count": len(keys),
                    "message": f"Loaded {len(keys)} industry models from the repo."}
        return {"ok": False, "count": len(_FALLBACK),
                "message": "Repo returned no model directories; using built-in list."}
    except Exception as e:
        return {"ok": False, "count": len(_FALLBACK),
                "message": f"Could not reach the models repo ({e}); using built-in "
                           f"list of {len(_FALLBACK)} models (offline-safe)."}
