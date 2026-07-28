"""ParseAgent — Stage 2 of the transpiler.

AGENT ROLE
==========
The ParseAgent walks the Magic ETL `actions` DAG in topological order (resolving
`dependsOn` edges) and converts each Domo action into a normalized intermediate
representation (IR) node. The IR is deliberately engine-neutral: it captures
"what the transform does" (op, inputs, output columns, params/expression)
without committing to Spark syntax yet. That's the EmitAgent's job.

This is the classic "fan-out, one parser per node type" decomposition: a
dispatch table maps each Domo action `type` to a small, single-purpose handler.
Adding support for a new Domo action type (Rank, AddConstant, Unpivot, ...) is a
one-function change — exactly what the fleet migration (thousands of dataflows
built from a bounded set of ~30 action types) needs.
"""

from __future__ import annotations

from dataclasses import dataclass, field
from typing import Any, Callable, Dict, List, Optional

from ingest import Lineage


# --------------------------------------------------------------------------- #
# Intermediate representation
# --------------------------------------------------------------------------- #
@dataclass
class IRNode:
    """One engine-neutral transform node in the parsed DAG.

    Fields
    ------
    node_id      : the Domo action id (a1, a2, ...)
    op           : normalized op name (LOAD, FILTER, FORMULA, GROUP_BY, SELECT,
                   JOIN, PUBLISH)
    name         : human label from Domo
    inputs       : upstream IRNode ids this node consumes
    out_columns  : columns this node is known to produce/carry (best-effort;
                   LOAD/JOIN carry "*" since input schemas aren't in the export)
    params       : op-specific structured parameters (filters, aggregations,
                   join keys, selected columns, formula expressions, ...)
    medallion    : which layer this node lands in (bronze/silver/gold)
    """
    node_id: str
    op: str
    name: str
    inputs: List[str] = field(default_factory=list)
    out_columns: List[str] = field(default_factory=list)
    params: Dict[str, Any] = field(default_factory=dict)
    medallion: str = "silver"


class ParseAgent:
    """Parses Magic ETL actions into a topologically-ordered list of IRNodes."""

    def __init__(self):
        # Dispatch table: Domo action type -> handler. One parser per node type.
        self._handlers: Dict[str, Callable[[Dict[str, Any]], IRNode]] = {
            "LoadFromVault": self._parse_load,
            "Filter": self._parse_filter,
            "AddFormula": self._parse_formula,
            "GroupBy": self._parse_groupby,
            "SelectValues": self._parse_select,
            "MergeJoin": self._parse_join,
            "PublishToVault": self._parse_publish,
            # Extend the fleet here (bounded set of Domo action types):
            # "AddConstant": self._parse_add_constant,
            # "Rank": self._parse_rank,
        }

    # -- public API -------------------------------------------------------- #
    def parse(self, lineage: Lineage) -> List[IRNode]:
        if lineage.is_sql:
            # SQL DataFlows are passed through by IngestAgent with a TODO; there
            # is no action DAG to walk. Return an empty IR so downstream agents
            # can report the gap rather than crash.
            return []

        ordered = self._topo_sort(lineage.actions)
        nodes: List[IRNode] = []
        for action in ordered:
            atype = action.get("type")
            handler = self._handlers.get(atype)
            if handler is None:
                raise NotImplementedError(
                    f"No parser registered for Domo action type '{atype}' "
                    f"(action id={action.get('id')}). Add a handler to the "
                    f"ParseAgent dispatch table."
                )
            nodes.append(handler(action))
        self._assign_medallion(nodes)
        return nodes

    # -- DAG ordering ------------------------------------------------------ #
    @staticmethod
    def _topo_sort(actions: List[Dict[str, Any]]) -> List[Dict[str, Any]]:
        """Kahn's algorithm over `dependsOn` edges (deterministic)."""
        by_id = {a["id"]: a for a in actions}
        indeg = {a["id"]: 0 for a in actions}
        adj: Dict[str, List[str]] = {a["id"]: [] for a in actions}
        for a in actions:
            for dep in a.get("dependsOn", []):
                adj[dep].append(a["id"])
                indeg[a["id"]] += 1
        # Seed queue in declaration order for stable output.
        queue = [a["id"] for a in actions if indeg[a["id"]] == 0]
        ordered_ids: List[str] = []
        while queue:
            nid = queue.pop(0)
            ordered_ids.append(nid)
            for nxt in adj[nid]:
                indeg[nxt] -= 1
                if indeg[nxt] == 0:
                    queue.append(nxt)
        if len(ordered_ids) != len(actions):
            raise ValueError("Cycle detected in Magic ETL DAG (dependsOn).")
        return [by_id[i] for i in ordered_ids]

    @staticmethod
    def _assign_medallion(nodes: List[IRNode]) -> None:
        """bronze = LOAD, gold = PUBLISH + its direct producer, silver = rest."""
        for n in nodes:
            if n.op == "LOAD":
                n.medallion = "bronze"
            elif n.op == "PUBLISH":
                n.medallion = "gold"
            else:
                n.medallion = "silver"

    # -- per-type handlers (dispatch table targets) ------------------------ #
    @staticmethod
    def _parse_load(a: Dict[str, Any]) -> IRNode:
        return IRNode(
            node_id=a["id"], op="LOAD", name=a.get("name", a["id"]),
            inputs=[],
            out_columns=["*"],
            params={"dataset_id": a["dataSourceId"]},
        )

    @staticmethod
    def _parse_filter(a: Dict[str, Any]) -> IRNode:
        return IRNode(
            node_id=a["id"], op="FILTER", name=a.get("name", a["id"]),
            inputs=list(a.get("dependsOn", [])),
            out_columns=["*"],
            params={
                "filters": a.get("filters", []),
                "combination": a.get("filterCombination", "AND"),
            },
        )

    @staticmethod
    def _parse_formula(a: Dict[str, Any]) -> IRNode:
        formulas = a.get("formulas", [])
        return IRNode(
            node_id=a["id"], op="FORMULA", name=a.get("name", a["id"]),
            inputs=list(a.get("dependsOn", [])),
            # Formula carries prior columns (*) plus the new derived ones.
            out_columns=["*"] + [f["outputColumn"] for f in formulas],
            params={"formulas": formulas},
        )

    @staticmethod
    def _parse_groupby(a: Dict[str, Any]) -> IRNode:
        gcols = a.get("groupByColumns", [])
        aggs = a.get("aggregations", [])
        return IRNode(
            node_id=a["id"], op="GROUP_BY", name=a.get("name", a["id"]),
            inputs=list(a.get("dependsOn", [])),
            out_columns=gcols + [ag["outputColumn"] for ag in aggs],
            params={"group_by": gcols, "aggregations": aggs},
        )

    @staticmethod
    def _parse_select(a: Dict[str, Any]) -> IRNode:
        cols = a.get("selectedColumns", [])
        return IRNode(
            node_id=a["id"], op="SELECT", name=a.get("name", a["id"]),
            inputs=list(a.get("dependsOn", [])),
            out_columns=list(cols),
            params={"selected": cols},
        )

    @staticmethod
    def _parse_join(a: Dict[str, Any]) -> IRNode:
        return IRNode(
            node_id=a["id"], op="JOIN", name=a.get("name", a["id"]),
            inputs=list(a.get("dependsOn", [])),
            out_columns=["*"],
            params={
                "join_type": a.get("joinType", "INNER"),
                "left_keys": a.get("leftKeys", []),
                "right_keys": a.get("rightKeys", []),
            },
        )

    @staticmethod
    def _parse_publish(a: Dict[str, Any]) -> IRNode:
        return IRNode(
            node_id=a["id"], op="PUBLISH", name=a.get("name", a["id"]),
            inputs=list(a.get("dependsOn", [])),
            out_columns=["*"],
            params={
                "dataset_id": a.get("dataSourceId"),
                "dataset_name": a.get("dataSourceName"),
            },
        )
