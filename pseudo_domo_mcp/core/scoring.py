"""scoring — Lakebridge-style Analyzer/Profiler signals.

Databricks Lakebridge frames a migration as **Profiler + Analyzer → Convert →
Reconcile**. Its Profiler sizes the estate (what's worth migrating) and its
Analyzer estimates migration effort/risk. This module adds the two signals the
accelerator was missing on top of the existing `classifier` complexity/value:

    * EFFORT  (Analyzer)  — how hard is this to migrate?  1-5.
    * USAGE   (Profiler)  — how used / worth migrating is it?  0-100.

Both are transparent, rule-based, human-reviewable DRAFT signals — not
authoritative. USAGE is **measured** when the provider exposes an activity log
+ run history (`provider.activity_log()` / `dataflow_executions()`): real view
counts, distinct users, and run recency/frequency (`is_proxy: False`). When
those aren't available it falls back to a **proxy** (dependent-card count +
refresh cadence + scale, `is_proxy: True`). `priority_score` then combines usage
+ value − effort − a duplicate penalty into a migration-priority score.
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
                  cards: List[Dict[str, Any]], pages: List[Dict[str, Any]],
                  activity: List[Dict[str, Any]] = None,
                  executions_by_flow: Dict[str, List[Dict[str, Any]]] = None) -> Dict[str, Any]:
    """Precompute what `score_usage` needs.

    Always builds the proxy maps (dependency + scale). When `activity` and/or
    `executions_by_flow` are supplied, also builds the MEASURED maps (per-object
    view counts + distinct users, per-flow run count / recency / last status),
    and flags `has_activity` so `score_usage` uses real signals.
    """
    import datetime
    cards_by_dataset: Dict[str, int] = {}
    for c in cards:
        for ds_id in c.get("boundDatasetIds", []):
            cards_by_dataset[ds_id] = cards_by_dataset.get(ds_id, 0) + 1

    ctx: Dict[str, Any] = {
        "cards_by_dataset": cards_by_dataset,
        "cards_per_page": {p["id"]: len(p.get("cardIds", [])) for p in pages},
        "max_rows": max((int(d.get("rows") or 0) for d in datasets), default=0),
        "has_activity": bool(activity or executions_by_flow),
    }

    now = datetime.datetime.now(datetime.timezone.utc)

    def _days_since(iso):
        try:
            t = datetime.datetime.fromisoformat(str(iso).replace("Z", "+00:00"))
            return max(0.0, (now - t).total_seconds() / 86400.0)
        except Exception:
            return None

    views: Dict[str, int] = {}
    users: Dict[str, set] = {}
    for e in (activity or []):
        oid = e.get("objectId")
        if not oid:
            continue
        views[oid] = views.get(oid, 0) + 1
        users.setdefault(oid, set()).add((e.get("actor") or {}).get("id"))
    ctx["views_by_object"] = views
    ctx["users_by_object"] = {k: len(v) for k, v in users.items()}

    runs: Dict[str, Dict[str, Any]] = {}
    for df_id, ex in (executions_by_flow or {}).items():
        days = [d for d in (_days_since(r.get("startTime")) for r in ex) if d is not None]
        runs[df_id] = {
            "count": len(ex),
            "days_since_last": min(days) if days else None,
            "last_status": (ex[0].get("status") if ex else None),
        }
    ctx["runs_by_flow"] = runs
    return ctx


# Refresh cadence → activity proxy points (frequent refresh ≈ actively used).
_CADENCE_PTS = [
    ("real", 40), ("hour", 35), ("daily", 30), ("day", 30),
    ("weekly", 20), ("week", 20), ("month", 10), ("manual", 5),
]


def _recency_pts(days):
    if days is None:
        return 0
    if days <= 7:
        return 30
    if days <= 30:
        return 20
    if days <= 90:
        return 8
    return 0


def score_usage(asset: Dict[str, Any], ctx: Dict[str, Any]) -> Dict[str, Any]:
    """Estimate USAGE (0-100). Uses MEASURED signals (views, distinct users,
    run recency/frequency) when activity/executions are available; otherwise
    falls back to the proxy (dependent cards + cadence + scale)."""
    if ctx.get("has_activity"):
        return _score_usage_real(asset, ctx)
    return _score_usage_proxy(asset, ctx)


def _score_usage_real(asset: Dict[str, Any], ctx: Dict[str, Any]) -> Dict[str, Any]:
    drivers: List[str] = []
    score = 0
    atype = asset.get("asset_type")
    views_map, users_map = ctx["views_by_object"], ctx["users_by_object"]

    if atype in ("magic_etl", "sql_dataflow"):
        outs = asset.get("_output_dataset_ids", [])
        views = sum(views_map.get(o, 0) for o in outs)
        users = max((users_map.get(o, 0) for o in outs), default=0)
        run = ctx["runs_by_flow"].get(asset.get("id"), {})
        rpts = _recency_pts(run.get("days_since_last"))
        score = min(views, 40) + min(users * 3, 20) + rpts + min(run.get("count", 0), 10)
        drivers.append(f"{views} output views / {users} users")
        if run.get("count"):
            d = run.get("days_since_last")
            drivers.append(f"{run['count']} runs, last {round(d)}d ago ({run.get('last_status')})"
                           if d is not None else f"{run['count']} runs")
        else:
            drivers.append("never run")
    else:
        oid = asset.get("id")
        views = views_map.get(oid, 0)
        users = users_map.get(oid, 0)
        score = min(views, 70) + min(users * 3, 30)
        drivers.append(f"{views} views / {users} distinct users")

    score = max(0, min(score, 100))
    return {"usage_score": score, "band": _band(score, 60, 30),
            "drivers": drivers, "is_proxy": False}


def _score_usage_proxy(asset: Dict[str, Any], ctx: Dict[str, Any]) -> Dict[str, Any]:
    """PROXY usage (no activity log): dependent cards + cadence + scale."""
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


_VALUE_PTS = {"HIGH": 30, "MEDIUM": 18, "LOW": 6}


def priority_score(asset: Dict[str, Any]) -> Dict[str, Any]:
    """Composite migration-priority (0-100): what to migrate first.

    Usage-weighted, plus business value, minus an effort drag and a heavy
    duplicate penalty (non-canonical copies score low so they fall to the
    bottom / into the retire pile). Transparent + explainable.
    """
    drivers: List[str] = []
    usage = int((asset.get("usage") or {}).get("usage_score", 0))
    value_band = (asset.get("value") or {}).get("band", "LOW")
    effort = int((asset.get("effort") or {}).get("effort_1_5", 3))
    dedup = asset.get("dedup") or {}

    score = int(usage * 0.5)                       # usage is the heaviest factor
    drivers.append(f"usage {usage}")
    score += _VALUE_PTS.get(value_band, 6)
    drivers.append(f"value {value_band}")
    score -= (effort - 1) * 3                       # higher effort = lower priority
    if dedup.get("is_duplicate"):
        score -= 40
        drivers.append("duplicate (non-canonical) — heavy penalty")

    score = max(0, min(score, 100))
    return {"score": score, "band": _band(score, 55, 25), "drivers": drivers}
