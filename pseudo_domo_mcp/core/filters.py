"""filters — multi-criteria filtering over the asset inventory.

Pure logic: `apply_filter(criteria, assets)` narrows the inventory by any mix of
governance / type / source / owner / domain / value / complexity / effort /
usage / triplet / disposition. A saved set of criteria IS a migration wave
candidate (persistence lives in tools/filters.py, keeping core store-free).

`facets(assets)` returns the distinct values present, so the UI can build the
filter panel from the actual estate rather than a hard-coded list.
"""

from __future__ import annotations

from typing import Any, Dict, List, Optional, Set


def _as_set(v: Any) -> Optional[Set[str]]:
    if v is None or v == "":
        return None
    if isinstance(v, str):
        return {v}
    return {x for x in v if x not in (None, "")} or None


def _asset_sources(a: Dict[str, Any]) -> Set[str]:
    if a.get("source_systems"):
        return set(a["source_systems"])
    return {a["source_system"]} if a.get("source_system") else set()


def _match(a: Dict[str, Any], c: Dict[str, Any]) -> bool:
    def band(key):  # nested {band: ...}
        return (a.get(key) or {}).get("band")

    checks = [
        (_as_set(c.get("asset_type")), a.get("asset_type")),
        (_as_set(c.get("governance")), a.get("governance")),
        (_as_set(c.get("data_domain")), a.get("data_domain")),
        (_as_set(c.get("owner")), a.get("owner")),
        (_as_set(c.get("value_band")), band("value")),
        (_as_set(c.get("complexity_band")), band("complexity")),
        (_as_set(c.get("effort_band")), band("effort")),
        (_as_set(c.get("usage_band")), band("usage")),
        (_as_set(c.get("disposition")), (a.get("disposition") or {}).get("disposition")),
    ]
    for allowed, actual in checks:
        if allowed and actual not in allowed:
            return False

    srcs = _as_set(c.get("source_system"))
    if srcs and not (_asset_sources(a) & srcs):
        return False

    usage = (a.get("usage") or {}).get("usage_score", 0)
    if c.get("min_usage") is not None and usage < c["min_usage"]:
        return False
    if c.get("max_usage") is not None and usage > c["max_usage"]:
        return False

    effort = (a.get("effort") or {}).get("effort_1_5")
    if c.get("effort_min") is not None and (effort is None or effort < c["effort_min"]):
        return False
    if c.get("effort_max") is not None and (effort is None or effort > c["effort_max"]):
        return False

    if c.get("has_triplet") is not None and bool(a.get("has_triplet")) != bool(c["has_triplet"]):
        return False

    q = c.get("search")
    if q and q.lower() not in (a.get("name") or "").lower():
        return False
    return True


def apply_filter(criteria: Dict[str, Any], assets: List[Dict[str, Any]]) -> List[Dict[str, Any]]:
    """Return the assets matching every provided criterion (empty criteria = all)."""
    c = criteria or {}
    return [a for a in assets if _match(a, c)]


def facets(assets: List[Dict[str, Any]]) -> Dict[str, List[str]]:
    """Distinct filterable values present in the estate (for building the UI)."""
    def collect(getter):
        vals = set()
        for a in assets:
            v = getter(a)
            if isinstance(v, (list, set)):
                vals.update(x for x in v if x)
            elif v not in (None, "", "n/a"):
                vals.add(v)
        return sorted(vals)

    return {
        "asset_type": collect(lambda a: a.get("asset_type")),
        "governance": collect(lambda a: a.get("governance")),
        "data_domain": collect(lambda a: a.get("data_domain")),
        "source_system": collect(_asset_sources),
        "owner": collect(lambda a: a.get("owner")),
        "value_band": collect(lambda a: (a.get("value") or {}).get("band")),
        "complexity_band": collect(lambda a: (a.get("complexity") or {}).get("band")),
        "effort_band": collect(lambda a: (a.get("effort") or {}).get("band")),
        "usage_band": collect(lambda a: (a.get("usage") or {}).get("band")),
    }
