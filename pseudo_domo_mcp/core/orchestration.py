"""orchestration — recover the Domo scheduling/dependency graph and map it to
Databricks Workflows.

A migration isn't just transforms — it's how they're *scheduled and chained*.
Domo dataflows run on triggers/schedules and form pipelines where one dataflow's
output dataset feeds another's input. We recover both from the provider:

    * schedules   — per-dataflow cadence/trigger (from `schedule` if present,
                    else the coarse `runCadence`).
    * dependencies — edge A→B when an output dataset of A is an input of B.

…and map the result to a **Databricks Workflow** (a multi-task Job with task
dependencies) + Lakeflow schedules — the target for orchestration.

Live enrichment seam: Domo exposes trigger/schedule detail on the instance
plane (`/api/dataprocessing/v1/dataflows/{id}`, `triggerSettings`) and execution
history (`/executions`); `LiveProvider` can populate a richer `schedule` there.
Derived here from API-observable shape so it works offline today.
"""

from __future__ import annotations

from typing import Any, Dict, List


def _cadence(df: Dict[str, Any]) -> str:
    sched = df.get("schedule")
    if isinstance(sched, dict):
        return sched.get("cadence") or sched.get("type") or "unknown"
    if isinstance(sched, str) and sched:
        return sched
    return df.get("runCadence") or "manual/unknown"


def build_orchestration(datasets: List[Dict[str, Any]],
                        dataflows: List[Dict[str, Any]]) -> Dict[str, Any]:
    """Return schedules + dependency edges + a Databricks Workflows mapping."""
    producer_of: Dict[str, str] = {}
    for df in dataflows:
        for out in df.get("outputDatasetIds", []):
            producer_of[out] = df["id"]

    name_of = {df["id"]: df.get("name") for df in dataflows}

    schedules = [{
        "dataflow_id": df["id"], "name": df.get("name"),
        "database_type": df.get("databaseType"),
        "cadence": _cadence(df),
    } for df in dataflows]

    edges: List[Dict[str, Any]] = []
    for df in dataflows:
        for inp in df.get("inputDatasetIds", []):
            upstream = producer_of.get(inp)
            if upstream and upstream != df["id"]:
                edges.append({
                    "from": upstream, "from_name": name_of.get(upstream),
                    "to": df["id"], "to_name": df.get("name"),
                    "via_dataset": inp,
                })

    # Chain roots (dataflows nobody feeds) vs. dependent ones.
    has_upstream = {e["to"] for e in edges}
    roots = [df["id"] for df in dataflows if df["id"] not in has_upstream]

    by_cadence: Dict[str, int] = {}
    for s in schedules:
        by_cadence[s["cadence"]] = by_cadence.get(s["cadence"], 0) + 1

    return {
        "schedules": schedules,
        "dependencies": edges,
        "roots": roots,
        "summary": {
            "dataflows": len(dataflows),
            "dependency_edges": len(edges),
            "by_cadence": by_cadence,
        },
        "databricks_mapping": {
            "target": "Databricks Workflows (multi-task Job) + Lakeflow schedules",
            "how": ("Each Domo dataflow becomes a task; the dependency edges become "
                    "task `depends_on` links, so the chain runs as one governed Job. "
                    "Domo triggers/cadence convert to the Job/Lakeflow schedule."),
            "note": ("Dependencies are derived from output→input dataset links "
                     "(API-observable). Confirm exact triggers from the Domo "
                     "instance plane before finalizing schedules."),
        },
    }
