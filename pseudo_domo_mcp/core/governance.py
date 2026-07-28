"""governance — INFER governed vs. shadow IT from API-observable signals.

Domo's API has no "governance" field. A naive automated scan therefore cannot
tell an IT-owned governed pipeline from citizen-dev shadow IT — but it CAN
observe signals that strongly imply it, and it can show its reasoning so a human
can confirm or override. This module does exactly that.

Signals we read (all available from discovery-level metadata):
  * source/connector type — a managed enterprise connector (SQL Server,
    Salesforce, Oracle, ServiceNow…) implies IT-governed ingestion; a
    hand-maintained spreadsheet / manual file upload (Excel/Workbench, Google
    Sheets, CSV) implies citizen-dev shadow IT.
  * writeback — a transactional app/form that writes back is shadow-IT app
    territory (and a re-platform, not a pipeline).
  * owner — a team / distribution-list / service account implies governed; a
    single named individual leans shadow.
  * refresh cadence — a regular managed schedule implies governed; "on-submit"
    / manual / stale implies shadow.

Output per asset: a governance label (governed | shadow | uncertain), a 0–1
confidence, and a list of human-readable signal strings. Nothing is asserted as
fact — the UI surfaces the "why" so the reviewer decides.
"""

from __future__ import annotations

import re
from typing import Any, Dict, List, Optional

# Source-system classification by keyword. Each source is one of:
#   managed  — enterprise system, typically an IT-governed connector
#   manual   — spreadsheet / manual upload — citizen-dev smell
#   app      — writeback app/form — shadow-IT application
#   derived  — produced inside Domo (no external source)
_MANAGED = ["sql server", "oracle", "mysql", "postgres", "salesforce",
            "servicenow", "workday", "sap", "snowflake", "redshift", "bigquery",
            "netsuite", "mes", "erp", "wms", "itsm", "crm", "s3", "azure", "gcs"]
_MANUAL = ["excel", "workbench", "google sheet", "gsheet", "csv", "spreadsheet",
           "manual", "upload"]
_APP = ["app/form", "webform", "writeback", "form"]
_DERIVED = ["domo", "derived"]


def classify_source(source_system: str) -> str:
    """Return 'managed' | 'manual' | 'app' | 'derived' | 'unknown' for a source."""
    s = (source_system or "").lower()
    if any(k in s for k in _APP):
        return "app"
    if any(k in s for k in _MANUAL):
        return "manual"
    if any(k in s for k in _DERIVED):
        return "derived"
    if any(k in s for k in _MANAGED):
        return "managed"
    return "unknown"


def _owner_is_individual(owner_name: str) -> bool:
    """Heuristic: a two-token 'First Last' name looks like an individual; a
    team/service/DL name (contains team/ops/analytics/service/svc/group/admin
    or is one token) looks governed."""
    n = (owner_name or "").strip()
    if not n:
        return False
    team_words = ("team", "ops", "operations", "analytics", "service", "svc",
                  "group", "admin", "platform", "engineering", "it", "dl-",
                  "shared", "dept")
    low = n.lower()
    if any(w in low for w in team_words):
        return False
    tokens = n.split()
    return 2 <= len(tokens) <= 3 and all(t[:1].isupper() for t in tokens)


def infer(dataflow: Dict[str, Any],
          input_datasets: List[Dict[str, Any]],
          card: Optional[Dict[str, Any]] = None) -> Dict[str, Any]:
    """Infer governance for one dataflow from its own + its inputs' signals.

    Returns {"governance", "confidence", "signals": [...], "source_classes": {...}}.
    The score starts neutral and each signal nudges it toward governed (+) or
    shadow (−); the sign of the total picks the label, its magnitude the
    confidence.
    """
    signals: List[str] = []
    score = 0.0

    # 1) Source/connector types across inputs.
    classes = [classify_source(ds.get("_source_system", "")) for ds in input_datasets]
    src_names = [ds.get("_source_system", "?") for ds in input_datasets]
    n_managed = classes.count("managed")
    n_manual = classes.count("manual")
    n_app = classes.count("app")

    if n_app:
        score -= 2.0
        signals.append(f"writeback app/form source ({_join(src_names, classes, 'app')}) "
                       f"→ shadow-IT application (re-platform to Apps + Lakebase)")
    if n_manual:
        score -= 1.4 * n_manual
        signals.append(f"manual/spreadsheet source ({_join(src_names, classes, 'manual')}) "
                       f"→ citizen-dev ingestion")
    if n_managed:
        score += 1.2 * n_managed
        signals.append(f"managed enterprise connector ({_join(src_names, classes, 'managed')}) "
                       f"→ IT-governed ingestion")

    # 2) Explicit writeback flag on the dataflow.
    if dataflow.get("_has_writeback"):
        score -= 1.5
        signals.append("dataflow writes back to source → transactional shadow-IT app")

    # 3) Owner shape.
    owner = (dataflow.get("owner") or {}).get("name", "")
    if owner:
        if _owner_is_individual(owner):
            score -= 0.8
            signals.append(f"owned by an individual ('{owner}') → leans citizen-dev")
        else:
            score += 0.8
            signals.append(f"owned by a team/service ('{owner}') → leans governed")

    # 4) Refresh cadence.
    cadence = (dataflow.get("runCadence") or "").lower()
    if cadence:
        if any(k in cadence for k in ("on-submit", "manual", "ad hoc", "adhoc")):
            score -= 0.6
            signals.append(f"refresh cadence '{cadence}' → manual/event, not a managed schedule")
        elif re.search(r"day|hour|x/|daily|hourly|weekly|nightly", cadence):
            score += 0.6
            signals.append(f"regular managed schedule ('{cadence}') → governed")

    # Decide label + confidence from the accumulated score.
    if score >= 1.0:
        gov = "governed"
    elif score <= -1.0:
        gov = "shadow"
    else:
        gov = "uncertain"
    confidence = round(min(abs(score) / 4.0, 0.98), 2)

    return {
        "governance": gov,
        "confidence": confidence,
        "signals": signals,
        "source_classes": {"managed": n_managed, "manual": n_manual, "app": n_app},
    }


def _join(names: List[str], classes: List[str], want: str) -> str:
    return ", ".join(n for n, c in zip(names, classes) if c == want) or want
