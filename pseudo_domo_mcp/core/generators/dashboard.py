"""Generator: AI/BI (Lakeview) dashboard `.lvdash.json`.

Builds a minimal, valid Lakeview dashboard bound to the migrated gold view — a
table of the gold columns plus a counter — as a starting point that replaces the
Domo card/page. Grounded in the transpile result's gold schema (or an explicit
view + columns for the non-transform path).
"""

from __future__ import annotations

import json
from typing import Any, Dict, List


def render(gold_view_fqn: str, columns: List[Dict[str, Any]], title: str) -> str:
    """columns: [{"name": .., "domo_type": ..}, ...]. Returns .lvdash.json text."""
    fields = [{"name": c["name"], "expression": f"`{c['name']}`"} for c in columns]

    widgets = [{
        # Row count — COUNT(*) needs no numeric column, so always include it.
        "widget": {
            "name": "row_counter",
            "queries": [{"name": "c", "query": {
                "datasetName": "gold",
                "fields": [{"name": "rows", "expression": "COUNT(*)"}],
                "disaggregated": False}}],
            "spec": {"version": 2, "widgetType": "counter",
                     "encodings": {"value": {"fieldName": "rows", "displayName": "Rows"}}},
        },
        "position": {"x": 0, "y": 0, "width": 2, "height": 1},
    }, {
        "widget": {
            "name": "gold_table",
            "queries": [{"name": "main", "query": {
                "datasetName": "gold", "fields": fields, "disaggregated": True}}],
            "spec": {"version": 1, "widgetType": "table",
                     "encodings": {"columns": [{"fieldName": c["name"]} for c in columns]}},
        },
        "position": {"x": 0, "y": 1, "width": 6, "height": 6},
    }]

    dashboard = {
        "datasets": [{
            "name": "gold",
            "displayName": gold_view_fqn,
            "queryLines": [f"SELECT * FROM {gold_view_fqn}"],
        }],
        "pages": [{
            "name": "page1",
            "displayName": title or "Migrated dashboard",
            "layout": widgets,
        }],
        "_generated_by": "pseudo-domo-migration-accelerator (scaffold — review in AI/BI)",
    }
    return json.dumps(dashboard, indent=2)
