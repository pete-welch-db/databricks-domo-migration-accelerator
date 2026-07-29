"""FastAPI operator UI over the Pseudo-Domo MCP core.

Every endpoint wraps the SAME core functions the MCP tools call — the UI and
the MCP are two front-ends over one engine. The four workflow stages map to:

    browse    GET  /api/estate            -> discovery + assessment
    Analyze   GET  /api/analyze/{lid}     -> core.graph.build_graph (DAG visual)
    Draft     GET  /api/draft/{lid}       -> transpiler pipeline.run (SDP SQL)
    Create    POST /api/create/{lid}      -> core.bundle.write_bundle (+deploy)

    config    GET/POST /api/config        -> catalog/schema/profile/domo
    map       GET  /api/map/{dataset_id}  -> industry_model_map
    feasibility GET /api/feasibility      -> lakeflow_feasibility
    plan      GET  /api/plan              -> migration_plan
"""

from __future__ import annotations

import os
import tempfile
from typing import Any, Dict, Optional

from fastapi import FastAPI, Body
from fastapi.responses import FileResponse, JSONResponse
from fastapi.staticfiles import StaticFiles

from ..core.domo_client import get_provider
from ..core import config as cfgmod
from ..core import gitlink
from ..core import sdp
from ..core import store
from ..core import patterns
from ..core import model_catalog
from ..core import llm
from ..core.graph import build_graph
from ..core.bundle import write_bundle
from ..transpiler import pipeline
from ..tools import discovery, assessment, mapping, feasibility, plan as planmod

app = FastAPI(title="Pseudo-Domo Migration Console")

_STATIC = os.path.join(os.path.dirname(os.path.abspath(__file__)), "static")
# Persist generated bundles under the repo so the customer can find them.
_REPO_ROOT = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
_BUNDLE_ROOT = os.path.join(_REPO_ROOT, "generated")


@app.get("/")
def index():
    return FileResponse(os.path.join(_STATIC, "index.html"))


@app.get("/api/estate")
def estate() -> Dict[str, Any]:
    """The migration estate: census summary + per-dataflow assessment, joined
    so each row carries value/complexity/governance for the browse list."""
    summary = discovery.domo_discover("summary")
    assessed = assessment.domo_assess("dataflows")["assessments"]
    cards = {c["id"]: c for c in discovery.domo_discover("cards")["cards"]}
    return {"summary": summary, "dataflows": assessed, "cards": list(cards.values())}


@app.get("/api/inventory")
def inventory(asset_type: str = "", search: str = "") -> Dict[str, Any]:
    """Typed, searchable asset inventory (connectors, magic_etl, sql_dataflow,
    dataset, card, beast_mode, page). Powers the Discover step's browse/search/
    filter and the connector remap plan. Records the scan to the state store."""
    inv = discovery.domo_inventory(asset_type=asset_type, search=search)
    if not asset_type and not search:  # a full scan — record it
        try:
            import datetime
            store.get_store().append("scans", {
                "at": datetime.datetime.now(datetime.timezone.utc).isoformat(),
                "counts_by_type": inv["counts_by_type"]})
        except Exception:
            pass  # persistence must never block discovery
    return inv


@app.get("/api/history")
def history() -> Dict[str, Any]:
    """Persisted scan history + bundle registry (from the configured store)."""
    s = store.get_store()
    return {"backend": s.backend(), "scans": s.list("scans"),
            "bundles": s.list("bundles")}


@app.get("/api/analyze/{lineage_id}")
def analyze(lineage_id: str) -> Dict[str, Any]:
    """Analyze/preview: the Magic ETL DAG as a medallion-layered graph."""
    p = get_provider()
    tdir = p.triplet_dir(lineage_id)
    if tdir is None:
        return JSONResponse(
            {"error": f"No full triplet for '{lineage_id}'. Magic ETL internals "
                      "come from the Domo instance API (dataprocessing); set "
                      "DOMO_INSTANCE + DOMO_DEVELOPER_TOKEN, or use fixtures."},
            status_code=404)
    return build_graph(lineage_id, tdir)


@app.get("/api/draft/{lineage_id}")
def draft(lineage_id: str, language: str = "") -> Dict[str, Any]:
    """Draft: run the transpiler, return real SDP (Lakeflow Declarative Pipeline)
    code in the chosen language + the reconcile gate (no deploy)."""
    p = get_provider()
    tdir = p.triplet_dir(lineage_id)
    if tdir is None:
        return JSONResponse({"error": f"No triplet for '{lineage_id}' — Magic "
                             "ETL internals need the Domo instance API."},
                            status_code=404)
    tmp = tempfile.mkdtemp(prefix=f"draft_{lineage_id}_")
    result = pipeline.run(lineage_id, tdir,
                          os.path.join(tmp, "out"), os.path.join(tmp, "sql"))
    lang = language or cfgmod.load_config().pipeline_language
    saved_map = _saved_mapping(lineage_id)
    if result.get("structured"):
        result["sdp"] = {
            "language": lang,
            "code": sdp.render(result, lang, mapping=saved_map),
            "conformed": bool(saved_map),
        }
    return result


@app.post("/api/create/{lineage_id}")
def create(lineage_id: str, payload: Optional[Dict[str, Any]] = Body(default=None)) -> Dict[str, Any]:
    """Create: transpile, write a deployable DAB, deploy if a profile is set.

    Body may override {catalog, schema, profile, language, repo} PER ASSET;
    otherwise the saved config is used. Deploy happens only when a Databricks
    profile is present. The generated bundle uses real SDP in the chosen
    language.
    """
    payload = payload or {}
    cfg = cfgmod.load_config()
    catalog = payload.get("catalog") or cfg.catalog
    schema = payload.get("schema") or cfg.schema
    profile = payload.get("profile", cfg.databricks_profile)
    language = payload.get("language") or cfg.pipeline_language

    p = get_provider()
    tdir = p.triplet_dir(lineage_id)
    if tdir is None:
        return {"error": f"No triplet for '{lineage_id}' — Magic ETL internals "
                "need the Domo instance API."}
    tmp = tempfile.mkdtemp(prefix=f"create_{lineage_id}_")
    result = pipeline.run(lineage_id, tdir,
                          os.path.join(tmp, "out"), os.path.join(tmp, "sql"))
    if result["reconciliation"]["gate"] != "PASS":
        return {"error": "Reconcile gate did not PASS — refusing to create.",
                "transpile": result}

    os.makedirs(_BUNDLE_ROOT, exist_ok=True)
    bundle = write_bundle(result, _BUNDLE_ROOT, catalog, schema,
                          profile=profile, language=language,
                          mapping=_saved_mapping(lineage_id))

    # Optional: commit the bundle to a linked repo (opt-in via the repo field).
    if payload.get("repo") and cfg.git_provider:
        branch = f"pseudo-domo/{lineage_id}"
        msg = f"Add migrated pipeline for {result['lineage']['name']}"
        bundle["git"] = gitlink.commit_bundle(
            cfg.git_provider, payload["repo"], bundle["bundle_dir"], branch, msg)

    # Register the bundle + mark the asset built in the state store.
    try:
        store.get_store().append("bundles", {
            "lineage_id": lineage_id, "pipeline_name": bundle["pipeline_name"],
            "target": f"{catalog}.{schema}", "language": language,
            "deployed": bundle["deployed"]})
        store.get_store().put("asset_status", lineage_id, {
            "lineage_id": lineage_id,
            "status": "deployed" if bundle["deployed"] else "built"})
    except Exception:
        pass

    return {"transpile": {"gate": result["reconciliation"]["gate"],
                          "counts": result["counts"]},
            "bundle": bundle}


@app.get("/api/patterns")
def get_patterns() -> Dict[str, Any]:
    """Current SDP/DAB pattern manifest (tracked from ai-dev-kit)."""
    return patterns.load_patterns()


@app.post("/api/patterns/refresh")
def refresh_patterns() -> Dict[str, Any]:
    """Re-fetch the latest conventions from the ai-dev-kit repo (offline-safe)."""
    return patterns.refresh()


@app.get("/api/llm/status")
def llm_status() -> Dict[str, Any]:
    """Whether the optional LLM enhancement is configured + reachable."""
    return llm.status()


@app.get("/api/config")
def get_config() -> Dict[str, Any]:
    return cfgmod.load_config().public()


@app.post("/api/config")
def set_config(updates: Dict[str, Any] = Body(...)) -> Dict[str, Any]:
    return cfgmod.save_config(updates).public()


@app.get("/api/map/lineage/{lineage_id}")
def map_lineage(lineage_id: str, industry: str = "", force_table: str = "") -> Dict[str, Any]:
    """Per-asset mapping view: map a Build lineage's output DataSet onto the
    chosen industry model. `industry` defaults to the first configured model."""
    ind = industry or _default_industry()
    return mapping.industry_model_map(
        lineage_id=lineage_id, industry=ind,
        force_table_fqn=force_table or None)


@app.post("/api/map/lineage/{lineage_id}")
def save_mapping(lineage_id: str, payload: Dict[str, Any] = Body(...)) -> Dict[str, Any]:
    """Re-map with human overrides (force table + per-column choices) and
    persist the accepted mapping to the state store."""
    ind = payload.get("industry") or _default_industry()
    res = mapping.industry_model_map(
        lineage_id=lineage_id, industry=ind,
        force_table_fqn=payload.get("force_table") or None,
        overrides=payload.get("overrides") or {})
    if payload.get("accept") and not res.get("error"):
        try:
            store.get_store().put("mappings", lineage_id, {
                "lineage_id": lineage_id, "industry": ind,
                "target_table": res.get("target_table"),
                "columns": [{"domo_column": c["domo_column"],
                             "target": c["target"]} for c in res.get("columns", [])]})
            res["saved"] = True
        except Exception:
            res["saved"] = False
    return res


def _saved_mapping(lineage_id: str):
    """Rehydrate a persisted accepted mapping for a lineage, in the shape
    sdp.render expects (target_table, industry, columns[domo_column,target_column])."""
    try:
        rows = store.get_store().list("mappings")
    except Exception:
        return None
    rec = next((r for r in rows if r.get("lineage_id") == lineage_id), None)
    if not rec or not rec.get("target_table"):
        return None
    cols = []
    for c in rec.get("columns", []):
        tgt = c.get("target")
        cols.append({"domo_column": c.get("domo_column"),
                     "target_column": tgt.split(".")[-1] if tgt else None})
    return {"target_table": rec["target_table"], "industry": rec.get("industry", ""),
            "columns": cols}


def _default_industry() -> str:
    models = (cfgmod.load_config().industry_models or "").split(",")
    models = [m.strip() for m in models if m.strip()]
    return models[0] if models else "automotive"


@app.get("/api/map/{dataset_id}")
def map_dataset(dataset_id: str, industry: str = "automotive") -> Dict[str, Any]:
    return mapping.industry_model_map(dataset_id=dataset_id, industry=industry)


@app.get("/api/industries")
def industries() -> Dict[str, Any]:
    return mapping.list_industry_models()


@app.get("/api/models")
def models() -> Dict[str, Any]:
    """Full catalog of Databricks Industry Data Models (all repo models),
    each flagged whether its DDL is vendored locally (mappable offline now)."""
    return {"models": model_catalog.catalog()}


@app.post("/api/models/refresh")
def models_refresh() -> Dict[str, Any]:
    """Refresh the model list from the industry-data-models repo (offline-safe)."""
    return model_catalog.refresh()


@app.get("/api/feasibility")
def feas() -> Dict[str, Any]:
    return feasibility.lakeflow_feasibility()


@app.get("/api/plan")
def migration_plan() -> Dict[str, Any]:
    return planmod.migration_plan()


app.mount("/static", StaticFiles(directory=_STATIC), name="static")


def main() -> None:
    import uvicorn
    port = int(os.environ.get("PORT", "8010"))
    uvicorn.run(app, host="127.0.0.1", port=port)


if __name__ == "__main__":
    main()
