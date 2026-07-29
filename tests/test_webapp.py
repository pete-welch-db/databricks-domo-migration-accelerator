"""End-to-end tests for the operator console's REST API (offline fixtures).

Drives the same endpoints the browser uses, so the browse -> analyze -> draft
-> create flow is covered without a live browser.
"""

from __future__ import annotations

from fastapi.testclient import TestClient

from pseudo_domo_mcp.webapp.app import app

client = TestClient(app)


def test_index_and_static():
    assert client.get("/").status_code == 200
    assert client.get("/static/app.js").status_code == 200
    assert client.get("/static/app.css").status_code == 200


def test_estate():
    r = client.get("/api/estate")
    assert r.status_code == 200
    data = r.json()
    assert len(data["dataflows"]) == 5
    # each dataflow carries the assessment fields the UI chips need
    df = data["dataflows"][0]
    for k in ("value", "complexity", "governance", "data_domain", "database_type"):
        assert k in df


def test_analyze_graph():
    g = client.get("/api/analyze/customer360").json()
    assert len(g["nodes"]) == 15
    assert len(g["edges"]) == 14
    layers = {n["layer"] for n in g["nodes"]}
    assert {"bronze", "silver", "gold"} <= layers
    assert len(g["meta"]["beast_modes"]) == 5


def test_analyze_missing_triplet_is_honest():
    # a discovery-only object (no triplet) should 404 with an explanation
    r = client.get("/api/analyze/does-not-exist")
    assert r.status_code == 404
    assert "instance" in r.json()["error"].lower()


def test_draft_gate_passes():
    d = client.get("/api/draft/customer360").json()
    assert d["reconciliation"]["gate"] == "PASS"
    assert set(d["sql"]) >= {"bronze", "silver", "gold", "gold_semantic_metrics"}


def test_config_roundtrip():
    orig = client.get("/api/config").json()
    updated = client.post("/api/config", json={"catalog": "unit_test_cat"}).json()
    assert updated["catalog"] == "unit_test_cat"
    # restore
    client.post("/api/config", json={"catalog": orig["catalog"]})


def test_create_writes_bundle_no_deploy():
    r = client.post("/api/create/customer360",
                    json={"catalog": "acme", "schema": "aft", "profile": "",
                          "language": "sql"}).json()
    b = r["bundle"]
    assert b["deployed"] is False              # no profile -> files only
    assert b["catalog"] == "acme"
    # bundle now emits a single real-SDP pipeline file
    assert any(f.endswith("pipeline.sql") for f in b["sql_files"])
    assert "bundle deploy" in b["deploy_command"]


def test_create_python_bundle_and_history():
    r = client.post("/api/create/supplier_quality",
                    json={"catalog": "bu_cat", "schema": "quality",
                          "language": "python", "profile": ""}).json()
    assert any(f.endswith("pipeline.py") for f in r["bundle"]["sql_files"])
    # bundle + scan history is persisted and queryable
    h = client.get("/api/history").json()
    assert "backend" in h and isinstance(h["bundles"], list)


def test_inventory_typed_and_searchable():
    inv = client.get("/api/inventory").json()
    ct = inv["counts_by_type"]
    assert ct["connector"] >= 1 and ct["magic_etl"] >= 1 and ct["beast_mode"] >= 1
    # connectors carry a Databricks remap plan
    conns = [a for a in inv["assets"] if a["asset_type"] == "connector"]
    assert all("databricks_remap" in c for c in conns)
    # filter by type
    only_ds = client.get("/api/inventory?asset_type=dataset").json()
    assert all(a["asset_type"] == "dataset" for a in only_ds["assets"])
    # search by name
    war = client.get("/api/inventory?search=warranty").json()
    assert war["matched"] >= 1 and all("warranty" in a["name"].lower() for a in war["assets"])


def test_config_exposes_git_fields():
    c = client.get("/api/config").json()
    assert "git_provider" in c and "git_token_present" in c


def test_patterns_endpoint_and_tunables():
    p = client.get("/api/patterns").json()
    assert "tunables" in p and "streaming_keyword" in p["tunables"]


def test_config_new_fields_roundtrip():
    orig = client.get("/api/config").json()
    u = client.post("/api/config", json={
        "pipeline_language": "python", "industry_models": "automotive,transport_shipping",
        "store_backend": "local"}).json()
    assert u["pipeline_language"] == "python"
    assert "transport_shipping" in u["industry_models"]
    client.post("/api/config", json={"pipeline_language": orig["pipeline_language"],
                                     "industry_models": orig["industry_models"]})


def test_models_catalog_lists_all_repo_models():
    m = client.get("/api/models").json()["models"]
    keys = {x["key"] for x in m}
    assert len(m) >= 30                          # full repo, not just vendored
    assert "automotive" in keys and "banking" in keys and "healthcare" in keys
    vendored = [x["key"] for x in m if x["vendored"]]
    assert "automotive" in vendored              # DDL present locally


def test_llm_optional_off_by_default():
    s = client.get("/api/llm/status").json()
    assert s["enabled"] is False              # not configured -> off, tool still works
    c = client.get("/api/config").json()
    assert c["llm_enabled"] is False and "databricks_host" in c


def test_config_llm_and_host_roundtrip():
    u = client.post("/api/config", json={
        "llm_endpoint": "my-endpoint", "databricks_host": "https://x.cloud.databricks.com"}).json()
    assert u["llm_endpoint"] == "my-endpoint"
    assert u["databricks_host"].startswith("https://")
    client.post("/api/config", json={"llm_endpoint": "", "databricks_host": ""})


def test_map_lineage_view_and_override():
    m = client.get("/api/map/lineage/customer360").json()
    assert m["target_table"] and m["columns"] and m["model_tables"]
    # each column carries ranked candidates for the dropdown
    assert all("candidates" in c for c in m["columns"])
    # override + accept persists and wins
    r = client.post("/api/map/lineage/customer360", json={
        "force_table": "customer.party", "overrides": {"region": "city"},
        "accept": True}).json()
    reg = [c for c in r["columns"] if c["domo_column"] == "region"][0]
    assert reg["target_column"] == "city" and reg["source"] == "override"
    assert r.get("saved") is True


def test_saved_mapping_conforms_generated_sdp():
    # save a mapping, then the draft SDP includes a conformed view w/ canonical names
    client.post("/api/map/lineage/customer360", json={
        "force_table": "customer.party", "overrides": {"region": "city"}, "accept": True})
    d = client.get("/api/draft/customer360?language=sql").json()
    assert d["sdp"]["conformed"] is True
    assert "_conformed" in d["sdp"]["code"]
    assert "AS `city`" in d["sdp"]["code"]
