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

from . import governance, feasibility, classifier, scoring


def build_inventory(provider) -> Dict[str, Any]:
    """Return {"assets": [...], "counts_by_type": {...}} for the whole estate."""
    datasets = provider.list_datasets()
    dataflows = provider.list_dataflows()
    cards = provider.list_cards()
    pages = provider.list_pages()
    ds_by_id = {d["id"]: d for d in datasets}

    # Precompute the maps the Profiler/Analyzer scoring needs (one pass).
    #   bm_by_dataset: Beast Modes reachable per output dataset (for complexity)
    #   usage_ctx:     dependency + scale maps (for the usage proxy)
    bm_by_dataset: Dict[str, int] = {}
    for c in cards:
        for ds_id in c.get("boundDatasetIds", []):
            bm_by_dataset[ds_id] = max(bm_by_dataset.get(ds_id, 0),
                                       c.get("beastModeCount", 0))
    usage_ctx = scoring.usage_context(datasets, dataflows, cards, pages)

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
        a = {
            "id": d["id"], "asset_type": "dataset", "name": d.get("name"),
            "governance": {"managed": "governed", "manual": "shadow",
                           "app": "shadow"}.get(governance.classify_source(src), "uncertain"),
            "source_system": src,
            "rows": d.get("rows"), "columns": d.get("columns"),
            "owner": (d.get("owner") or {}).get("name"),
        }
        a["usage"] = scoring.score_usage(a, usage_ctx)
        assets.append(a)

    # -- dataflows (Magic ETL / SQL) -------------------------------------- #
    for df in dataflows:
        inp = [ds_by_id[i] for i in df.get("inputDatasetIds", []) if i in ds_by_id]
        g = governance.infer(df, inp)
        srcs = []
        for ds in inp:
            s = ds.get("_source_system")
            if s and s not in srcs:
                srcs.append(s)
        out_ids = df.get("outputDatasetIds", [])
        beast_modes = max((bm_by_dataset.get(o, 0) for o in out_ids), default=0)
        domain = classifier.classify_domain(df.get("name", ""), " ".join(srcs))
        has_triplet = bool(df.get("_triplet_lineage_id"))
        cx = classifier.complexity_score(df, beast_modes)
        a = {
            "id": df["id"],
            "asset_type": "magic_etl" if df.get("databaseType") == "MAGIC" else "sql_dataflow",
            "name": df.get("name"),
            "governance": g["governance"],
            "governance_confidence": g["confidence"],
            "governance_signals": g["signals"],
            "database_type": df.get("databaseType"),
            "action_count": df.get("actionCount"),
            "owner": (df.get("owner") or {}).get("name"),
            "data_domain": domain,
            "source_systems": srcs,
            "complexity": cx,
            "value": classifier.value_tag(domain),
            "effort": scoring.score_effort(df, has_triplet, cx),
            "has_triplet": has_triplet,
            "triplet_lineage_id": df.get("_triplet_lineage_id"),
            "_output_dataset_ids": out_ids,
            "_run_cadence": df.get("runCadence"),
        }
        a["usage"] = scoring.score_usage(a, usage_ctx)
        a.pop("_output_dataset_ids", None)
        a.pop("_run_cadence", None)
        assets.append(a)

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
        a = {
            "id": pg["id"], "asset_type": "page", "name": pg.get("name"),
            "card_count": len(pg.get("cardIds", [])),
            "owner": (pg.get("owner") or {}).get("name"),
            "governance": "n/a",
        }
        a["usage"] = scoring.score_usage(a, usage_ctx)
        assets.append(a)

    # Tag each asset with its migration path + whether it drives the Build step.
    type_meta = {t["key"]: t for t in ASSET_TYPES}
    counts: Dict[str, int] = {}
    for a in assets:
        counts[a["asset_type"]] = counts.get(a["asset_type"], 0) + 1
        tm = type_meta.get(a["asset_type"], {})
        a["migration_path"] = tm.get("path", "")
        a["migration_path_label"] = PATH_LABEL.get(tm.get("path", ""), "")
        a["build"] = tm.get("build", False)

    return {"assets": assets, "counts_by_type": counts}


# Display metadata for the UI. Every type has a migration PATH — but the paths
# differ; only the transform types go through the SDP transpiler (the Build
# step). `path` is the migration strategy; `build` = drives the transpiler.
ASSET_TYPES = [
    {"key": "connector", "label": "Connectors", "build": False,
     "path": "ingest",
     "hint": "Source connections → Databricks ingestion (Lakeflow Connect / Auto Loader / Apps+Lakebase)"},
    {"key": "magic_etl", "label": "Magic ETL", "build": True,
     "path": "transpile",
     "hint": "Visual transform DAGs → Lakeflow Declarative Pipelines (Build step)"},
    {"key": "sql_dataflow", "label": "SQL DataFlows", "build": True,
     "path": "transpile",
     "hint": "SQL transforms → Spark SQL, hand-review flagged (Build step)"},
    {"key": "dataset", "label": "DataSets", "build": False,
     "path": "byproduct",
     "hint": "Inputs migrate via their connector; outputs ARE the gold table a pipeline produces"},
    {"key": "card", "label": "Cards", "build": False,
     "path": "repoint",
     "hint": "Re-point to the new gold table (Domo connector swap) or rebuild as an AI/BI dashboard"},
    {"key": "beast_mode", "label": "Beast Modes", "build": False,
     "path": "metric_view",
     "hint": "Card calc fields → Unity Catalog metric view (built with the pipeline)"},
    {"key": "page", "label": "Pages", "build": False,
     "path": "repoint",
     "hint": "A set of re-pointed cards → an AI/BI dashboard"},
]

# Human-readable migration path labels (for the UI).
PATH_LABEL = {
    "transpile": "Transpile → SDP pipeline",
    "ingest": "Ingest → bronze (connector remap)",
    "byproduct": "Produced by a pipeline",
    "repoint": "Re-point → AI/BI",
    "metric_view": "→ metric view",
}
