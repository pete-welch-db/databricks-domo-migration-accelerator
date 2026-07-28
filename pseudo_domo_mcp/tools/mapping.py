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


def industry_model_map(dataset_id: str,
                       industry: str = "automotive",
                       prefer_domain: Optional[str] = None) -> Dict[str, Any]:
    """Draft-map a Domo DataSet's columns onto a canonical industry-model table.

    Conforms a Domo output DataSet to the Databricks Industry Data Model
    ("silver") so the transpiled pipeline lands governed, standard entities
    rather than a like-for-like copy.

    Args:
        dataset_id: the Domo DataSet id to map (must have a schema — i.e. a
            derived/output dataset or one with a known column contract).
        industry: target model, "automotive" (default) or "transport_shipping".
        prefer_domain: optional canonical domain to bias table selection
            (e.g. "customer", "aftersales"); if omitted it's inferred from the
            dataset name.

    Returns the chosen target table, per-column mapping with confidence scores,
    and any unmapped columns flagged for human review. Draft-grade suggestions.
    """
    p = get_provider()

    # Resolve the DataSet's schema. Output datasets carry it via their lineage
    # triplet schema doc; otherwise use the census-level column list if present.
    schema_cols = _resolve_schema(p, dataset_id)
    if schema_cols is None:
        return {"error": f"No column schema available for dataset '{dataset_id}'. "
                         "Provide an output/derived DataSet with a known schema, "
                         "or wire the live provider for full DataSet detail."}

    ds = next((d for d in p.list_datasets() if d["id"] == dataset_id), {})
    if prefer_domain is None:
        prefer_domain = classifier.classify_domain(ds.get("name", ""))

    model = load_model(industry)
    result = map_columns(model, schema_cols, prefer_domain=prefer_domain)
    result["dataset_id"] = dataset_id
    result["dataset_name"] = ds.get("name")
    result["inferred_domain"] = prefer_domain
    result["note"] = (
        "Draft mapping (name+type+comment similarity). Cross-domain blends "
        "(e.g. Customer 360) will leave aggregate columns unmapped against a "
        "single table — those belong to sibling domains and are flagged for "
        "human review, not dropped."
    )
    return result


def _resolve_schema(provider, dataset_id: str):
    """Best-effort column contract for a dataset id (list of {name,type})."""
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
