"""pipeline.run() — importable wrapper around the vendored 6-agent transpiler.

The standalone `run.py` orchestrator (in the original project) printed a stage
log and called sys.exit(). For the MCP we need the same six agents wired in
sequence but returning a structured result dict so a tool can serialize it.
This module is that wrapper. It intentionally re-implements only the *wiring*
(a dozen lines) and delegates all real work to the unchanged agent modules.

Because the agent modules import each other by bare name (`from ingest import
Lineage`), we prepend this directory to sys.path before importing them.
"""

from __future__ import annotations

import datetime
import os
import sys
from typing import Any, Dict, List

_HERE = os.path.dirname(os.path.abspath(__file__))
if _HERE not in sys.path:
    sys.path.insert(0, _HERE)

# These imports resolve against the vendored agent modules in this directory.
from ingest import IngestAgent          # noqa: E402
from parse import ParseAgent            # noqa: E402
from emit import EmitAgent              # noqa: E402
from beastmode import BeastModeAgent    # noqa: E402
from repoint import RepointAgent        # noqa: E402
from reconcile import ReconcileAgent    # noqa: E402


def _stage(n: int, agent: str, status: str, detail: str) -> Dict[str, Any]:
    return {"stage": n, "agent": agent, "status": status, "detail": detail}


def run(lineage_id: str,
        fixtures_dir: str,
        out_dir: str,
        out_sql_dir: str,
        value_driver: str = "",
        value_per_year: str = "",
        owners: List[str] | None = None) -> Dict[str, Any]:
    """Run the full transpile pipeline for one lineage triplet.

    Parameters
    ----------
    lineage_id   : the fixture lineage id (e.g. "customer360"); the IngestAgent
                   looks for dataflow_<id>_*.json / dataset_<id>_schema.json /
                   card_<id>_beastmodes.json under `fixtures_dir`.
    fixtures_dir : directory holding the triplet JSON files.
    out_dir      : directory for JSON artifacts (repoint/reconcile/result).
    out_sql_dir  : directory for the emitted .sql files.

    Returns
    -------
    The same machine-readable result dict the original run.py wrote to
    out/transpile_result.json, plus an in-memory copy of the emitted SQL so a
    tool can return it without a second file read.
    """
    owners = owners or []
    os.makedirs(out_dir, exist_ok=True)
    os.makedirs(out_sql_dir, exist_ok=True)

    stages: List[Dict[str, Any]] = []

    # 1) INGEST -------------------------------------------------------------
    lineage = IngestAgent(fixtures_dir).load(lineage_id)
    stages.append(_stage(1, "IngestAgent", "PASS",
                         f"{len(lineage.inputs)} input datasets, "
                         f"type={lineage.database_type}"))

    # SQL DataFlows have no action DAG — report the gap instead of crashing.
    if lineage.is_sql:
        stages.append(_stage(2, "ParseAgent", "WARN",
                             "SQL DataFlow: raw SQL captured, not parsed to IR"))
        return {
            "schema_version": 1,
            "generated_at": _now(),
            "lineage": _lineage_meta(lineage, value_driver, value_per_year, owners),
            "stages": stages,
            "counts": {"input_datasets": len(lineage.inputs), "ir_nodes": 0,
                       "gold_columns": len(lineage.gold_schema),
                       "beast_modes_total": len(lineage.card.beast_modes),
                       "beast_modes_translated": 0},
            "reconciliation": {"gate": "NEEDS_REVIEW", "checks": []},
            "warnings": lineage.warnings,
            "sql": {},
            "artifacts": {},
        }

    # 2) PARSE --------------------------------------------------------------
    ir = ParseAgent().parse(lineage)
    stages.append(_stage(2, "ParseAgent", "PASS", f"{len(ir)} IR nodes"))

    # 3) EMIT ---------------------------------------------------------------
    emit_res = EmitAgent(out_sql_dir).emit(lineage, ir)
    stages.append(_stage(3, "EmitAgent", "PASS",
                         f"{len(emit_res.gold_columns)} gold cols; "
                         f"schema-parity gate held"))

    # 4) BEAST MODES --------------------------------------------------------
    bm_res = BeastModeAgent(out_sql_dir).translate(lineage, emit_res.gold_view_fqn)
    done, total = bm_res.coverage
    stages.append(_stage(4, "BeastModeAgent",
                         "PASS" if done == total else "WARN",
                         f"{done}/{total} beast modes translated"))

    # 5) REPOINT ------------------------------------------------------------
    repoint = RepointAgent(out_dir)
    plan = repoint.build_plan(lineage, emit_res)
    stages.append(_stage(5, "RepointAgent", "PASS",
                         f"{len(plan['dataset_swaps'])} swap(s) planned"))

    # 6) RECONCILE (gate) ---------------------------------------------------
    reconciler = ReconcileAgent(out_dir)
    report = reconciler.reconcile(lineage, emit_res, bm_res)
    stages.append(_stage(6, "ReconcileAgent", report["gate"],
                         f"gate={report['gate']}"))

    return {
        "schema_version": 1,
        "generated_at": _now(),
        "lineage": _lineage_meta(lineage, value_driver, value_per_year, owners),
        "stages": stages,
        "counts": {
            "input_datasets": len(lineage.inputs),
            "ir_nodes": len(ir),
            "gold_columns": len(emit_res.gold_columns),
            "beast_modes_total": total,
            "beast_modes_translated": done,
        },
        "reconciliation": {
            "gate": report["gate"],
            "checks": [{"id": c["id"], "status": c["status"]}
                       for c in report["checks"]],
        },
        "warnings": lineage.warnings,
        "sql": {
            "bronze": emit_res.bronze_sql,
            "silver": emit_res.silver_sql,
            "gold": emit_res.gold_sql,
            "gold_semantic_metrics": bm_res.sql,
        },
        "repoint_plan": plan,
        "artifacts": {
            "bronze_sql": emit_res.files["bronze"],
            "silver_sql": emit_res.files["silver"],
            "gold_sql": emit_res.files["gold"],
            "gold_semantic_metrics_sql": bm_res.file_path,
            "repoint_plan_json": repoint.plan_path,
            "reconciliation_report_json": reconciler.report_path,
        },
    }


def _now() -> str:
    return (datetime.datetime.now(datetime.timezone.utc)
            .isoformat().replace("+00:00", "Z"))


def _lineage_meta(lineage, value_driver, value_per_year, owners) -> Dict[str, Any]:
    return {
        "id": lineage.lineage_id,
        "name": lineage.name,
        "database_type": lineage.database_type,
        "value_driver": value_driver,
        "value_per_year": value_per_year,
        "owners": owners,
    }
