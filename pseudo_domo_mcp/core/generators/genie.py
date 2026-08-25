"""Generator: Genie space definition (YAML).

Produces a Genie space grounded on the migrated gold view + any metric views,
with instructions and example questions derived from the gold columns. Follows
the Genie space shape (sorted table identifiers, instructions, sample questions)
so it's a ready starting point to create the space.
"""

from __future__ import annotations

from typing import Any, Dict, List

import yaml


def render(gold_view_fqn: str, columns: List[Dict[str, Any]], title: str,
           metric_view_fqns: List[str] | None = None) -> str:
    col_names = [c["name"] for c in columns]
    tables = sorted({gold_view_fqn, *(metric_view_fqns or [])})

    sample = [f"What is the total number of rows in {title}?"]
    if col_names:
        sample.append(f"Break down {title} by {col_names[0]}.")
    if len(col_names) > 1:
        sample.append(f"Show {col_names[1]} over time." if any(
            "date" in c.lower() or "ts" in c.lower() for c in col_names)
            else f"Which {col_names[0]} has the highest {col_names[-1]}?")

    space = {
        "display_name": f"{title} — Genie",
        "description": f"Ask questions in natural language about {title}, "
                       f"migrated from Domo to governed Databricks gold.",
        "warehouse_id": "<set-your-sql-warehouse-id>",
        "table_identifiers": tables,
        "instructions": (
            f"This space answers questions about {title}. Data lives in "
            f"{gold_view_fqn}" + (f" with governed metrics in {', '.join(metric_view_fqns)}"
                                  if metric_view_fqns else "") + ". "
            "Use the metric views for any KPI so numbers match the dashboards."
        ),
        "sample_questions": sample,
        "_generated_by": "pseudo-domo-migration-accelerator (scaffold — review before create)",
    }
    return yaml.safe_dump(space, sort_keys=False, allow_unicode=True)
