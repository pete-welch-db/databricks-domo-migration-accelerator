"""domo_assess — classify + score each Domo object for migration triage."""

from __future__ import annotations

from typing import Any, Dict, List

from ..core.domo_client import get_provider
from ..core import classifier
from ..core import governance
from ..core import scoring
from ..core import llm

__all__ = ["domo_assess"]


def domo_assess(scope: str = "dataflows") -> Dict[str, Any]:
    """Assess the Domo estate: classify by data domain + source, score
    governance and migration complexity, and tag business value.

    Args:
        scope: "dataflows" (default) assesses each DataFlow + its card; "cards"
            assesses cards standalone; "summary" returns portfolio rollups.

    Returns per-object assessments and, for "summary", a value/complexity
    portfolio view for wave planning. Scores are transparent, rule-based, and
    human-reviewable — draft-grade triage signals, not authoritative labels.
    """
    p = get_provider()
    scope = scope.lower().strip()

    datasets = {d["id"]: d for d in p.list_datasets()}
    cards = p.list_cards()
    dataflows = p.list_dataflows()
    # Profiler/Analyzer usage context — measured when the provider exposes
    # activity + run history, else the proxy.
    usage_ctx = scoring.usage_context(
        list(datasets.values()), dataflows, cards, p.list_pages(),
        activity=p.activity_log(),
        executions_by_flow={df["id"]: p.dataflow_executions(df["id"]) for df in dataflows})

    # Beast-mode count per output dataset (via the card bound to it).
    bm_by_dataset: Dict[str, int] = {}
    for c in cards:
        for ds_id in c.get("boundDatasetIds", []):
            bm_by_dataset[ds_id] = max(bm_by_dataset.get(ds_id, 0),
                                       c.get("beastModeCount", 0))

    assessed: List[Dict[str, Any]] = []
    for df in dataflows:
        out_ids = df.get("outputDatasetIds", [])
        beast_modes = max((bm_by_dataset.get(o, 0) for o in out_ids), default=0)
        # Input dataset dicts (for source names AND governance inference).
        input_ds = [datasets[i] for i in df.get("inputDatasetIds", [])
                    if i in datasets]
        srcs = []
        for ds in input_ds:
            s = ds.get("_source_system")
            if s and s not in srcs:
                srcs.append(s)
        domain = classifier.classify_domain(df.get("name", ""),
                                             " ".join(srcs))
        cx = classifier.complexity_score(df, beast_modes)
        val = classifier.value_tag(domain)
        eff = scoring.score_effort(df, bool(df.get("_triplet_lineage_id")), cx)
        usage = scoring.score_usage({
            "asset_type": "magic_etl" if df.get("databaseType") == "MAGIC" else "sql_dataflow",
            "_output_dataset_ids": out_ids,
            "_run_cadence": df.get("runCadence"),
        }, usage_ctx)
        # INFER governance from API-observable signals (source type, writeback,
        # owner shape, cadence) — do NOT trust a pre-tagged field.
        gov = governance.infer(df, input_ds)
        # OPTIONAL: an LLM can add a plain-language rationale (falls back to the
        # raw signals when the LLM is not configured — never blocks).
        rationale = llm.explain_governance(
            df.get("name", ""), gov["signals"], gov["governance"],
            fallback="") if llm.enabled() else ""
        assessed.append({
            "dataflow_id": df["id"],
            "name": df.get("name"),
            "database_type": df.get("databaseType"),
            "data_domain": domain,
            "source_systems": srcs,
            "governance": gov["governance"],
            "governance_confidence": gov["confidence"],
            "governance_signals": gov["signals"],
            "governance_rationale": rationale,
            "complexity": cx,
            "value": val,
            "effort": eff,
            "usage": usage,
            "has_triplet": bool(df.get("_triplet_lineage_id")),
            "triplet_lineage_id": df.get("_triplet_lineage_id"),
        })

    if scope == "cards":
        # Card governance is inherited from the dataflow that produces the
        # dataset it binds to (via the assessed list above).
        gov_by_output = {}
        for df, a in zip(dataflows, assessed):
            for o in df.get("outputDatasetIds", []):
                gov_by_output[o] = a["governance"]
        card_out = []
        for c in cards:
            domain = classifier.classify_domain(
                c.get("title", ""), c.get("_value_domain", ""))
            gov = next((gov_by_output.get(o) for o in c.get("boundDatasetIds", [])
                        if o in gov_by_output), "uncertain")
            card_out.append({
                "card_id": c["id"], "title": c.get("title"),
                "data_domain": domain,
                "governance": gov,
                "beast_modes": c.get("beastModeCount", 0),
                "value": classifier.value_tag(domain),
                "note": ("Beast Modes are the #1 gotcha — folded into the "
                         "semantic layer by the transpiler, not the base gold."),
            })
        return {"cards": card_out}

    if scope == "summary":
        by_domain: Dict[str, int] = {}
        by_governance = {"governed": 0, "shadow": 0, "uncertain": 0}
        high_value_low_complexity = []
        for a in assessed:
            by_domain[a["data_domain"]] = by_domain.get(a["data_domain"], 0) + 1
            g = a["governance"]
            by_governance[g if g in by_governance else "uncertain"] += 1
            if a["value"]["band"] == "HIGH" and a["complexity"]["band"] != "HIGH":
                high_value_low_complexity.append(a["name"])
        return {
            "portfolio": {
                "by_domain": by_domain,
                "by_governance": by_governance,
                "quick_wins_high_value_manageable_complexity": high_value_low_complexity,
            },
            "note": ("Wave planning: sequence HIGH value + LOW/MEDIUM complexity "
                     "first; SQL DataFlows and writeback (shadow IT) are the "
                     "hard tail."),
        }

    return {"assessments": assessed}
