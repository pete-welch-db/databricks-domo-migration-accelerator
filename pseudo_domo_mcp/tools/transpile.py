"""transpile_lineage — emit an SDP pipeline for one Domo lineage triplet."""

from __future__ import annotations

import os
import tempfile
from typing import Any, Dict, Optional

from ..core.domo_client import get_provider
from ..core import classifier
from ..transpiler import pipeline

__all__ = ["transpile_lineage"]


def transpile_lineage(lineage_id: str,
                      industry: str = "automotive",
                      out_dir: Optional[str] = None) -> Dict[str, Any]:
    """Transpile one Domo lineage triplet into a Databricks SDP medallion.

    Runs the 6-agent transpiler (Ingest -> Parse -> Emit -> BeastMode ->
    Repoint -> Reconcile) over a lineage's triplet (Magic ETL + DataSet schema
    + card Beast Modes) and returns the emitted bronze/silver/gold Spark SQL,
    the folded semantic-metrics view, the Domo->Databricks connector-swap plan,
    and the PASS/FAIL reconciliation gate.

    Args:
        lineage_id: the triplet lineage id (e.g. "customer360"). Get valid ids
            from domo_assess (assessments with has_triplet=true).
        industry: industry model to tag the value driver against.
        out_dir: optional directory for the emitted .sql/.json artifacts;
            defaults to a temp dir.

    Returns the transpile result including in-memory SQL, the reconcile gate,
    and artifact paths. The gold view is schema-parity-matched to the Domo
    DataSet contract so the connector swap is transparent to every bound card.
    """
    p = get_provider()

    # Locate the dataflow to derive value-driver metadata for the report.
    df = next((d for d in p.list_dataflows()
               if d.get("_triplet_lineage_id") == lineage_id), None)
    domain = classifier.classify_domain(df["name"]) if df else "unknown"
    val = classifier.value_tag(domain)

    # The transpiler's IngestAgent reads triplets from the lineages dir.
    fixtures_dir = getattr(p, "lineages_dir_path", lambda: None)()
    if not fixtures_dir or not os.path.isdir(fixtures_dir):
        return {"error": "Active provider exposes no lineage triplet directory. "
                         "Triplet transpile needs the full Magic ETL + schema + "
                         "card export (fixtures today; export/private API live)."}

    base = out_dir or tempfile.mkdtemp(prefix=f"transpile_{lineage_id}_")
    out_json = os.path.join(base, "out")
    out_sql = os.path.join(base, "out_sql")

    result = pipeline.run(
        lineage_id=lineage_id,
        fixtures_dir=fixtures_dir,
        out_dir=out_json,
        out_sql_dir=out_sql,
        value_driver=val["driver"],
        value_per_year=val["value_per_year"],
        owners=[df["owner"]["name"]] if df and df.get("owner") else [],
    )
    result["industry_context"] = industry
    result["data_domain"] = domain
    return result
