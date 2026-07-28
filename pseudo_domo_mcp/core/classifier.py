"""classifier — assessment heuristics for the Domo estate.

Given the discovery census, score each dataflow/card by:
  * data DOMAIN     (maps to an industry-model domain: customer, aftersales,
                     quality, manufacturing, supply, logistics, finance...)
  * SOURCE system   (already enriched on datasets; propagated to dataflows)
  * GOVERNANCE      (governed IT vs. shadow/citizen-dev — the classic Domo split)
  * COMPLEXITY      (MAGIC vs SQL DataFlow, action count, beast-mode count,
                     writeback presence)
  * VALUE tag       (business-value band keyed by domain — illustrative defaults)

These are deliberately transparent, rule-based heuristics (not ML): every
score is explainable to the customer and human-reviewable. They are DRAFT-grade
signals for triage, not authoritative classifications.
"""

from __future__ import annotations

from typing import Any, Dict, List

# Keyword -> canonical data domain. First match wins; order matters.
_DOMAIN_KEYWORDS = [
    ("warranty", "aftersales"),
    ("claim", "aftersales"),
    ("service", "aftersales"),
    ("parts", "aftersales"),
    ("customer", "customer"),
    ("account", "customer"),
    ("crm", "customer"),
    ("360", "customer"),
    ("oee", "manufacturing"),
    ("plant", "manufacturing"),
    ("production", "manufacturing"),
    ("mes", "manufacturing"),
    ("supplier", "supply"),
    ("procure", "supply"),
    ("quality", "quality"),
    ("defect", "quality"),
    ("scorecard", "quality"),
    ("capex", "finance"),
    ("finance", "finance"),
    ("cost", "finance"),
    ("logistics", "logistics"),
    ("lane", "logistics"),
    ("freight", "logistics"),
    ("shipment", "logistics"),
]

# Value bands ($/yr) keyed by domain — illustrative defaults for a
# manufacturing/enterprise estate. Directional placeholders; override with the
# customer's own value model. Edit freely, they carry no proprietary data.
_VALUE_BY_DOMAIN = {
    "customer": {"value_per_year": "$200K", "driver": "Customer 360", "band": "HIGH"},
    "aftersales": {"value_per_year": "$180K", "driver": "Aftermarket Ops", "band": "HIGH"},
    "quality": {"value_per_year": "$150K", "driver": "Quality / 8D", "band": "HIGH"},
    "manufacturing": {"value_per_year": "$140K", "driver": "Plant OEE", "band": "MEDIUM"},
    "supply": {"value_per_year": "$120K", "driver": "Supplier Quality", "band": "MEDIUM"},
    "logistics": {"value_per_year": "$90K", "driver": "Inbound Logistics", "band": "MEDIUM"},
    "finance": {"value_per_year": "$60K", "driver": "CapEx Governance", "band": "LOW"},
    "unknown": {"value_per_year": "$0", "driver": "Unclassified", "band": "LOW"},
}


def classify_domain(name: str, hint: str = "") -> str:
    text = f"{name} {hint}".lower()
    for kw, domain in _DOMAIN_KEYWORDS:
        if kw in text:
            return domain
    return "unknown"


def value_tag(domain: str) -> Dict[str, str]:
    return _VALUE_BY_DOMAIN.get(domain, _VALUE_BY_DOMAIN["unknown"])


def complexity_score(dataflow: Dict[str, Any], card_beast_modes: int = 0) -> Dict[str, Any]:
    """Return a 0-100 complexity score + drivers for one dataflow.

    Higher = harder to migrate. SQL DataFlows and writeback are the big
    multipliers (SQL body must be hand-translated; writeback needs Lakebase +
    a Databricks App, not just a pipeline).
    """
    drivers: List[str] = []
    score = 0

    db_type = str(dataflow.get("databaseType", "MAGIC")).upper()
    if db_type == "SQL":
        score += 40
        drivers.append("SQL DataFlow — raw SQL must be hand-translated to Spark SQL")
    else:
        drivers.append("Magic ETL — deterministic DAG transpile")

    actions = int(dataflow.get("actionCount", 0))
    action_pts = min(actions * 2, 30)
    score += action_pts
    if actions:
        drivers.append(f"{actions} Magic ETL actions (+{action_pts})")

    inputs = len(dataflow.get("inputDatasetIds", []))
    if inputs > 1:
        score += min((inputs - 1) * 5, 15)
        drivers.append(f"{inputs} input datasets to join/reconcile")

    if card_beast_modes:
        bm_pts = min(card_beast_modes * 3, 20)
        score += bm_pts
        drivers.append(f"{card_beast_modes} card Beast Modes to fold into semantics (+{bm_pts})")

    if dataflow.get("_has_writeback"):
        score += 25
        drivers.append("WRITEBACK — needs Lakebase + Databricks App (not just a pipeline)")

    score = min(score, 100)
    band = "HIGH" if score >= 60 else "MEDIUM" if score >= 30 else "LOW"
    return {"score": score, "band": band, "drivers": drivers}


def governance_of(obj: Dict[str, Any]) -> str:
    return obj.get("_governance", "unknown")
