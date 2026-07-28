"""assets — a unified, asset-TYPE-aware view of a Domo estate.

Domo organizes work into distinct object types; a migration inventory should be
browsable and searchable by each. We surface:

    connector  — a source connection (derived by grouping DataSets by source
                 system). THE object that must be planned for Databricks
                 remapping: each connector maps to a Lakeflow Connect managed
                 connector, Auto Loader, or an Apps+Lakebase re-platform.
    dataset    — a Domo DataSet (a table)
    dataflow   — a transform: Magic ETL or SQL DataFlow
    card       — a visualization
    beast_mode — a card-level calculated field (migrates into the semantic layer)
    page       — a dashboard (holds cards)

Each asset carries a common shape {id, asset_type, name, governance, ...} plus
type-specific fields, so the UI can render one searchable list filtered by type.
"""

from __future__ import annotations

from typing import Any, Dict, List

from . import governance, feasibility


def build_inventory(provider) -> Dict[str, Any]:
    """Return {"assets": [...], "counts_by_type": {...}} for the whole estate."""
    datasets = provider.list_datasets()
    dataflows = provider.list_dataflows()
    cards = provider.list_cards()
    pages = provider.list_pages()
    ds_by_id = {d["id"]: d for d in datasets}

    assets: List[Dict[str, Any]] = []

    # -- connectors (derived from source systems) ------------------------- #
    # Group datasets by their source system; each group is one connector that
    # needs a Databricks ingestion plan.
    by_source: Dict[str, List[Dict[str, Any]]] = {}
    for d in datasets:
        by_source.setdefault(d.get("_source_system", "Unknown"), []).append(d)
    for source, dss in by_source.items():
        feas = feasibility.score_source(source)
        gov = governance.classify_source(source)
        assets.append({
            "id": f"connector::{source}",
            "asset_type": "connector",
            "name": source,
            "governance": {"managed": "governed", "manual": "shadow",
                           "app": "shadow"}.get(gov, "uncertain"),
            "feeds_datasets": [d["id"] for d in dss],
            "dataset_count": len(dss),
            "databricks_remap": {
                "rating": feas["rating"],
                "connector": feas["connector"],
                "pattern": feas["pattern"],
                "rationale": feas["rationale"],
            },
        })

    # -- datasets --------------------------------------------------------- #
    for d in datasets:
        src = d.get("_source_system", "Unknown")
        assets.append({
            "id": d["id"], "asset_type": "dataset", "name": d.get("name"),
            "governance": {"managed": "governed", "manual": "shadow",
                           "app": "shadow"}.get(governance.classify_source(src), "uncertain"),
            "source_system": src,
            "rows": d.get("rows"), "columns": d.get("columns"),
            "owner": (d.get("owner") or {}).get("name"),
        })

    # -- dataflows (Magic ETL / SQL) -------------------------------------- #
    for df in dataflows:
        inp = [ds_by_id[i] for i in df.get("inputDatasetIds", []) if i in ds_by_id]
        g = governance.infer(df, inp)
        assets.append({
            "id": df["id"],
            "asset_type": "magic_etl" if df.get("databaseType") == "MAGIC" else "sql_dataflow",
            "name": df.get("name"),
            "governance": g["governance"],
            "governance_confidence": g["confidence"],
            "governance_signals": g["signals"],
            "database_type": df.get("databaseType"),
            "action_count": df.get("actionCount"),
            "owner": (df.get("owner") or {}).get("name"),
            "has_triplet": bool(df.get("_triplet_lineage_id")),
            "triplet_lineage_id": df.get("_triplet_lineage_id"),
        })

    # -- cards + beast modes ---------------------------------------------- #
    for c in cards:
        assets.append({
            "id": c["id"], "asset_type": "card", "name": c.get("title"),
            "card_type": c.get("type"), "page_id": c.get("pageId"),
            "beast_mode_count": c.get("beastModeCount", 0),
            "bound_datasets": c.get("boundDatasetIds", []),
            "governance": "n/a",
        })
        # Beast Modes are their own migratable asset type (→ semantic layer).
        for i in range(c.get("beastModeCount", 0)):
            assets.append({
                "id": f"{c['id']}::bm{i}",
                "asset_type": "beast_mode",
                "name": f"{c.get('title')} · Beast Mode {i + 1}",
                "on_card": c["id"],
                "governance": "n/a",
                "note": "Card-level calc field — migrates into the gold semantic view.",
            })

    # -- pages ------------------------------------------------------------ #
    for pg in pages:
        assets.append({
            "id": pg["id"], "asset_type": "page", "name": pg.get("name"),
            "card_count": len(pg.get("cardIds", [])),
            "owner": (pg.get("owner") or {}).get("name"),
            "governance": "n/a",
        })

    counts: Dict[str, int] = {}
    for a in assets:
        counts[a["asset_type"]] = counts.get(a["asset_type"], 0) + 1

    return {"assets": assets, "counts_by_type": counts}


# Display metadata for the UI: label + whether the type is directly migratable.
ASSET_TYPES = [
    {"key": "connector", "label": "Connectors", "migratable": True,
     "hint": "Source connections → Databricks ingestion (Lakeflow Connect / Auto Loader / Apps+Lakebase)"},
    {"key": "magic_etl", "label": "Magic ETL", "migratable": True,
     "hint": "Visual transform DAGs → Lakeflow Declarative Pipelines"},
    {"key": "sql_dataflow", "label": "SQL DataFlows", "migratable": True,
     "hint": "SQL transforms → Spark SQL (hand-review)"},
    {"key": "dataset", "label": "DataSets", "migratable": False,
     "hint": "Tables produced/consumed by flows"},
    {"key": "card", "label": "Cards", "migratable": False,
     "hint": "Visualizations → AI/BI dashboards (re-point)"},
    {"key": "beast_mode", "label": "Beast Modes", "migratable": True,
     "hint": "Card calc fields → gold semantic layer"},
    {"key": "page", "label": "Pages", "migratable": False,
     "hint": "Dashboards holding cards"},
]
