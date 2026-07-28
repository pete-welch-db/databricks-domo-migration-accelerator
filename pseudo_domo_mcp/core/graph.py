"""graph — turn a Domo lineage into a medallion-layered node/edge graph.

Powers the UI's **Analyze** stage: a data-flow visual of a Magic ETL DataFlow.
We reuse the transpiler's own IngestAgent + ParseAgent so the picture is
exactly the DAG that gets transpiled (no divergence between "what you see" and
"what gets built"). Each node is tagged with its medallion layer (bronze =
LOAD/input, silver = transforms, gold = PUBLISH) so the UI can lay it out in
left-to-right lanes.
"""

from __future__ import annotations

import os
from typing import Any, Dict, List

from ..transpiler import pipeline  # ensures the transpiler dir is on sys.path
from ingest import IngestAgent      # noqa: E402  (resolved via pipeline's sys.path)
from parse import ParseAgent        # noqa: E402


# Human-friendly labels + the medallion lane each op belongs in.
_OP_META = {
    "LOAD": ("Load", "bronze"),
    "FILTER": ("Filter", "silver"),
    "FORMULA": ("Formula", "silver"),
    "GROUP_BY": ("Group By", "silver"),
    "SELECT": ("Select", "silver"),
    "JOIN": ("Join", "silver"),
    "PUBLISH": ("Publish", "gold"),
}


def build_graph(lineage_id: str, fixtures_dir: str) -> Dict[str, Any]:
    """Return {nodes, edges, layers, meta} for a lineage's Magic ETL DAG.

    For SQL DataFlows (no action DAG) we return a single node flagged for
    human review, so the UI can still render something honest.
    """
    lineage = IngestAgent(fixtures_dir).load(lineage_id)

    meta = {
        "lineage_id": lineage.lineage_id,
        "name": lineage.name,
        "database_type": lineage.database_type,
        "output_dataset": lineage.output_dataset_name,
        "gold_columns": [c.name for c in lineage.gold_schema],
        "beast_modes": [b.name for b in lineage.card.beast_modes],
        "inputs": [{"id": i.dataset_id, "name": i.name} for i in lineage.inputs],
        "warnings": lineage.warnings,
    }

    if lineage.is_sql:
        return {
            "nodes": [{
                "id": "sql", "op": "SQL", "label": "SQL DataFlow",
                "layer": "silver", "detail": "Raw SQL — needs hand-translation",
                "review": True,
            }],
            "edges": [],
            "layers": ["bronze", "silver", "gold"],
            "meta": meta,
        }

    ir = ParseAgent().parse(lineage)
    ds_name = {i.dataset_id: i.name for i in lineage.inputs}

    nodes: List[Dict[str, Any]] = []
    edges: List[Dict[str, Any]] = []
    for n in ir:
        label, layer = _OP_META.get(n.op, (n.op.title(), "silver"))
        detail = _node_detail(n, ds_name)
        nodes.append({
            "id": n.node_id,
            "op": n.op,
            "label": label,
            "name": n.name,
            "layer": n.medallion or layer,
            "detail": detail,
            "columns": [c for c in n.out_columns if c != "*"],
        })
        for src in n.inputs:
            edges.append({"from": src, "to": n.node_id})

    return {"nodes": nodes, "edges": edges,
            "layers": ["bronze", "silver", "gold"], "meta": meta}


def _node_detail(n, ds_name: Dict[str, str]) -> str:
    """A short human description of what each IR node does."""
    p = n.params
    if n.op == "LOAD":
        return ds_name.get(p.get("dataset_id"), p.get("dataset_id", ""))
    if n.op == "FILTER":
        return f"{len(p.get('filters', []))} predicate(s), {p.get('combination','AND')}"
    if n.op == "FORMULA":
        cols = [f["outputColumn"] for f in p.get("formulas", [])]
        return "+ " + ", ".join(cols)
    if n.op == "GROUP_BY":
        aggs = [a["outputColumn"] for a in p.get("aggregations", [])]
        return f"by {', '.join(p.get('group_by', []))} → {', '.join(aggs)}"
    if n.op == "SELECT":
        return ", ".join(p.get("selected", []))
    if n.op == "JOIN":
        return f"{p.get('join_type','INNER')} on {', '.join(p.get('left_keys', []))}"
    if n.op == "PUBLISH":
        return p.get("dataset_name", "")
    return ""
