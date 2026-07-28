"""industry_model_map — draft-map a Domo DataSet onto the canonical model."""

from __future__ import annotations

from typing import Any, Dict, Optional

from ..core.domo_client import get_provider
from ..core import classifier
from ..core.industry_model import load_model, available_industries
from ..core.mapper import map_columns

__all__ = ["industry_model_map", "list_industry_models"]


def list_industry_models(industry: str = "") -> Dict[str, Any]:
    """List available Databricks Industry Data Models (and their domains).

    Args:
        industry: optional — if given (e.g. "automotive"), returns that model's
            domains and table count; otherwise lists all vendored industries.
    """
    if not industry:
        return {"industries": available_industries(),
                "note": "Vendored MVM slices of the Databricks Industry Data "
                        "Models. Use one as the map target."}
    m = load_model(industry)
    return {
        "industry": industry,
        "domains": m.domains,
        "table_count": len(m.tables),
        "tables": [t.fqn for t in m.tables],
    }


def industry_model_map(dataset_id: str = "",
                       lineage_id: str = "",
                       industry: str = "automotive",
                       prefer_domain: Optional[str] = None,
                       force_table_fqn: Optional[str] = None,
                       overrides: Optional[Dict[str, str]] = None) -> Dict[str, Any]:
    """Draft-map a Domo DataSet's columns onto a canonical industry-model table.

    Conforms a Domo output DataSet to the Databricks Industry Data Model
    ("silver") so the transpiled pipeline lands governed, standard entities
    rather than a like-for-like copy.

    Args:
        dataset_id: the Domo DataSet id to map; OR
        lineage_id: a Build lineage id — its output DataSet is mapped.
        industry: target model key (e.g. "automotive", "transport_shipping").
        prefer_domain: bias table selection; inferred from name if omitted.
        force_table_fqn: pin the target table (user re-selected it in the UI).
        overrides: {domo_column: target_column | ""} human column choices.

    Returns per-column mappings with confidence + ranked candidates, plus the
    model's table catalog and the chosen table's columns for UI re-selection.
    """
    p = get_provider()

    if lineage_id and not dataset_id:
        dataset_id = _output_dataset_for_lineage(p, lineage_id) or ""
    schema_cols = _resolve_schema(p, dataset_id)
    if schema_cols is None:
        return {"error": f"No column schema available for '{dataset_id or lineage_id}'. "
                         "Needs an output/derived DataSet with a known schema."}

    ds = next((d for d in p.list_datasets() if d["id"] == dataset_id), {})
    if prefer_domain is None and not force_table_fqn:
        prefer_domain = classifier.classify_domain(ds.get("name", ""))

    model = load_model(industry)
    result = map_columns(model, schema_cols, prefer_domain=prefer_domain,
                         force_table_fqn=force_table_fqn, overrides=overrides)
    result["dataset_id"] = dataset_id
    result["dataset_name"] = ds.get("name")
    result["lineage_id"] = lineage_id
    result["inferred_domain"] = prefer_domain
    result["note"] = (
        "Draft mapping (name+type+comment similarity). Re-pick the target table "
        "or any column; cross-domain blends leave some columns for a sibling "
        "table — flagged, not dropped."
    )
    return result


def _output_dataset_for_lineage(provider, lineage_id: str) -> Optional[str]:
    for df in provider.list_dataflows():
        if df.get("_triplet_lineage_id") == lineage_id:
            outs = df.get("outputDatasetIds", [])
            return outs[0] if outs else None
    return None


def _resolve_schema(provider, dataset_id: str):
    """Best-effort column contract for a dataset id (list of {name,type})."""
    if not dataset_id:
        return None
    # 1) If it's the output of a lineage triplet, use the triplet schema doc.
    for df in provider.list_dataflows():
        if dataset_id in df.get("outputDatasetIds", []) and df.get("_triplet_lineage_id"):
            trip = provider.get_lineage_triplet(df["_triplet_lineage_id"])
            if trip:
                return trip["schema"]["schema"]["columns"]
    # 2) Some census datasets may carry an inline schema (live provider).
    ds = next((d for d in provider.list_datasets() if d["id"] == dataset_id), None)
    if ds and isinstance(ds.get("schema"), dict):
        return ds["schema"].get("columns")
    return None
