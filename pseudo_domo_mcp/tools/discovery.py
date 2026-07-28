"""domo_discover — inventory the Domo tenant (the fleet census)."""

from __future__ import annotations

from typing import Any, Dict

from ..core.domo_client import get_provider
from ..core import governance
from ..core import assets as assets_mod

__all__ = ["domo_discover", "domo_inventory"]


def domo_inventory(asset_type: str = "", search: str = "") -> Dict[str, Any]:
    """Typed, searchable asset inventory of the Domo estate.

    Domo work is organized by object type; this returns every asset with a
    common shape plus type-specific fields, optionally filtered.

    Args:
        asset_type: filter to one type — connector | magic_etl | sql_dataflow |
            dataset | card | beast_mode | page. Empty = all types.
        search: case-insensitive substring match on the asset name.

    Connectors are first-class here: each carries a `databricks_remap` plan
    (Lakeflow Connect / Auto Loader / Apps+Lakebase) since source connections
    are what must be explicitly remapped for ingestion.
    """
    inv = assets_mod.build_inventory(get_provider())
    items = inv["assets"]
    if asset_type:
        items = [a for a in items if a["asset_type"] == asset_type]
    if search:
        s = search.lower()
        items = [a for a in items if s in (a.get("name") or "").lower()]
    return {"assets": items, "counts_by_type": inv["counts_by_type"],
            "asset_types": assets_mod.ASSET_TYPES, "matched": len(items)}


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

    # Governance is INFERRED from signals (see core.governance), never read
    # from a pre-tagged field — a real API scan has no governance attribute.
    ds_by_id = {d["id"]: d for d in datasets}

    def _split(labels):
        return {"governed": labels.count("governed"),
                "shadow": labels.count("shadow"),
                "uncertain": labels.count("uncertain")}

    df_gov = []
    for df in dataflows:
        inp = [ds_by_id[i] for i in df.get("inputDatasetIds", []) if i in ds_by_id]
        df_gov.append(governance.infer(df, inp)["governance"])

    def _ds_gov(ds):
        cls = governance.classify_source(ds.get("_source_system", ""))
        return {"managed": "governed", "manual": "shadow", "app": "shadow"}.get(cls, "uncertain")
    ds_labels = [_ds_gov(d) for d in datasets]

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
            "datasets": _split(ds_labels),
            "dataflows": _split(df_gov),
        },
        "source_systems": p.source_systems(),
        "note": (
            "Governed vs. shadow is INFERRED from source/connector type, "
            "writeback, owner, and cadence (Domo's API has no governance "
            "field). Synthetic census (provider=fixture); Magic ETL internals "
            "+ Beast Mode expressions require the dataflow/card export."
        ),
    }

    if scope == "all":
        return {"summary": summary, "datasets": datasets, "dataflows": dataflows,
                "cards": cards, "pages": pages}
    return summary
