"""Orchestration tool — recover Domo scheduling + dependency graph."""

from __future__ import annotations

from typing import Any, Dict

from ..core.domo_client import get_provider
from ..core import orchestration as orch

__all__ = ["orchestration_plan"]


def orchestration_plan() -> Dict[str, Any]:
    """Recover the Domo orchestration graph (schedules + dataflow dependencies)
    and map it to a Databricks Workflow (multi-task Job) with task dependencies.
    """
    p = get_provider()
    return orch.build_orchestration(p.list_datasets(), p.list_dataflows())
