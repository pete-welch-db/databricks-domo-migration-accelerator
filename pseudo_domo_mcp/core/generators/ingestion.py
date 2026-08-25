"""Generator: UC ingestion scaffolding per connector.

Routes each connector to its Databricks ingestion path (from the feasibility
matrix) and emits a starting artifact: a Lakeflow Connect resource note, an Auto
Loader SQL, an Apps+Lakebase re-platform note, or a custom-Python stub — plus a
shared UC Connection + secret-scope scaffold (credentials/secrets).
"""

from __future__ import annotations

import re
from typing import Any, Dict


def _slug(name: str) -> str:
    return re.sub(r"[^a-zA-Z0-9_]", "_", (name or "source")).strip("_").lower()[:50] or "source"


def _uc_connection_scaffold(name: str) -> str:
    slug = _slug(name)
    return f"""-- UC Connection + secrets scaffold for source: {name}
-- 1) Store credentials in a secret scope (never inline):
--    databricks secrets create-scope {slug}_ingest
--    databricks secrets put-secret {slug}_ingest password
-- 2) Create a governed Unity Catalog connection:
CREATE CONNECTION IF NOT EXISTS {slug}_conn
  TYPE <type>
  OPTIONS (host '<host>', port '<port>', user '<user>',
           password secret('{slug}_ingest', 'password'));
"""


def render_connector(connector_asset: Dict[str, Any], catalog: str, schema: str) -> Dict[str, str]:
    """Return {relative_filename: content} for one connector asset."""
    name = connector_asset.get("name", "source")
    slug = _slug(name)
    remap = connector_asset.get("databricks_remap") or {}
    pattern = (remap.get("pattern", "") + " " + remap.get("connector", "")).lower()
    files: Dict[str, str] = {}
    conn = _uc_connection_scaffold(name)

    if remap.get("rating") == "RED" or "lakebase" in pattern or "writeback" in pattern:
        files[f"src/ingestion/{slug}_apps_lakebase.md"] = (
            f"# {name} — re-platform to Databricks Apps + Lakebase\n\n"
            "This is a transactional writeback source, not an ingestion. Rebuild "
            "the form/app as a Databricks App backed by Lakebase (OLTP). Not a "
            "Lakeflow pipeline.\n")
    elif "auto loader" in pattern:
        files[f"src/ingestion/{slug}_autoloader.sql"] = (
            f"-- Auto Loader ingestion for {name} (no managed connector).\n"
            f"CREATE OR REFRESH STREAMING TABLE {catalog}.{schema}.bronze_{slug}\n"
            f"AS SELECT * FROM STREAM read_files(\n"
            f"  '/Volumes/{catalog}/{schema}/landing/{slug}/',\n"
            f"  format => 'csv', header => true);\n")
    elif "managed" in pattern or "lakeflow" in pattern:
        files[f"src/ingestion/{slug}_lakeflow_connect.md"] = (
            f"# {name} — Lakeflow Connect (managed)\n\n"
            f"Use the managed connector: **{remap.get('connector', 'Lakeflow Connect')}**.\n"
            f"Create a UC connection + ingestion pipeline landing into "
            f"`{catalog}.{schema}.bronze_{slug}`.\n\n```sql\n{conn}```\n")
    else:
        files[f"src/ingestion/{slug}_custom_ingest.py"] = (
            f'"""Custom ingestion for {name} — no managed Lakeflow Connect path.\n'
            f'Pull via the source API/JDBC and land into '
            f'{catalog}.{schema}.bronze_{slug}. Use a UC connection + secret scope.\n"""\n'
            f"# See {slug}_connection.sql for the UC connection + secret scaffold.\n")

    files[f"src/ingestion/{slug}_connection.sql"] = conn
    return files
