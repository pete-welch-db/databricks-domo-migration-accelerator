"""feasibility — per-source Lakeflow Connect feasibility scoring.

Lakeflow Connect offers managed, low-code ingestion connectors for a set of
enterprise sources; everything else falls back to Auto Loader (files/cloud
storage), a database CDC connector, or custom ingestion. This module holds a
curated connector-support matrix and scores each Domo source system:

    GREEN  — first-class Lakeflow Connect managed connector exists
    AMBER  — ingestible via Auto Loader / generic DB / partner path, some work
    RED    — no clean managed path; needs custom ingestion or app re-platform

The matrix is a maintained reference (verify against the current Lakeflow
Connect connector list before customer distribution). Scores are DRAFT-grade
sequencing signals, not a commitment.
"""

from __future__ import annotations

from typing import Any, Dict, List

# Normalized source key -> feasibility record.
# `pattern` is the recommended Databricks ingestion pattern.
_MATRIX: Dict[str, Dict[str, Any]] = {
    "salesforce": {
        "rating": "GREEN", "connector": "Lakeflow Connect — Salesforce (managed)",
        "pattern": "Managed connector, incremental",
        "rationale": "Salesforce is a first-class Lakeflow Connect managed connector.",
    },
    "sql server": {
        "rating": "GREEN", "connector": "Lakeflow Connect — SQL Server (managed CDC)",
        "pattern": "Managed connector, CDC",
        "rationale": "SQL Server has a managed Lakeflow Connect connector with CDC.",
    },
    "workday": {
        "rating": "GREEN", "connector": "Lakeflow Connect — Workday (managed)",
        "pattern": "Managed connector",
        "rationale": "Workday reports are a supported managed connector.",
    },
    "servicenow": {
        "rating": "GREEN", "connector": "Lakeflow Connect — ServiceNow (managed)",
        "pattern": "Managed connector",
        "rationale": "ServiceNow is a supported managed connector.",
    },
    "google sheets": {
        "rating": "AMBER", "connector": "Auto Loader (exported CSV) or partner API",
        "pattern": "Auto Loader on scheduled export",
        "rationale": "No managed connector; land periodic exports to a volume and Auto Load. Better long-term: replace the sheet with a governed input.",
    },
    "excel/workbench": {
        "rating": "AMBER", "connector": "Auto Loader (file drop) / Databricks App form",
        "pattern": "Auto Loader on file arrival",
        "rationale": "Manual Excel uploads become file-arrival Auto Loader ingestion; the hand-maintained sheet is a governance smell — candidate to replace with a Databricks App form.",
    },
    "servicedesk plus": {
        "rating": "AMBER", "connector": "REST API extract -> Auto Loader / DLT",
        "pattern": "Scheduled API pull to bronze",
        "rationale": "No managed connector; ingest via its REST API on a schedule.",
    },
    "oracle": {
        "rating": "GREEN", "connector": "Lakeflow Connect — Oracle (managed CDC)",
        "pattern": "Managed connector, CDC",
        "rationale": "Oracle has a managed Lakeflow Connect connector with CDC.",
    },
    "mysql": {
        "rating": "GREEN", "connector": "Lakeflow Connect — MySQL (managed CDC)",
        "pattern": "Managed connector, CDC",
        "rationale": "MySQL has a managed Lakeflow Connect connector with CDC.",
    },
    "postgres": {
        "rating": "GREEN", "connector": "Lakeflow Connect — PostgreSQL (managed CDC)",
        "pattern": "Managed connector, CDC",
        "rationale": "PostgreSQL has a managed Lakeflow Connect connector with CDC.",
    },
    "legacy": {
        "rating": "AMBER", "connector": "JDBC / DB extract -> Auto Loader",
        "pattern": "DB extract or JDBC to bronze",
        "rationale": "Custom/legacy system; ingest via its database or extract files. Assess for a supported DB engine underneath (may upgrade to GREEN).",
    },
    "domo app/form (writeback)": {
        "rating": "RED", "connector": "Re-platform: Databricks App + Lakebase",
        "pattern": "Lakebase (OLTP writeback) + Databricks App",
        "rationale": "This is not an ingestion problem — it's a transactional writeback app. Re-platform onto Databricks Apps + Lakebase. This is the sticky shadow-IT layer Power BI/Fabric/Sigma can't cover.",
    },
    "domo (derived)": {
        "rating": "GREEN", "connector": "N/A — derived inside Domo",
        "pattern": "Rebuilt as SDP medallion (no external ingest)",
        "rationale": "Derived DataSet produced by a Domo ETL; it has no external source — it becomes gold in the transpiled pipeline.",
    },
}

_DEFAULT = {
    "rating": "AMBER", "connector": "Auto Loader (generic file landing)",
    "pattern": "Land to volume + Auto Loader",
    "rationale": "Unrecognized source; default to file-based Auto Loader ingestion pending a source deep-dive.",
}


def score_source(source_system: str) -> Dict[str, Any]:
    """Match a source system to the matrix.

    Sources arrive with qualifiers ("SQL Server (MES)", "Oracle ERP"), so match
    by longest matrix key contained in the (lowercased) source string, falling
    back to an exact key, then the generic default.
    """
    key = source_system.strip().lower()
    rec = _MATRIX.get(key)
    if rec is None:
        # longest containing key wins (so "sql server (mes)" -> "sql server")
        hits = sorted((k for k in _MATRIX if k in key), key=len, reverse=True)
        rec = _MATRIX[hits[0]] if hits else _DEFAULT
    rec = dict(rec)
    rec["source_system"] = source_system
    return rec


def score_all(source_systems: List[str]) -> List[Dict[str, Any]]:
    ranked = [score_source(s) for s in source_systems]
    order = {"GREEN": 0, "AMBER": 1, "RED": 2}
    ranked.sort(key=lambda r: order.get(r["rating"], 3))
    return ranked
