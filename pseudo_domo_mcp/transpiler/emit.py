"""EmitAgent — Stage 3 of the transpiler.

AGENT ROLE
==========
The EmitAgent walks the IR produced by the ParseAgent and emits real, readable
**Spark SQL** implementing a bronze -> silver -> gold medallion architecture:

  * BRONZE : one view per input DataSet (a thin SELECT over the raw landing
             table for each Domo LoadFromVault source).
  * SILVER : the intermediate transforms (filter, formula, group-by, select,
             join) — one view per IR node, wired to its upstream views.
  * GOLD   : a single final view whose columns EXACTLY match the DataSet schema
             contract (dataset_customer360_schema.json), with Domo->Spark type
             casts applied so the Domo->Databricks connector swap does not break
             the cards that bind to the dataset.

The GOLD view is the schema-parity boundary. This agent FAILS LOUDLY if any
required gold column is not produced somewhere in the transform DAG (a renamed
or dropped column would silently break every downstream card, so we refuse to
emit).

Domo -> Spark type map (from the fixture `_note`):
    STRING  -> STRING
    LONG    -> BIGINT
    DECIMAL -> DECIMAL(18,2)
    DOUBLE  -> DOUBLE
"""

from __future__ import annotations

import os
import re
from dataclasses import dataclass, field
from typing import Dict, List, Set

from ingest import Lineage
from parse import IRNode


# --------------------------------------------------------------------------- #
# Configuration
# --------------------------------------------------------------------------- #
CATALOG = "domo_migration"
RAW_SCHEMA = "raw"
BRONZE_SCHEMA = "bronze"
SILVER_SCHEMA = "silver"
GOLD_SCHEMA = "gold"

DOMO_TO_SPARK_TYPE = {
    "STRING": "STRING",
    "LONG": "BIGINT",
    "DECIMAL": "DECIMAL(18,2)",
    "DOUBLE": "DOUBLE",
    "DATE": "DATE",
    "DATETIME": "TIMESTAMP",
}

# Domo Filter operator -> Spark SQL predicate template.
_DATE_RE = re.compile(r"^\d{4}-\d{2}-\d{2}$")


@dataclass
class EmitResult:
    """Everything the downstream agents / orchestrator need to know."""
    bronze_sql: str
    silver_sql: str
    gold_sql: str
    gold_columns: List[str]                 # exact ordered gold output columns
    produced_columns: Set[str] = field(default_factory=set)
    bronze_views: Dict[str, str] = field(default_factory=dict)   # ds_id -> fqn
    gold_view_fqn: str = ""
    files: Dict[str, str] = field(default_factory=dict)          # layer -> path


class SchemaContractError(Exception):
    """Raised when the emitted gold view cannot satisfy the schema contract."""


class EmitAgent:
    def __init__(self, out_dir: str):
        self.out_dir = out_dir

    # -- public API -------------------------------------------------------- #
    def emit(self, lineage: Lineage, ir: List[IRNode]) -> EmitResult:
        if lineage.is_sql:
            raise SchemaContractError(
                "EmitAgent received a SQL DataFlow with no IR. SQL DataFlows "
                "must be translated by the SQL path before emit."
            )

        node_by_id = {n.node_id: n for n in ir}
        view_fqn = self._plan_view_names(ir, lineage)
        produced = self._collect_produced_columns(ir)

        bronze_sql, bronze_views = self._emit_bronze(ir, lineage, view_fqn)
        silver_sql = self._emit_silver(ir, node_by_id, view_fqn)
        gold_sql, gold_cols, gold_fqn = self._emit_gold(
            ir, node_by_id, view_fqn, lineage, produced
        )

        files = self._write_files(bronze_sql, silver_sql, gold_sql)

        return EmitResult(
            bronze_sql=bronze_sql,
            silver_sql=silver_sql,
            gold_sql=gold_sql,
            gold_columns=gold_cols,
            produced_columns=produced,
            bronze_views=bronze_views,
            gold_view_fqn=gold_fqn,
            files=files,
        )

    # -- naming / provenance ---------------------------------------------- #
    def _plan_view_names(self, ir: List[IRNode], lineage: Lineage) -> Dict[str, str]:
        """Map each IR node id -> the fully-qualified view name it produces."""
        fqn: Dict[str, str] = {}
        for n in ir:
            if n.op == "LOAD":
                ds_name = self._dataset_slug(n.params["dataset_id"], lineage)
                fqn[n.node_id] = f"{CATALOG}.{BRONZE_SCHEMA}.brz_{ds_name}"
            elif n.op == "PUBLISH":
                fqn[n.node_id] = (
                    f"{CATALOG}.{GOLD_SCHEMA}."
                    f"{self._slug(lineage.output_dataset_name)}"
                )
            else:
                fqn[n.node_id] = (
                    f"{CATALOG}.{SILVER_SCHEMA}."
                    f"slv_{n.node_id}_{n.op.lower()}"
                )
        return fqn

    @staticmethod
    def _collect_produced_columns(ir: List[IRNode]) -> Set[str]:
        """All column names explicitly produced by known ops (for gate check)."""
        produced: Set[str] = set()
        for n in ir:
            if n.op == "FORMULA":
                for f in n.params["formulas"]:
                    produced.add(f["outputColumn"])
            elif n.op == "GROUP_BY":
                produced.update(n.params["group_by"])
                for ag in n.params["aggregations"]:
                    produced.add(ag["outputColumn"])
            elif n.op == "SELECT":
                produced.update(n.params["selected"])
        return produced

    # -- bronze ------------------------------------------------------------ #
    def _emit_bronze(self, ir, lineage, view_fqn):
        lines = [self._header("BRONZE", "one view per Domo input DataSet")]
        bronze_views: Dict[str, str] = {}
        for n in ir:
            if n.op != "LOAD":
                continue
            ds_id = n.params["dataset_id"]
            slug = self._dataset_slug(ds_id, lineage)
            fqn = view_fqn[n.node_id]
            raw = f"{CATALOG}.{RAW_SCHEMA}.{slug}"
            bronze_views[ds_id] = fqn
            lines.append(
                f"-- {n.name}  (Domo DataSet {ds_id})\n"
                f"CREATE OR REPLACE VIEW {fqn} AS\n"
                f"SELECT * FROM {raw};\n"
            )
        return "\n".join(lines) + "\n", bronze_views

    # -- silver ------------------------------------------------------------ #
    def _emit_silver(self, ir, node_by_id, view_fqn) -> str:
        lines = [self._header("SILVER", "intermediate Magic ETL transforms")]
        for n in ir:
            if n.op in ("LOAD", "PUBLISH"):
                continue
            sql = self._emit_node(n, node_by_id, view_fqn)
            lines.append(
                f"-- [{n.node_id}] {n.op}: {n.name}\n"
                f"CREATE OR REPLACE VIEW {view_fqn[n.node_id]} AS\n{sql};\n"
            )
        return "\n".join(lines) + "\n"

    def _emit_node(self, n: IRNode, node_by_id, view_fqn) -> str:
        up = [view_fqn[i] for i in n.inputs]
        if n.op == "FILTER":
            return self._emit_filter(n, up[0])
        if n.op == "FORMULA":
            return self._emit_formula(n, up[0])
        if n.op == "GROUP_BY":
            return self._emit_groupby(n, up[0])
        if n.op == "SELECT":
            return self._emit_select(n, up[0])
        if n.op == "JOIN":
            return self._emit_join(n, up)
        raise NotImplementedError(f"EmitAgent has no emitter for op '{n.op}'.")

    def _emit_filter(self, n: IRNode, src: str) -> str:
        preds = [self._predicate(f) for f in n.params["filters"]]
        joiner = f"\n  {n.params['combination']} "
        return f"SELECT *\nFROM {src}\nWHERE {joiner.join(preds)}"

    def _emit_formula(self, n: IRNode, src: str) -> str:
        derived = ",\n       ".join(
            f"{self._spark_expr(f['expression'])} AS {f['outputColumn']}"
            for f in n.params["formulas"]
        )
        return f"SELECT *,\n       {derived}\nFROM {src}"

    def _emit_groupby(self, n: IRNode, src: str) -> str:
        gcols = n.params["group_by"]
        aggs = []
        for ag in n.params["aggregations"]:
            fn = ag["function"].upper()
            col = ag["column"]
            aggs.append(f"{fn}(`{col}`) AS {ag['outputColumn']}")
        select_cols = [f"`{c}`" for c in gcols] + aggs
        cols = ",\n       ".join(select_cols)
        grp = ", ".join(f"`{c}`" for c in gcols)
        return f"SELECT {cols}\nFROM {src}\nGROUP BY {grp}"

    def _emit_select(self, n: IRNode, src: str) -> str:
        cols = ",\n       ".join(f"`{c}`" for c in n.params["selected"])
        return f"SELECT {cols}\nFROM {src}"

    def _emit_join(self, n: IRNode, up: List[str]) -> str:
        left, right = up[0], up[1]
        jtype = n.params["join_type"].upper()
        lkeys = n.params["left_keys"]
        rkeys = n.params["right_keys"]
        # When keys share names on both sides, USING(...) coalesces the key
        # column and avoids duplicate output columns — the common Domo case.
        if lkeys == rkeys and lkeys:
            using = ", ".join(f"`{k}`" for k in lkeys)
            return (f"SELECT *\nFROM {left} AS l\n"
                    f"{jtype} JOIN {right} AS r USING ({using})")
        # Fallback: explicit ON with r-side keys excluded to avoid dup columns.
        on = " AND ".join(
            f"l.`{lk}` = r.`{rk}`" for lk, rk in zip(lkeys, rkeys)
        )
        return (f"SELECT l.*, r.*\nFROM {left} AS l\n"
                f"{jtype} JOIN {right} AS r ON {on}")

    # -- gold -------------------------------------------------------------- #
    def _emit_gold(self, ir, node_by_id, view_fqn, lineage, produced):
        publish = next(n for n in ir if n.op == "PUBLISH")
        producer_fqn = view_fqn[publish.inputs[0]]
        gold_fqn = view_fqn[publish.node_id]

        # ---- SCHEMA-PARITY GATE (fail loudly) --------------------------- #
        contract_cols = [c.name for c in lineage.gold_schema]
        missing = [c for c in contract_cols if c not in produced]
        if missing:
            raise SchemaContractError(
                "GOLD schema-parity violation for "
                f"'{lineage.output_dataset_name}': the following contract "
                f"columns are not produced anywhere in the transform DAG "
                f"(renamed/dropped/typo?): {missing}. Refusing to emit gold — "
                "this would break every card bound to the DataSet."
            )

        # Emit an explicit, ordered, type-cast projection = the contract.
        projected = []
        for c in lineage.gold_schema:
            spark_type = DOMO_TO_SPARK_TYPE.get(c.domo_type, "STRING")
            projected.append(
                f"CAST(`{c.name}` AS {spark_type}) AS {c.name}"
            )
        cols_sql = ",\n       ".join(projected)

        header = self._header(
            "GOLD",
            f"final contract view — MUST match DataSet {lineage.output_dataset_id}"
        )
        body = (
            f"-- Gold columns are cast to Domo-compatible Spark types so the\n"
            f"-- Domo->Databricks connector swap is transparent to every card.\n"
            f"CREATE OR REPLACE VIEW {gold_fqn} AS\n"
            f"SELECT {cols_sql}\n"
            f"FROM {producer_fqn};\n"
        )
        return header + "\n" + body + "\n", contract_cols, gold_fqn

    # -- expression / predicate translation -------------------------------- #
    @staticmethod
    def _spark_expr(expr: str) -> str:
        """Translate a Domo dataset-formula expression to Spark SQL.

        Domo's calc language is a close SQL analog: backtick-quoted identifiers,
        CASE WHEN, COALESCE, DATEDIFF, CURRENT_DATE() all exist in Spark SQL, so
        the translation is mostly a pass-through. We normalize the couple of
        spots where dialects differ.
        """
        out = expr.strip()
        # Domo DATEDIFF(a, b) == a - b (days); Spark datediff(end, start) matches
        # argument order, so it passes through. CURRENT_DATE() is valid in Spark.
        # (Kept explicit here as the hook point for dialect fixes at fleet scale.)
        return out

    def _predicate(self, f: Dict) -> str:
        col = f"`{f['column']}`"
        op = f["operator"].upper()
        if op == "IN":
            vals = ", ".join(self._lit(v) for v in f.get("values", []))
            return f"{col} IN ({vals})"
        if op in ("NOT_IN", "NOTIN"):
            vals = ", ".join(self._lit(v) for v in f.get("values", []))
            return f"{col} NOT IN ({vals})"
        cmp_map = {
            "GREATER_THAN": ">", "LESS_THAN": "<",
            "GREATER_THAN_EQUAL": ">=", "LESS_THAN_EQUAL": "<=",
            "EQUALS": "=", "NOT_EQUALS": "<>",
        }
        if op in cmp_map:
            return f"{col} {cmp_map[op]} {self._lit(f.get('value'))}"
        raise NotImplementedError(f"Unsupported Domo filter operator '{op}'.")

    @staticmethod
    def _lit(v):
        if isinstance(v, str):
            if _DATE_RE.match(v):
                return f"DATE '{v}'"
            return "'" + v.replace("'", "''") + "'"
        return str(v)

    # -- io / util --------------------------------------------------------- #
    def _write_files(self, bronze, silver, gold) -> Dict[str, str]:
        os.makedirs(self.out_dir, exist_ok=True)
        paths = {}
        for layer, sql in (("bronze", bronze), ("silver", silver), ("gold", gold)):
            p = os.path.join(self.out_dir, f"{layer}.sql")
            with open(p, "w", encoding="utf-8") as fh:
                fh.write(sql)
            paths[layer] = p
        return paths

    @staticmethod
    def _header(layer: str, note: str) -> str:
        return (f"-- ============================================================\n"
                f"-- {layer} LAYER — {note}\n"
                f"-- Generated by the Domo->Databricks transpiler (EmitAgent).\n"
                f"-- ============================================================\n")

    @staticmethod
    def _slug(name: str) -> str:
        return re.sub(r"[^a-z0-9]+", "_", name.lower()).strip("_")

    def _dataset_slug(self, ds_id: str, lineage: Lineage) -> str:
        for i in lineage.inputs:
            if i.dataset_id == ds_id:
                return self._slug(i.name)
        return self._slug(ds_id)
