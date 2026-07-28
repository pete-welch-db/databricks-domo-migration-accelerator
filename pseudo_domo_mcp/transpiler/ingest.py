"""IngestAgent — Stage 1 of the Domo->Databricks migration transpiler.

AGENT ROLE
==========
The IngestAgent is the "front door." It knows nothing about Spark and nothing
about how transforms are shaped. Its single responsibility is to load the
*triplet* that defines one migratable unit of work (a "lineage") and normalize
it into a stable internal contract (the `Lineage` dataclass) that every
downstream agent can rely on.

A single Domo Card cannot be migrated from the Magic ETL DataFlow alone. Three
artifacts are always required:

  1. DataFlow JSON      -- the transform DAG (Magic ETL) OR raw SQL (SQL DataFlow)
  2. DataSet schema     -- the gold output contract the card binds to
  3. Card + Beast Modes -- card-level calculated fields (Domo's SQL-analog calc
                           language) that DO NOT live in the DataFlow

This agent handles BOTH `databaseType == "MAGIC"` and `databaseType == "SQL"`.
For SQL DataFlows we do not attempt to parse the SQL here; we capture the raw
SQL string plus the declared inputs/output and flag it with a TODO marker so a
human (or a future SQL-parsing agent) can finish the translation. This mirrors
reality: a large Domo estate's thousands of "ETLs" are a mix of Magic ETL and
SQL DataFlows, and the fleet transpiler cannot assume Magic-only.
"""

from __future__ import annotations

import json
import os
from dataclasses import dataclass, field
from typing import Any, Dict, List, Optional


# --------------------------------------------------------------------------- #
# Normalized internal contract
# --------------------------------------------------------------------------- #
@dataclass
class InputDataSet:
    """A Domo DataSet that feeds the DataFlow (an INPUT / LoadFromVault source)."""
    dataset_id: str
    name: str
    execute_when_updated: bool = False


@dataclass
class SchemaColumn:
    """One column of the gold output DataSet schema contract."""
    name: str
    domo_type: str
    visible: bool = True


@dataclass
class BeastMode:
    """A card-level calculated field (Domo's SQL-analog, NOT DAX)."""
    name: str
    expression: str
    fmt: Dict[str, Any] = field(default_factory=dict)


@dataclass
class Card:
    """A dashboard tile bound to the gold DataSet."""
    card_id: str
    title: str
    card_type: str
    page_id: str
    bound_dataset_ids: List[str] = field(default_factory=list)
    beast_modes: List[BeastMode] = field(default_factory=list)
    filters: List[Dict[str, Any]] = field(default_factory=list)
    series: List[Dict[str, Any]] = field(default_factory=list)


@dataclass
class Lineage:
    """The fully-normalized, transform-engine-agnostic migration unit.

    This is the single object handed from IngestAgent to every downstream agent.
    """
    lineage_id: str
    name: str
    description: str
    database_type: str                      # "MAGIC" | "SQL"
    inputs: List[InputDataSet]
    actions: List[Dict[str, Any]]           # raw Magic ETL actions (empty for SQL)
    raw_sql: Optional[str]                   # raw SQL text (None for MAGIC)
    output_dataset_id: str
    output_dataset_name: str
    gold_schema: List[SchemaColumn]
    card: Card
    warnings: List[str] = field(default_factory=list)

    @property
    def is_sql(self) -> bool:
        return self.database_type.upper() == "SQL"


class IngestAgent:
    """Loads + normalizes one lineage triplet from JSON fixtures."""

    def __init__(self, fixtures_dir: str):
        self.fixtures_dir = fixtures_dir

    # -- public API -------------------------------------------------------- #
    def load(self, lineage: str = "customer360") -> Lineage:
        """Load the triplet for a given lineage id (e.g. 'customer360')."""
        dataflow = self._read_json(f"dataflow_{lineage}_magic_etl.json",
                                   optional=True)
        sql_dataflow = self._read_json(f"dataflow_{lineage}_sql.json",
                                       optional=True)
        schema_doc = self._read_json(f"dataset_{lineage}_schema.json")
        card_doc = self._read_json(f"card_{lineage}_beastmodes.json")

        if dataflow is None and sql_dataflow is None:
            raise FileNotFoundError(
                f"No DataFlow fixture found for lineage '{lineage}' "
                f"(looked for MAGIC and SQL variants)."
            )

        # Prefer the Magic ETL variant when present; SQL variant is the fallback.
        flow = dataflow if dataflow is not None else sql_dataflow
        return self._normalize(flow, schema_doc, card_doc)

    # -- internals --------------------------------------------------------- #
    def _read_json(self, filename: str, optional: bool = False):
        path = os.path.join(self.fixtures_dir, filename)
        if not os.path.exists(path):
            if optional:
                return None
            raise FileNotFoundError(f"Required fixture missing: {path}")
        with open(path, "r", encoding="utf-8") as fh:
            text = fh.read()
        # Tolerate trailing non-JSON (e.g. a stray export tag): decode only the
        # leading JSON value and ignore anything after it. Keeps us robust to
        # imperfect real-world Domo exports without mutating the source file.
        obj, _end = json.JSONDecoder().raw_decode(text.lstrip())
        return obj

    def _normalize(self, flow: Dict[str, Any],
                   schema_doc: Dict[str, Any],
                   card_doc: Dict[str, Any]) -> Lineage:
        warnings: List[str] = []
        db_type = str(flow.get("databaseType", "MAGIC")).upper()

        inputs = [
            InputDataSet(
                dataset_id=i["dataSourceId"],
                name=i.get("dataSourceName", i["dataSourceId"]),
                execute_when_updated=bool(i.get("executeFlowWhenUpdated", False)),
            )
            for i in flow.get("inputs", [])
        ]

        actions = flow.get("actions", []) or []
        raw_sql = None

        if db_type == "SQL":
            # We do NOT parse the SQL here. Capture it verbatim and flag it.
            raw_sql = flow.get("sql") or flow.get("query")
            warnings.append(
                "TODO(SQL DataFlow): raw SQL captured but not parsed into IR. "
                "A dedicated SQL-parsing agent (or human) must translate the "
                "MySQL/Redshift-dialect SQL to Spark SQL and validate the gold "
                "schema against the DataSet contract."
            )
            if not raw_sql:
                warnings.append(
                    "SQL DataFlow declared but no 'sql'/'query' field present."
                )

        # Output DataSet = PublishToVault target (Magic) or schema doc id (SQL).
        publish = next(
            (a for a in actions if a.get("type") == "PublishToVault"), None
        )
        out_id = (publish or {}).get("dataSourceId") or schema_doc["id"]
        out_name = (publish or {}).get("dataSourceName") or schema_doc["name"]

        gold_schema = [
            SchemaColumn(name=c["name"], domo_type=c["type"],
                         visible=c.get("visible", True))
            for c in schema_doc["schema"]["columns"]
        ]

        card = Card(
            card_id=card_doc["id"],
            title=card_doc.get("title", card_doc["id"]),
            card_type=card_doc.get("type", "unknown"),
            page_id=card_doc.get("pageId", ""),
            bound_dataset_ids=[d["dataSourceId"]
                               for d in card_doc.get("datasources", [])],
            beast_modes=[
                BeastMode(name=b["name"], expression=b["expression"],
                          fmt=b.get("format", {}))
                for b in card_doc.get("beastModes", [])
            ],
            filters=card_doc.get("filters", []),
            series=card_doc.get("series", []),
        )

        return Lineage(
            lineage_id=flow["id"],
            name=flow.get("name", flow["id"]),
            description=flow.get("description", ""),
            database_type=db_type,
            inputs=inputs,
            actions=actions,
            raw_sql=raw_sql,
            output_dataset_id=out_id,
            output_dataset_name=out_name,
            gold_schema=gold_schema,
            card=card,
            warnings=warnings,
        )
