"""industry_model — load + index the Databricks Industry Data Models.

Source of truth = the vendored MVM Spark DDL under models/<industry>/*.sql
(sliced from databricks-industry-solutions/lakehouse-industry-data-models).
We parse the DDL into an in-memory index of domain -> table -> columns, where
each column carries name, spark_type, a human comment, and any enumerated
"Valid values are `a|b|c`" hint. That index is what `industry_model_map` uses
to draft-map Domo columns onto the canonical model.

We parse the DDL (not model.json) because the DDL is the deployable artifact
and carries the rich column comments + valid-value constraints that make
comment/name similarity matching meaningful.
"""

from __future__ import annotations

import os
import re
from dataclasses import dataclass, field
from functools import lru_cache
from typing import Dict, List, Optional

_MODELS_ROOT = os.path.join(
    os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__)))),
    "models",
)

# `CREATE OR REPLACE TABLE `cat`.`domain`.`table` (`
_TABLE_RE = re.compile(
    r"CREATE\s+(?:OR\s+REPLACE\s+)?TABLE\s+`([^`]+)`\.`([^`]+)`\.`([^`]+)`\s*\(",
    re.IGNORECASE,
)
# `  `col_name` TYPE COMMENT '...'`  (type may be DECIMAL(18,2))
_COL_RE = re.compile(
    r"^\s*`([a-z0-9_]+)`\s+([A-Za-z]+(?:\([0-9, ]+\))?)"
    r"(?:\s+COMMENT\s+'(.*?)')?\s*,?\s*$"
)
_VALID_VALUES_RE = re.compile(r"Valid values are\s+`([^`]+)`")


@dataclass
class ModelColumn:
    name: str
    spark_type: str
    comment: str = ""
    valid_values: List[str] = field(default_factory=list)


@dataclass
class ModelTable:
    domain: str
    table: str
    catalog: str
    columns: List[ModelColumn] = field(default_factory=list)

    @property
    def fqn(self) -> str:
        return f"{self.domain}.{self.table}"


@dataclass
class IndustryModel:
    industry: str
    tables: List[ModelTable] = field(default_factory=list)

    @property
    def domains(self) -> List[str]:
        seen: List[str] = []
        for t in self.tables:
            if t.domain not in seen:
                seen.append(t.domain)
        return seen

    def table_by_fqn(self, fqn: str) -> Optional[ModelTable]:
        return next((t for t in self.tables if t.fqn == fqn), None)


def available_industries() -> List[str]:
    if not os.path.isdir(_MODELS_ROOT):
        return []
    return sorted(
        d for d in os.listdir(_MODELS_ROOT)
        if os.path.isdir(os.path.join(_MODELS_ROOT, d))
    )


@lru_cache(maxsize=8)
def load_model(industry: str) -> IndustryModel:
    """Parse every domain DDL file for an industry into an IndustryModel."""
    industry_dir = os.path.join(_MODELS_ROOT, industry)
    if not os.path.isdir(industry_dir):
        raise ValueError(
            f"Unknown industry '{industry}'. Available: {available_industries()}"
        )
    model = IndustryModel(industry=industry)
    for fname in sorted(os.listdir(industry_dir)):
        if not fname.endswith(".sql"):
            continue
        with open(os.path.join(industry_dir, fname), "r", encoding="utf-8") as fh:
            model.tables.extend(_parse_ddl(fh.read()))
    return model


def _parse_ddl(sql: str) -> List[ModelTable]:
    """Parse one DDL file into its list of ModelTables.

    Walks line by line: a CREATE TABLE opens a table; subsequent column lines
    are attached until the closing `)` / `;` or the next CREATE.
    """
    tables: List[ModelTable] = []
    current: Optional[ModelTable] = None
    for raw in sql.splitlines():
        m = _TABLE_RE.search(raw)
        if m:
            catalog, domain, table = m.group(1), m.group(2), m.group(3)
            current = ModelTable(domain=domain, table=table, catalog=catalog)
            tables.append(current)
            continue
        if current is None:
            continue
        stripped = raw.strip()
        if stripped.startswith(")") or stripped.startswith(";"):
            current = None
            continue
        cm = _COL_RE.match(raw)
        if cm:
            comment = cm.group(3) or ""
            vv = _VALID_VALUES_RE.search(comment)
            current.columns.append(ModelColumn(
                name=cm.group(1),
                spark_type=cm.group(2).upper(),
                comment=comment,
                valid_values=vv.group(1).split("|") if vv else [],
            ))
    return tables
