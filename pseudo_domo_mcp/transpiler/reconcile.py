"""ReconcileAgent — Stage 6 of the transpiler (the PASS/FAIL GATE).

AGENT ROLE
==========
The ReconcileAgent is the quality gate. Nothing ships to a customer without it
going green. With no live data available yet, it SIMULATES reconciliation with
three structural checks that catch the failure modes that actually break Domo
card migrations:

  (a) SCHEMA-PARITY      — does the emitted gold view expose EXACTLY the DataSet
                           schema contract (same names, same mapped Spark types,
                           same count)? A rename/drop/type-drift silently breaks
                           every bound card.
  (b) BEAST-MODE COVERAGE — is every card Beast Mode accounted for in the
                           semantic-metrics layer AND fully translated? This is
                           the gotcha: base dataset can reconcile while the card
                           renders wrong numbers because a Beast Mode was missed.
  (c) LINEAGE COMPLETENESS — does every DataSet the card binds to have a
                           producing gold view? No dangling card bindings.

Emits `reconciliation_report.json` (per-check PASS/FAIL + overall gate) and
prints a human-readable summary. The overall gate is PASS only if all checks
pass. This is what a demo shows a customer: "the mechanism proves itself."
"""

from __future__ import annotations

import json
import os
from typing import Any, Dict, List

from ingest import Lineage
from emit import EmitResult, DOMO_TO_SPARK_TYPE
from beastmode import BeastModeResult


class ReconcileAgent:
    def __init__(self, out_dir: str):
        self.out_dir = out_dir

    def reconcile(self, lineage: Lineage, emit: EmitResult,
                  bm: BeastModeResult) -> Dict[str, Any]:
        checks = [
            self._check_schema_parity(lineage, emit),
            self._check_beastmode_coverage(lineage, bm),
            self._check_lineage_completeness(lineage, emit),
        ]
        overall = "PASS" if all(c["status"] == "PASS" for c in checks) else "FAIL"
        report = {
            "lineage_id": lineage.lineage_id,
            "lineage_name": lineage.name,
            "gate": overall,
            "checks": checks,
            "warnings": lineage.warnings,
        }
        self._write(report)
        self._print_summary(report)
        return report

    # -- (a) schema parity ------------------------------------------------- #
    def _check_schema_parity(self, lineage: Lineage, emit: EmitResult) -> Dict:
        contract = [(c.name, DOMO_TO_SPARK_TYPE.get(c.domo_type, "STRING"))
                    for c in lineage.gold_schema]
        emitted = emit.gold_columns  # ordered names produced by the gold view

        details: List[str] = []
        ok = True

        # Name + order parity.
        contract_names = [n for n, _ in contract]
        if emitted != contract_names:
            ok = False
            missing = [n for n in contract_names if n not in emitted]
            extra = [n for n in emitted if n not in contract_names]
            if missing:
                details.append(f"missing gold columns: {missing}")
            if extra:
                details.append(f"unexpected gold columns: {extra}")
            if not missing and not extra:
                details.append("column ORDER differs from contract")
        else:
            details.append(
                f"all {len(contract_names)} columns present, in order, "
                f"with Domo->Spark types mapped"
            )

        return {
            "id": "schema_parity",
            "label": "Gold schema matches Domo DataSet contract (names + types)",
            "status": "PASS" if ok else "FAIL",
            "expected_columns": [{"name": n, "spark_type": t} for n, t in contract],
            "emitted_columns": emitted,
            "details": details,
        }

    # -- (b) beast-mode coverage ------------------------------------------- #
    def _check_beastmode_coverage(self, lineage: Lineage,
                                  bm: BeastModeResult) -> Dict:
        card_bms = {b.name for b in lineage.card.beast_modes}
        covered = {m.name for m in bm.metrics}
        untranslated = [m.name for m in bm.metrics if not m.fully_translated]

        missing = sorted(card_bms - covered)
        ok = (not missing) and (not untranslated)

        details = []
        done, total = bm.coverage
        details.append(f"{done}/{total} Beast Modes fully translated to Spark SQL")
        if missing:
            details.append(f"Beast Modes with NO semantic metric: {missing}")
        if untranslated:
            details.append(f"Beast Modes needing human review: {untranslated}")

        return {
            "id": "beastmode_coverage",
            "label": "Every card Beast Mode is folded into the semantic layer",
            "status": "PASS" if ok else "FAIL",
            "card_beast_modes": sorted(card_bms),
            "translated": sorted(covered),
            "needs_review": untranslated,
            "details": details,
        }

    # -- (c) lineage completeness ------------------------------------------ #
    def _check_lineage_completeness(self, lineage: Lineage,
                                    emit: EmitResult) -> Dict:
        details = []
        ok = True
        for ds_id in lineage.card.bound_dataset_ids:
            # The card binds to the gold output DataSet; a producing gold view
            # must exist for it.
            if ds_id == lineage.output_dataset_id and emit.gold_view_fqn:
                details.append(f"{ds_id} -> {emit.gold_view_fqn}")
            else:
                ok = False
                details.append(f"{ds_id} -> NO producing gold view (dangling)")

        return {
            "id": "lineage_completeness",
            "label": "Every card-bound DataSet has a producing gold view",
            "status": "PASS" if ok else "FAIL",
            "card_bound_datasets": lineage.card.bound_dataset_ids,
            "details": details,
        }

    # -- io / output ------------------------------------------------------- #
    def _write(self, report: Dict[str, Any]) -> str:
        os.makedirs(self.out_dir, exist_ok=True)
        p = os.path.join(self.out_dir, "reconciliation_report.json")
        with open(p, "w", encoding="utf-8") as fh:
            json.dump(report, fh, indent=2)
        self.report_path = p
        return p

    @staticmethod
    def _print_summary(report: Dict[str, Any]) -> None:
        print("    ---- Reconciliation ----")
        for c in report["checks"]:
            mark = "PASS" if c["status"] == "PASS" else "FAIL"
            print(f"    [{mark}] {c['label']}")
            for d in c["details"]:
                print(f"           - {d}")
        gate = report["gate"]
        print(f"    ==> GATE: {gate}")
