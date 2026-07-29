"""RepointAgent — Stage 5 of the transpiler.

AGENT ROLE
==========
This is the "cards keep working, swap the source" step — NOT a dashboard rebuild.
Once the gold view exists in Databricks with a schema-parity-matched contract,
each Domo Card that binds to the old Domo DataSet can be repointed at the new
Databricks-backed DataSet (via a Databricks connector) with zero card edits.

The RepointAgent produces a connector-swap PLAN as JSON:
  * for each Domo DataSet a card binds to -> the target Databricks gold
    table/view, a column-by-column mapping, and the connector type;
  * the Domo API call shapes we WOULD make to swap the DataSet's source
    (documented as a DRY RUN, for when there is no live Domo tenant yet).

Nothing here executes against a live tenant. It is a reviewable artifact that a
human (or an execution agent, once credentials land) can act on.
"""

from __future__ import annotations

import json
import os
from typing import Any, Dict, List

from ingest import Lineage
from emit import EmitResult, DOMO_TO_SPARK_TYPE


class RepointAgent:
    def __init__(self, out_dir: str):
        self.out_dir = out_dir

    def build_plan(self, lineage: Lineage, emit: EmitResult) -> Dict[str, Any]:
        col_map = [
            {
                "domo_column": c.name,
                "domo_type": c.domo_type,
                "databricks_column": c.name,          # 1:1, gate-enforced
                "databricks_type": DOMO_TO_SPARK_TYPE.get(c.domo_type, "STRING"),
            }
            for c in lineage.gold_schema
        ]

        # A card can bind to >1 DataSet; here it binds to the gold output.
        swaps: List[Dict[str, Any]] = []
        for ds_id in lineage.card.bound_dataset_ids:
            swaps.append({
                "domo_dataset_id": ds_id,
                "domo_dataset_name": lineage.output_dataset_name,
                "target_databricks_view": emit.gold_view_fqn,
                "connector_type": "databricks-connector-v2",
                "swap_strategy": (
                    "In-place source swap: keep the Domo DataSet id stable so "
                    "every card/page binding is preserved; replace its backing "
                    "connection with the Databricks connector pointed at the "
                    "gold view. No card is edited or rebuilt."
                ),
                "column_mapping": col_map,
                "dry_run_api_calls": self._api_call_shapes(ds_id, emit.gold_view_fqn),
            })

        plan = {
            "lineage_id": lineage.lineage_id,
            "lineage_name": lineage.name,
            "output_dataset_id": lineage.output_dataset_id,
            "gold_view": emit.gold_view_fqn,
            "cards_preserved": [{
                "card_id": lineage.card.card_id,
                "title": lineage.card.title,
                "page_id": lineage.card.page_id,
            }],
            "dataset_swaps": swaps,
            "dry_run": True,
            "note": (
                "DRY RUN — no live Domo tenant. API shapes below are what the "
                "execution step WOULD send once credentials are provisioned."
            ),
        }
        self._write(plan)
        return plan

    def _api_call_shapes(self, ds_id: str, gold_view: str) -> List[Dict[str, Any]]:
        """Illustrative Domo API request shapes for the source swap (DRY RUN).

        NOTE: connection/DataSource management lives on Domo's INSTANCE plane
        (https://{instance}.domo.com/api/..., X-DOMO-Developer-Token), not the
        public api.domo.com OAuth API, and the exact connector-swap contract is
        not publicly documented. These shapes are directional — validate against
        the tenant's actual endpoints before executing.
        """
        return [
            {
                "step": "1. Register Databricks connection",
                "method": "POST",
                "path": "/api/data/v1/connections",
                "body": {
                    "type": "databricks",
                    "name": "databricks-uc",
                    "properties": {
                        "host": "<workspace>.cloud.databricks.com",
                        "httpPath": "/sql/1.0/warehouses/<warehouse_id>",
                        "authType": "oauth-m2m",
                        "catalog": gold_view.split(".")[0],
                    },
                },
            },
            {
                "step": "2. Repoint the existing DataSet's source (in place)",
                "method": "PUT",
                "path": f"/api/data/v3/datasources/{ds_id}",
                "body": {
                    "dataSourceId": ds_id,
                    "transport": {"type": "connector"},
                    "connector": {
                        "type": "databricks-connector-v2",
                        "query": f"SELECT * FROM {gold_view}",
                    },
                    "advancedScheduleJson": {"triggerType": "MANUAL"},
                },
                "note": (
                    "Keeps dataSourceId stable so all card bindings survive; "
                    "only the backing transport/connector changes."
                ),
            },
            {
                "step": "3. Trigger a validation index/refresh",
                "method": "POST",
                "path": f"/api/data/v1/streams/{ds_id}/executions",
                "body": {"reason": "post-migration connector-swap validation"},
            },
        ]

    def _write(self, plan: Dict[str, Any]) -> str:
        os.makedirs(self.out_dir, exist_ok=True)
        p = os.path.join(self.out_dir, "repoint_plan.json")
        with open(p, "w", encoding="utf-8") as fh:
            json.dump(plan, fh, indent=2)
        self.plan_path = p
        return p
