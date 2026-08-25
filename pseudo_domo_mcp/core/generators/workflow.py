"""Generator: Databricks Workflow (multi-task Job) from the orchestration graph.

Turns the recovered Domo schedule + dataflow-dependency graph
(`core.orchestration.build_orchestration`) into a DAB `resources/*.job.yml`:
one task per dataflow, `depends_on` from the dependency edges, and a schedule
derived from the dominant cadence.
"""

from __future__ import annotations

import re
from typing import Any, Dict

import yaml

# Coarse Domo cadence → a quartz cron (illustrative; confirm real triggers live).
_CRON = {
    "hourly": "0 0 * * * ?", "hour": "0 0 * * * ?",
    "daily": "0 0 6 * * ?", "day": "0 0 6 * * ?",
    "weekly": "0 0 6 ? * MON", "week": "0 0 6 ? * MON",
    "monthly": "0 0 6 1 * ?", "month": "0 0 6 1 * ?",
}


def _task_key(name: str) -> str:
    return re.sub(r"[^a-zA-Z0-9_]", "_", (name or "task")).strip("_").lower()[:60] or "task"


def _schedule_from(summary: Dict[str, Any]):
    cad = max((summary.get("by_cadence") or {"manual": 1}).items(),
              key=lambda kv: kv[1])[0].lower()
    for key, cron in _CRON.items():
        if key in cad:
            return {"quartz_cron_expression": cron, "timezone_id": "UTC",
                    "pause_status": "PAUSED"}
    return None  # manual / on-submit → no schedule


def render(orchestration: Dict[str, Any], job_name: str = "domo_migration_orchestration") -> str:
    dataflows = {s["dataflow_id"]: s for s in orchestration.get("schedules", [])}
    keys = {df_id: _task_key(s["name"]) for df_id, s in dataflows.items()}
    depends = {}
    for e in orchestration.get("dependencies", []):
        depends.setdefault(e["to"], []).append(e["from"])

    tasks = []
    for df_id, s in dataflows.items():
        task = {
            "task_key": keys[df_id],
            # Placeholder run — point at the migrated pipeline for this dataflow.
            "notebook_task": {"notebook_path": f"../src/pipeline/{keys[df_id]}"},
        }
        deps = [keys[d] for d in depends.get(df_id, []) if d in keys]
        if deps:
            task["depends_on"] = [{"task_key": k} for k in deps]
        tasks.append(task)

    job: Dict[str, Any] = {"name": job_name, "tasks": tasks}
    sched = _schedule_from(orchestration.get("summary", {}))
    if sched:
        job["schedule"] = sched

    doc = {"resources": {"jobs": {job_name: job}}}
    header = ("# Databricks Workflow generated from the Domo orchestration graph.\n"
              "# One task per dataflow; depends_on from output->input dependencies.\n"
              "# Schedule is derived from Domo cadence — confirm real triggers.\n")
    return header + yaml.safe_dump(doc, sort_keys=False, allow_unicode=True)
