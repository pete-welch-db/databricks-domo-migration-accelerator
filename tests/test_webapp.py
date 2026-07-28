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
    assert "export" in r.json()["error"].lower()


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
                    json={"catalog": "acme", "schema": "aft", "profile": ""}).json()
    b = r["bundle"]
    assert b["deployed"] is False              # no profile -> files only
    assert b["catalog"] == "acme"
    assert any(f.endswith("gold.sql") for f in b["sql_files"])
    assert "bundle deploy" in b["deploy_command"]
