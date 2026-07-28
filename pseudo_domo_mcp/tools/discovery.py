"""domo_discover — inventory the Domo tenant (the fleet census)."""

from __future__ import annotations

from typing import Any, Dict

from ..core.domo_client import get_provider

__all__ = ["domo_discover"]


def domo_discover(scope: str = "summary") -> Dict[str, Any]:
    """Inventory the Domo tenant for a migration assessment.

    Args:
        scope: What to return. One of:
            "summary"    — counts + governance split + source systems (default)
            "datasets"   — the DataSet census
            "dataflows"  — the DataFlow (Magic ETL / SQL) census
            "cards"      — the Card census
            "pages"      — the Page (dashboard) census
            "sources"    — distinct upstream source systems
            "all"        — every census in one payload

    Returns a dict with the requested inventory. Data comes from the active
    provider (synthetic fixtures by default; live Domo API when configured).
    """
    p = get_provider()
    scope = scope.lower().strip()

    if scope == "datasets":
        return {"datasets": p.list_datasets()}
    if scope == "dataflows":
        return {"dataflows": p.list_dataflows()}
    if scope == "cards":
        return {"cards": p.list_cards()}
    if scope == "pages":
        return {"pages": p.list_pages()}
    if scope == "sources":
        return {"source_systems": p.source_systems()}

    datasets = p.list_datasets()
    dataflows = p.list_dataflows()
    cards = p.list_cards()
    pages = p.list_pages()

    def _gov_split(items):
        g = sum(1 for i in items if i.get("_governance") == "governed")
        s = sum(1 for i in items if i.get("_governance") == "shadow")
        return {"governed": g, "shadow": s,
                "other": len(items) - g - s}

    summary = {
        "counts": {
            "datasets": len(datasets),
            "dataflows": len(dataflows),
            "cards": len(cards),
            "pages": len(pages),
            "source_systems": len(p.source_systems()),
        },
        "dataflow_types": {
            "MAGIC": sum(1 for d in dataflows if d.get("databaseType") == "MAGIC"),
            "SQL": sum(1 for d in dataflows if d.get("databaseType") == "SQL"),
        },
        "governance_split": {
            "datasets": _gov_split(datasets),
            "dataflows": _gov_split(dataflows),
            "cards": _gov_split(cards),
        },
        "source_systems": p.source_systems(),
        "note": (
            "Synthetic census (provider=fixture). Domo's public API exposes "
            "DataSet schema + card/page metadata; Magic ETL internals and "
            "Beast Mode expressions require the dataflow/card export (private "
            "API) — modeled per-lineage under fixtures/lineages/."
        ),
    }

    if scope == "all":
        return {"summary": summary, "datasets": datasets, "dataflows": dataflows,
                "cards": cards, "pages": pages}
    return summary
