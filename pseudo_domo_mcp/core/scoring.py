"""scoring — Lakebridge-style Analyzer/Profiler signals.

Databricks Lakebridge frames a migration as **Profiler + Analyzer → Convert →
Reconcile**. Its Profiler sizes the estate (what's worth migrating) and its
Analyzer estimates migration effort/risk. This module adds the two signals the
accelerator was missing on top of the existing `classifier` complexity/value:

    * EFFORT  (Analyzer)  — how hard is this to migrate?  1-5.
    * USAGE   (Profiler)  — how used / worth migrating is it?  0-100.

Both are transparent, rule-based, human-reviewable DRAFT signals — not
authoritative. USAGE is a **proxy** today: Domo's public/instance API planes
here expose refresh cadence and dependency shape, but not an activity log, so
usage is inferred from dependent-card count + refresh cadence + scale and is
flagged `is_proxy` so the UI can say so. Wire real activity later via
`LiveProvider.activity_logs()` and swap the proxy for measured views.
"""

from __future__ import annotations

from typing import Any, Dict, List


def _band(score: int, hi: int, mid: int) -> str:
    return "HIGH" if score >= hi else "MEDIUM" if score >= mid else "LOW"


def score_effort(dataflow: Dict[str, Any], has_triplet: bool,
                 complexity: Dict[str, Any] | None = None) -> Dict[str, Any]:
    """Estimate migration EFFORT (1-5) for one dataflow.

    Anchored on the existing 0-100 `classifier.complexity_score`, then bumped for
    the things that make a transpile genuinely harder: raw SQL without an export
    triplet, and writeback (which needs an Apps + Lakebase re-platform, not just
    a pipeline). Returns effort_1_5 + band + human-readable factors.
    """
    cx = complexity or {}
    cscore = int(cx.get("score", 0))
    factors: List[str] = [f"complexity {cscore}/100"]

    effort = 1 + min(cscore // 20, 4)  # 0-19→1, 20-39→2, ... 80-100→5

    db_type = str(dataflow.get("databaseType", "MAGIC")).upper()
    if db_type == "SQL" and not has_triplet:
        effort = min(effort + 1, 5)
        factors.append("SQL DataFlow without an export triplet — hand translation")
    if dataflow.get("_has_writeback"):
        effort = min(effort + 1, 5)
        factors.append("writeback — re-platform to Apps + Lakebase")

    effort = max(1, min(effort, 5))
    return {"effort_1_5": effort, "band": _band(effort, 4, 3), "factors": factors}


def usage_context(datasets: List[Dict[str, Any]], dataflows: List[Dict[str, Any]],
                  cards: List[Dict[str, Any]], pages: List[Dict[str, Any]]) -> Dict[str, Any]:
    """Precompute the dependency + scale maps `score_usage` needs (one pass)."""
    cards_by_dataset: Dict[str, int] = {}
    for c in cards:
        for ds_id in c.get("boundDatasetIds", []):
            cards_by_dataset[ds_id] = cards_by_dataset.get(ds_id, 0) + 1
    return {
        "cards_by_dataset": cards_by_dataset,
        "cards_per_page": {p["id"]: len(p.get("cardIds", [])) for p in pages},
        "max_rows": max((int(d.get("rows") or 0) for d in datasets), default=0),
    }


# Refresh cadence → activity proxy points (frequent refresh ≈ actively used).
_CADENCE_PTS = [
    ("real", 40), ("hour", 35), ("daily", 30), ("day", 30),
    ("weekly", 20), ("week", 20), ("month", 10), ("manual", 5),
]


def score_usage(asset: Dict[str, Any], ctx: Dict[str, Any]) -> Dict[str, Any]:
    """Estimate USAGE (0-100, PROXY) for one asset.

    Signals: number of dependent cards (a dataflow's output datasets, a dataset's
    bindings, a page's cards), refresh cadence, and relative scale. Assets with
    no dependent cards surface as retire candidates. `is_proxy` is always True
    until a real activity log is wired in.
    """
    drivers: List[str] = []
    score = 0
    atype = asset.get("asset_type")

    dep = 0
    if atype in ("magic_etl", "sql_dataflow"):
        for o in asset.get("_output_dataset_ids", []):
            dep += ctx["cards_by_dataset"].get(o, 0)
    elif atype == "dataset":
        dep = ctx["cards_by_dataset"].get(asset.get("id"), 0)
    elif atype == "page":
        dep = ctx["cards_per_page"].get(asset.get("id"), 0)
    if dep:
        pts = min(dep * 12, 45)
        score += pts
        drivers.append(f"{dep} dependent card(s) (+{pts})")
    else:
        drivers.append("no dependent cards found — retire candidate")

    cadence = str(asset.get("_run_cadence") or "").lower()
    for key, pts in _CADENCE_PTS:
        if key in cadence:
            score += pts
            drivers.append(f"{cadence} refresh (+{pts})")
            break

    rows = int(asset.get("rows") or 0)
    if rows and ctx.get("max_rows"):
        pts = int(round((rows / ctx["max_rows"]) * 15))
        if pts:
            score += pts
            drivers.append(f"{rows:,} rows (+{pts})")

    score = max(0, min(score, 100))
    return {"usage_score": score, "band": _band(score, 60, 30),
            "drivers": drivers, "is_proxy": True}
