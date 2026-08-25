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


def _magic_flow():
    """A minimal but real Magic ETL flow whose output columns are inferable
    (GroupBy resets to a known column set, so no raw `*` reaches PUBLISH)."""
    return {
        "id": "df-test-upload", "name": "Test Upload Flow", "databaseType": "MAGIC",
        "inputs": [{"dataSourceId": "ds-in", "dataSourceName": "Orders"}],
        "actions": [
            {"id": "a1", "type": "LoadFromVault", "name": "Load", "dataSourceId": "ds-in"},
            {"id": "a2", "type": "GroupBy", "name": "By cust", "dependsOn": ["a1"],
             "groupByColumns": ["customer_id"],
             "aggregations": [{"outputColumn": "order_count", "function": "COUNT", "column": "order_id"},
                              {"outputColumn": "revenue", "function": "SUM", "column": "total"}]},
            {"id": "a3", "type": "PublishToVault", "name": "Publish", "dependsOn": ["a2"],
             "dataSourceName": "Cust_Rollup", "dataSourceId": "ds-out"},
        ],
    }


def _upload(flow):
    import json
    return client.post("/api/upload",
                       files={"file": ("flow.json", json.dumps(flow), "application/json")})


def test_upload_infers_schema_and_transpiles():
    r = _upload(_magic_flow())
    assert r.status_code == 200
    meta = r.json()
    lid = meta["triplet_lineage_id"]
    assert meta["uploaded"] and meta["schema_inferred"]
    # GroupBy resets to exactly these 3 columns.
    assert meta["columns"] == 3
    # it flows through analyze + draft (gate PASS, no Beast Modes to fold)
    g = client.get(f"/api/analyze/{lid}").json()
    assert len(g["nodes"]) == 3 and not g.get("error")
    d = client.get(f"/api/draft/{lid}").json()
    assert d["reconciliation"]["gate"] == "PASS"
    assert d["counts"]["beast_modes_total"] == 0
    # and it can be mapped (schema comes from the synthesized triplet)
    m = client.get(f"/api/map/lineage/{lid}").json()
    assert m["target_table"] and len(m["columns"]) == 3
    # it appears in the uploads list, then cleans up
    assert any(u["triplet_lineage_id"] == lid for u in client.get("/api/uploads").json()["uploads"])
    assert client.delete(f"/api/uploads/{lid}").json()["deleted"] is True


def test_upload_rejects_non_flow_json():
    import json
    r = client.post("/api/upload",
                    files={"file": ("x.json", json.dumps({"not": "a flow"}), "application/json")})
    assert r.status_code == 400
    assert "actions" in r.json()["error"].lower()


def test_upload_needs_schema_when_uninferable():
    # A pass-through flow (Load -> Filter -> Publish) carries a raw `*`, so the
    # exact output columns can't be inferred; the API asks for the schema.
    flow = {
        "id": "df-passthrough", "name": "Passthrough", "databaseType": "MAGIC",
        "inputs": [{"dataSourceId": "ds-in", "dataSourceName": "Raw"}],
        "actions": [
            {"id": "a1", "type": "LoadFromVault", "name": "Load", "dataSourceId": "ds-in"},
            {"id": "a2", "type": "Filter", "name": "F", "dependsOn": ["a1"],
             "filters": [{"column": "status", "operator": "EQUALS", "value": "OPEN"}]},
            {"id": "a3", "type": "PublishToVault", "name": "Pub", "dependsOn": ["a2"],
             "dataSourceName": "Out", "dataSourceId": "ds-out"},
        ],
    }
    r = _upload(flow)
    assert r.status_code == 400
    assert r.json().get("needs_schema") is True


def test_upload_with_explicit_schema_and_card():
    import json
    flow = {
        "id": "df-passthrough2", "name": "Passthrough2", "databaseType": "MAGIC",
        "inputs": [{"dataSourceId": "ds-in", "dataSourceName": "Raw"}],
        "actions": [
            {"id": "a1", "type": "LoadFromVault", "name": "Load", "dataSourceId": "ds-in"},
            {"id": "a2", "type": "PublishToVault", "name": "Pub", "dependsOn": ["a1"],
             "dataSourceName": "Out", "dataSourceId": "ds-out"},
        ],
    }
    schema = {"id": "ds-out", "name": "Out",
              "schema": {"columns": [{"name": "id", "type": "LONG"},
                                     {"name": "label", "type": "STRING"}]}}
    r = client.post("/api/upload", files={
        "file": ("f.json", json.dumps(flow), "application/json"),
        "schema_file": ("s.json", json.dumps(schema), "application/json")})
    assert r.status_code == 200
    meta = r.json()
    assert meta["schema_inferred"] is False and meta["columns"] == 2
    client.delete(f"/api/uploads/{meta['triplet_lineage_id']}")


def test_saved_mapping_conforms_generated_sdp():
    # save a mapping, then the draft SDP includes a conformed view w/ canonical names
    client.post("/api/map/lineage/customer360", json={
        "force_table": "customer.party", "overrides": {"region": "city"}, "accept": True})
    d = client.get("/api/draft/customer360?language=sql").json()
    assert d["sdp"]["conformed"] is True
    assert "_conformed" in d["sdp"]["code"]
    assert "AS `city`" in d["sdp"]["code"]


def test_inventory_has_scores_and_facets():
    inv = client.get("/api/inventory").json()
    assert "facets" in inv and "governance" in inv["facets"]
    df = next(a for a in inv["assets"] if a["asset_type"] in ("magic_etl", "sql_dataflow"))
    assert "effort" in df and "usage" in df


def test_filter_endpoint_narrows():
    r = client.post("/api/inventory/filter", json={
        "governance": "governed", "asset_type": ["magic_etl", "sql_dataflow"]}).json()
    assert 1 <= r["matched"] <= r["total"]
    assert all(a["governance"] == "governed" for a in r["assets"])


def test_estimate_endpoint():
    e = client.get("/api/estimate?domo_annual_spend=1200000").json()
    assert e["migration_effort"]["est_fte_weeks"] >= 0
    assert e["target_consumption"]["band"] in ("SMALL", "MEDIUM", "LARGE")


def test_rationalize_roundtrip_and_plan_reflects():
    import json as _json
    from pseudo_domo_mcp.core import store as _store
    # pick a governed dataflow, mark it Retire
    r = client.post("/api/inventory/filter", json={
        "asset_type": ["magic_etl", "sql_dataflow"]}).json()
    aid = r["assets"][0]["id"]
    save = client.post("/api/rationalize", json={
        "asset_id": aid, "disposition": "Retire", "target_surface": "none",
        "rationale": "test"}).json()
    assert save["saved"] is True
    lst = client.get("/api/rationalizations").json()
    assert any(x["asset_id"] == aid for x in lst["rationalizations"])
    # the plan now surfaces the rationalization rollup + excludes the retired asset
    pl = client.get("/api/plan").json()
    assert "rationalization" in pl["summary"]
    assert save["record"]["name"] in pl["summary"]["retired_excluded"]
    # cleanup: keep dev state clean (no delete API — reset the collection)
    try:
        d = _json.load(open(_store._LOCAL_PATH))
        d["rationalizations"] = {}
        _json.dump(d, open(_store._LOCAL_PATH, "w"), indent=2)
    except Exception:
        pass


def test_nondataflow_disposition_counts_and_wave_no_collapse():
    import json as _json
    from pseudo_domo_mcp.core import store as _store
    inv = client.get("/api/inventory").json()["assets"]
    card = next(a for a in inv if a["asset_type"] == "card")
    df = next(a for a in inv if a["asset_type"] in ("magic_etl", "sql_dataflow"))
    # a CARD disposition (Elevate -> ai_bi_genie) must show in the estimate,
    client.post("/api/rationalize", json={"asset_id": card["id"], "disposition": "Elevate",
                                          "target_surface": "ai_bi_genie", "rationale": "t"})
    # and assigning ONE dataflow a wave must NOT collapse the rest into one wave.
    client.post("/api/rationalize", json={"asset_id": df["id"], "disposition": "Rebuild",
                                          "target_surface": "ai_bi_genie", "assigned_wave": 1})
    est = client.get("/api/estimate").json()
    assert est["target_surfaces"].get("ai_bi_genie", 0) >= 1  # card counted (fix 1)
    pl = client.get("/api/plan").json()
    non_empty = [w for w in pl["waves"] if w["items"]]
    assert len(non_empty) >= 2  # assigned wave + auto buckets, not collapsed (fix 2)
    try:
        d = _json.load(open(_store._LOCAL_PATH))
        d["rationalizations"] = {}
        _json.dump(d, open(_store._LOCAL_PATH, "w"), indent=2)
    except Exception:
        pass
