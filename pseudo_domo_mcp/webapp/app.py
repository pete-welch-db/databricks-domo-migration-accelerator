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


@app.get("/api/analyze/{lineage_id}")
def analyze(lineage_id: str) -> Dict[str, Any]:
    """Analyze/preview: the Magic ETL DAG as a medallion-layered graph."""
    p = get_provider()
    fixtures = getattr(p, "lineages_dir_path", lambda: None)()
    if not fixtures:
        return JSONResponse({"error": "no lineage source"}, status_code=400)
    trip = p.get_lineage_triplet(lineage_id)
    if trip is None:
        return JSONResponse(
            {"error": f"No full triplet for '{lineage_id}'. Discovery-only "
                      "object — Magic ETL internals need the Domo export/private "
                      "API (public API exposes only DataSet + card metadata)."},
            status_code=404)
    return build_graph(lineage_id, fixtures)


@app.get("/api/draft/{lineage_id}")
def draft(lineage_id: str) -> Dict[str, Any]:
    """Draft: run the transpiler, return SDP SQL + reconcile gate (no deploy)."""
    p = get_provider()
    fixtures = getattr(p, "lineages_dir_path", lambda: None)()
    tmp = tempfile.mkdtemp(prefix=f"draft_{lineage_id}_")
    result = pipeline.run(lineage_id, fixtures,
                          os.path.join(tmp, "out"), os.path.join(tmp, "sql"))
    return result


@app.post("/api/create/{lineage_id}")
def create(lineage_id: str, payload: Optional[Dict[str, Any]] = Body(default=None)) -> Dict[str, Any]:
    """Create: transpile, write a deployable DAB, deploy if a profile is set.

    Body may override {catalog, schema, profile}; otherwise the saved config
    is used. Deploy happens only when a Databricks profile is present.
    """
    payload = payload or {}
    cfg = cfgmod.load_config()
    catalog = payload.get("catalog") or cfg.catalog
    schema = payload.get("schema") or cfg.schema
    profile = payload.get("profile", cfg.databricks_profile)

    p = get_provider()
    fixtures = getattr(p, "lineages_dir_path", lambda: None)()
    tmp = tempfile.mkdtemp(prefix=f"create_{lineage_id}_")
    result = pipeline.run(lineage_id, fixtures,
                          os.path.join(tmp, "out"), os.path.join(tmp, "sql"))
    if result["reconciliation"]["gate"] != "PASS":
        return {"error": "Reconcile gate did not PASS — refusing to create.",
                "transpile": result}

    os.makedirs(_BUNDLE_ROOT, exist_ok=True)
    bundle = write_bundle(result, _BUNDLE_ROOT, catalog, schema, profile=profile)
    return {"transpile": {"gate": result["reconciliation"]["gate"],
                          "counts": result["counts"]},
            "bundle": bundle}


@app.get("/api/config")
def get_config() -> Dict[str, Any]:
    return cfgmod.load_config().public()


@app.post("/api/config")
def set_config(updates: Dict[str, Any] = Body(...)) -> Dict[str, Any]:
    return cfgmod.save_config(updates).public()


@app.get("/api/map/{dataset_id}")
def map_dataset(dataset_id: str, industry: str = "automotive") -> Dict[str, Any]:
    return mapping.industry_model_map(dataset_id, industry=industry)


@app.get("/api/industries")
def industries() -> Dict[str, Any]:
    return mapping.list_industry_models()


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
