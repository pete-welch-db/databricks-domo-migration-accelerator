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

from fastapi import FastAPI, Body, UploadFile, File, Form
from fastapi.responses import FileResponse, JSONResponse
from fastapi.staticfiles import StaticFiles

from ..core.domo_client import get_provider
from ..core import runtime
from ..core import config as cfgmod
from ..core import gitlink
from ..core import sdp
from ..core import store
from ..core import patterns
from ..core import model_catalog
from ..core import llm
from ..core import uploads
from ..core import filters as filtercore
from ..core import rationalize as ratcore
from ..core.graph import build_graph
from ..core.bundle import write_bundle
from ..transpiler import pipeline
from ..tools import discovery, assessment, mapping, feasibility, plan as planmod
from ..tools import filters as filtersmod
from ..tools import rationalize as ratmod
from ..tools import estimate as estmod
from ..tools import orchestration as orchmod

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
    # Facets (distinct filterable values) let the UI build the filter panel from
    # the real estate; saved dispositions are merged so a disposition filter works.
    saved = {r["asset_id"]: r for r in store.get_store().list("rationalizations")}
    ratcore.merge_dispositions(inv["assets"], saved)
    inv["facets"] = filtercore.facets(inv["assets"])
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
    # Read the collections first: the store connects lazily, so backend() only
    # reflects the true backend after a query has fired the connection.
    scans, bundles = s.list("scans"), s.list("bundles")
    return {"backend": s.backend(), "scans": scans, "bundles": bundles}


# ----- Filtered discovery + saved filter sets (= migration waves) ---------- #

@app.post("/api/inventory/filter")
def inventory_filter(criteria: Dict[str, Any] = Body(default={})) -> Dict[str, Any]:
    """Return the inventory narrowed by multi-criteria filters (see core.filters)."""
    return filtersmod.filter_inventory(criteria)


@app.get("/api/filter-sets")
def filter_sets() -> Dict[str, Any]:
    """List saved filter sets (wave candidates) with current matched counts."""
    return filtersmod.list_filter_sets()


@app.post("/api/filter-sets")
def save_filter_set(body: Dict[str, Any] = Body(...)) -> Dict[str, Any]:
    """Save a named filter set. Body: {name, criteria, description?}."""
    return filtersmod.save_filter_set(body.get("name", "Untitled"),
                                      body.get("criteria", {}),
                                      body.get("description", ""))


@app.get("/api/filter-sets/{filter_set_id}")
def apply_filter_set(filter_set_id: str) -> Dict[str, Any]:
    """Apply a saved filter set and return its matching assets."""
    return filtersmod.apply_saved_filter(filter_set_id)


# ----- Rationalization (disposition + target surface per asset) ------------ #

@app.post("/api/rationalize/suggest")
def rationalize_suggest(criteria: Dict[str, Any] = Body(default={})) -> Dict[str, Any]:
    """Suggested + already-decided dispositions for each asset (optionally filtered)."""
    return ratmod.suggest_dispositions(criteria or None)


@app.get("/api/rationalizations")
def rationalizations() -> Dict[str, Any]:
    """All saved dispositions + a rollup by disposition / target surface / wave."""
    return ratmod.list_rationalizations()


@app.post("/api/rationalize")
def rationalize(body: Dict[str, Any] = Body(...)) -> Dict[str, Any]:
    """Save one asset's disposition. Body: {asset_id, disposition, target_surface?,
    rationale?, assigned_wave?, decided_by?}."""
    return ratmod.rationalize_asset(
        body.get("asset_id", ""), body.get("disposition", ""),
        body.get("target_surface", ""), body.get("rationale", ""),
        int(body.get("assigned_wave") or 0), body.get("decided_by", ""))


@app.post("/api/rationalize/bulk")
def rationalize_bulk(body: Dict[str, Any] = Body(...)) -> Dict[str, Any]:
    """Apply one disposition to every asset matching a filter (wave-at-once).
    Body: {criteria, disposition, target_surface?, assigned_wave?, rationale?}."""
    return ratmod.rationalize_bulk(
        body.get("criteria", {}), body.get("disposition", ""),
        body.get("target_surface", ""), int(body.get("assigned_wave") or 0),
        body.get("rationale", ""), body.get("decided_by", ""))


@app.get("/api/estimate")
def estimate(domo_annual_spend: float = 0.0) -> Dict[str, Any]:
    """Directional future-state estimate: migration effort (FTE-weeks), target
    consumption size, and surface split, from assess + saved dispositions."""
    return estmod.estimate_migration(domo_annual_spend)


@app.get("/api/orchestration")
def orchestration() -> Dict[str, Any]:
    """Domo scheduling + dataflow-dependency graph, mapped to Databricks Workflows."""
    return orchmod.orchestration_plan()


def _resolve_triplet_dir(lineage_id: str):
    """Locate a lineage's triplet dir — an uploaded flow first (synthesized
    under generated/_uploads/), else the active provider (fixtures / live API).
    Uploaded lineages are keyed `upload_*` so the lookup is cheap and unambiguous."""
    up = uploads.triplet_dir(lineage_id)
    if up is not None:
        return up
    return get_provider().triplet_dir(lineage_id)


@app.get("/api/analyze/{lineage_id}")
def analyze(lineage_id: str) -> Dict[str, Any]:
    """Analyze/preview: the Magic ETL DAG as a medallion-layered graph."""
    tdir = _resolve_triplet_dir(lineage_id)
    if tdir is None:
        return JSONResponse(
            {"error": f"No full triplet for '{lineage_id}'. Magic ETL internals "
                      "come from the Domo instance API (dataprocessing); set "
                      "DOMO_INSTANCE + DOMO_DEVELOPER_TOKEN, use fixtures, or "
                      "upload a Magic ETL JSON."},
            status_code=404)
    return build_graph(lineage_id, tdir)


@app.get("/api/draft/{lineage_id}")
def draft(lineage_id: str, language: str = "") -> Dict[str, Any]:
    """Draft: run the transpiler, return real SDP (Lakeflow Declarative Pipeline)
    code in the chosen language + the reconcile gate (no deploy)."""
    tdir = _resolve_triplet_dir(lineage_id)
    if tdir is None:
        return JSONResponse({"error": f"No triplet for '{lineage_id}' — Magic "
                             "ETL internals need the Domo instance API, or "
                             "upload a Magic ETL JSON."},
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
    from ..core.generators import DEFAULT_TARGETS
    build_targets = payload.get("build_targets") or DEFAULT_TARGETS

    tdir = _resolve_triplet_dir(lineage_id)
    if tdir is None:
        return {"error": f"No triplet for '{lineage_id}' — Magic ETL internals "
                "need the Domo instance API, or upload a Magic ETL JSON."}
    tmp = tempfile.mkdtemp(prefix=f"create_{lineage_id}_")
    result = pipeline.run(lineage_id, tdir,
                          os.path.join(tmp, "out"), os.path.join(tmp, "sql"))
    # The reconcile gate protects the ETL pipeline (schema parity). Non-pipeline
    # targets (dashboard/genie/metric views) don't require it, so only block when
    # the pipeline itself is being generated.
    if "etl_pipeline" in build_targets and result["reconciliation"]["gate"] != "PASS":
        return {"error": "Reconcile gate did not PASS — refusing to create the pipeline.",
                "transpile": result}

    # Supply orchestration + connectors when those targets are requested.
    orchestration = orchmod.orchestration_plan() if "databricks_workflow" in build_targets else None
    connectors = None
    if "uc_ingestion" in build_targets:
        connectors = [a for a in discovery.domo_inventory()["assets"]
                      if a["asset_type"] == "connector"]

    os.makedirs(_BUNDLE_ROOT, exist_ok=True)
    bundle = write_bundle(result, _BUNDLE_ROOT, catalog, schema,
                          profile=profile, language=language,
                          mapping=_saved_mapping(lineage_id),
                          build_targets=build_targets,
                          orchestration=orchestration, connectors=connectors)

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


@app.post("/api/upload")
async def upload_flow(file: UploadFile = File(...),
                      schema_file: Optional[UploadFile] = File(default=None),
                      card_file: Optional[UploadFile] = File(default=None)) -> Dict[str, Any]:
    """Manually add a migratable unit from an uploaded Magic ETL JSON.

    The transpiler needs a triplet (flow + output DataSet schema + card Beast
    Modes). Only `file` (the Magic ETL DataFlow) is required — if `schema`
    and/or `card` are omitted, they're synthesized: the schema is inferred from
    the transform DAG, the card is empty (no Beast Modes). Returns a build-asset
    descriptor the UI drops into the Build list, or a 400 with `needs_schema`
    when the output columns can't be inferred and no schema was supplied."""
    import json as _json

    async def _parse(f: Optional[UploadFile]):
        if f is None:
            return None
        raw = await f.read()
        if not raw:
            return None
        return _json.loads(raw.decode("utf-8"))

    try:
        flow = await _parse(file)
    except (ValueError, UnicodeDecodeError) as e:
        return JSONResponse({"error": f"Not valid JSON: {e}"}, status_code=400)
    if not isinstance(flow, dict):
        return JSONResponse({"error": "Uploaded file is not a JSON object."},
                            status_code=400)
    try:
        schema_doc = await _parse(schema_file)
        card_doc = await _parse(card_file)
    except (ValueError, UnicodeDecodeError) as e:
        return JSONResponse({"error": f"Schema/card not valid JSON: {e}"},
                            status_code=400)

    meta = uploads.register_upload(flow, schema=schema_doc, card=card_doc)
    if meta.get("error"):
        return JSONResponse(meta, status_code=400)
    return meta


@app.get("/api/uploads")
def list_uploads() -> Dict[str, Any]:
    """All manually-uploaded build assets (persisted under generated/_uploads)."""
    return {"uploads": uploads.list_uploads()}


@app.delete("/api/uploads/{lineage_id}")
def delete_upload(lineage_id: str) -> Dict[str, Any]:
    return {"deleted": uploads.delete_upload(lineage_id)}


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


@app.get("/api/debug/store")
def debug_store() -> Dict[str, Any]:
    """Diagnostics for the persistence backend (env presence + connect error)."""
    info: Dict[str, Any] = {
        "mode": runtime.mode(),
        "pg_env": {k: bool(os.environ.get(k))
                   for k in ("PGHOST", "PGUSER", "PGDATABASE", "PGPORT")},
        "pguser_value": os.environ.get("PGUSER", ""),
        "lakebase_instance_env": os.environ.get("PSEUDO_DOMO_LAKEBASE_INSTANCE", ""),
        "store_backend_env": os.environ.get("PSEUDO_DOMO_STORE_BACKEND", ""),
    }
    for mod in ("psycopg", "databricks.sdk"):
        try:
            __import__(mod)
            info[mod] = "ok"
        except Exception as e:  # noqa: BLE001
            info[mod] = f"ERR {type(e).__name__}: {e}"
    s = store.get_store()
    # Force a real connection attempt before reporting (backend()/last_error are
    # only meaningful after the lazy connect fires).
    try:
        info["config_rows"] = len(s.list("config"))
    except Exception as e:  # noqa: BLE001
        info["list_error"] = f"{type(e).__name__}: {e}"
    info["backend"] = s.backend()
    info["last_error"] = getattr(s, "last_error", None)
    return info


@app.get("/api/debug/llm")
def debug_llm() -> Dict[str, Any]:
    """Live LLM round-trip: prove the endpoint actually answers (not just that
    it's configured). Uses the deterministic fallback path, so it never errors."""
    st = llm.status()
    if not st["enabled"]:
        return {"status": st, "reply": None}
    reply = llm._chat([{"role": "user", "content": "Reply with the single word: PONG"}],
                      max_tokens=10)
    return {"status": st, "reply": reply, "reachable": bool(reply)}


@app.get("/api/config")
def get_config() -> Dict[str, Any]:
    return cfgmod.load_config().public()


@app.post("/api/config")
def set_config(updates: Dict[str, Any] = Body(...)) -> Dict[str, Any]:
    return cfgmod.save_config(updates).public()


def _upload_map_kwargs(lineage_id: str) -> Dict[str, Any]:
    """For an uploaded lineage, feed the synthesized triplet's schema straight
    into the mapper (it isn't in the provider census). Empty dict otherwise."""
    cols = uploads.upload_schema_columns(lineage_id)
    if cols is None:
        return {}
    meta = uploads.get_upload(lineage_id) or {}
    return {"schema_cols": cols,
            "dataset_name": meta.get("output_dataset_name", "")}


@app.get("/api/map/lineage/{lineage_id}")
def map_lineage(lineage_id: str, industry: str = "", force_table: str = "") -> Dict[str, Any]:
    """Per-asset mapping view: map a Build lineage's output DataSet onto the
    chosen industry model. `industry` defaults to the first configured model."""
    ind = industry or _default_industry()
    return mapping.industry_model_map(
        lineage_id=lineage_id, industry=ind,
        force_table_fqn=force_table or None,
        **_upload_map_kwargs(lineage_id))


@app.post("/api/map/lineage/{lineage_id}")
def save_mapping(lineage_id: str, payload: Dict[str, Any] = Body(...)) -> Dict[str, Any]:
    """Re-map with human overrides (force table + per-column choices) and
    persist the accepted mapping to the state store."""
    ind = payload.get("industry") or _default_industry()
    res = mapping.industry_model_map(
        lineage_id=lineage_id, industry=ind,
        force_table_fqn=payload.get("force_table") or None,
        overrides=payload.get("overrides") or {},
        **_upload_map_kwargs(lineage_id))
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
    from ..core import runtime
    uvicorn.run(app, host=runtime.bind_host(), port=runtime.bind_port())


if __name__ == "__main__":
    main()
