"""End-to-end tests for the Pseudo-Domo MCP tools (against synthetic fixtures).

These exercise the plain sync tool functions directly (no MCP client needed),
which is exactly what the server wraps. Running `pytest` proves the whole
discovery -> assess -> map -> feasibility -> transpile -> plan flow works
offline and that the transpile reconcile gate goes green.
"""

from __future__ import annotations

from pseudo_domo_mcp.tools import (
    discovery, assessment, mapping, feasibility, transpile, plan,
)


def test_discover_summary():
    s = discovery.domo_discover("summary")
    assert s["counts"]["datasets"] == 9
    assert s["counts"]["dataflows"] == 5
    assert s["dataflow_types"]["MAGIC"] == 4
    assert s["dataflow_types"]["SQL"] == 1
    # governed vs shadow split present
    assert s["governance_split"]["dataflows"]["governed"] >= 1
    assert s["governance_split"]["dataflows"]["shadow"] >= 1


def test_discover_scopes():
    assert len(discovery.domo_discover("datasets")["datasets"]) == 9
    assert len(discovery.domo_discover("cards")["cards"]) == 6
    assert len(discovery.domo_discover("pages")["pages"]) == 5
    assert "Oracle ERP" in discovery.domo_discover("sources")["source_systems"]


def test_assess_dataflows_classify_and_score():
    out = assessment.domo_assess("dataflows")["assessments"]
    by_name = {a["name"]: a for a in out}
    c360 = by_name["Customer 360 - Aftermarket Master"]
    assert c360["data_domain"] in ("customer", "aftersales")
    assert c360["governance"] == "governed"
    assert c360["has_triplet"] is True
    # SQL dataflow scores higher complexity than a plain magic flow
    sqlflow = by_name["Plant OEE Rollup (SQL DataFlow)"]
    assert sqlflow["database_type"] == "SQL"
    assert sqlflow["complexity"]["score"] >= 40
    # writeback flow flagged as high complexity
    capex = by_name["CapEx Tracker Aggregation (+writeback)"]
    assert any("WRITEBACK" in d for d in capex["complexity"]["drivers"])


def test_assess_summary_quick_wins():
    s = assessment.domo_assess("summary")["portfolio"]
    assert "by_domain" in s and "by_governance" in s


def test_list_and_map_industry_model():
    models = mapping.list_industry_models()["industries"]
    assert "automotive" in models and "transport_shipping" in models
    auto = mapping.list_industry_models("automotive")
    assert auto["table_count"] > 50
    assert "customer" in auto["domains"]


def test_industry_model_map_customer360():
    res = mapping.industry_model_map("ds-customer360-out-9999", industry="automotive")
    assert res["target_table"] is not None
    assert res["mapped_count"] >= 3
    # identity columns should map into the customer domain
    targets = [m["target"] for m in res["mappings"]]
    assert any(t.startswith("customer.") for t in targets)


def test_lakeflow_feasibility_ranks_and_flags_writeback():
    out = feasibility.lakeflow_feasibility()
    ratings = {r["source_system"]: r["rating"] for r in out["feasibility"]}
    assert ratings.get("Salesforce") == "GREEN"
    assert ratings.get("SQL Server (MES)") == "GREEN"
    # writeback source must be RED (re-platform, not ingest)
    assert ratings.get("Domo App/Form (writeback)") == "RED"
    # ranked GREEN-first
    order = [r["rating"] for r in out["feasibility"]]
    assert order == sorted(order, key=lambda r: {"GREEN": 0, "AMBER": 1, "RED": 2}[r])


def test_transpile_lineage_gate_passes():
    res = transpile.transpile_lineage("customer360")
    assert res["reconciliation"]["gate"] == "PASS"
    assert res["counts"]["gold_columns"] == 14
    assert res["counts"]["beast_modes_translated"] == res["counts"]["beast_modes_total"] == 5
    # emitted SQL is present and real
    assert "CREATE OR REPLACE VIEW" in res["sql"]["gold"]
    assert "semantic_metrics" in res["sql"]["gold_semantic_metrics"].lower() or \
           "Beast Mode" in res["sql"]["gold_semantic_metrics"]


def test_migration_plan_end_to_end():
    p = plan.migration_plan()
    assert p["recommended_pilot"] is not None
    assert len(p["waves"]) == 3
    # wave 3 is the shadow-IT re-platform bucket
    assert "Lakebase" in p["waves"][2]["theme"]
    assert "source_feasibility" in p


def test_governance_is_inferred_not_pretagged():
    from pseudo_domo_mcp.core import governance
    # a managed connector + team owner + regular schedule -> governed
    df = {"owner": {"name": "Data Platform Team"}, "runCadence": "4x/day"}
    inp = [{"_source_system": "Salesforce"}, {"_source_system": "SQL Server"}]
    g = governance.infer(df, inp)
    assert g["governance"] == "governed" and g["confidence"] > 0.5
    assert any("managed" in s for s in g["signals"])
    # a writeback app -> shadow, with an explanatory signal
    df2 = {"owner": {"name": "Finance Ops"}, "runCadence": "on-submit", "_has_writeback": True}
    g2 = governance.infer(df2, [{"_source_system": "Domo App/Form (writeback)"}])
    assert g2["governance"] == "shadow"
    assert any("writeback" in s.lower() for s in g2["signals"])


def test_assess_exposes_governance_signals():
    out = assessment.domo_assess("dataflows")["assessments"]
    for a in out:
        assert "governance_signals" in a and isinstance(a["governance_signals"], list)
        assert 0.0 <= a["governance_confidence"] <= 1.0


def test_sdp_renders_real_lakeflow_sql_and_python():
    from pseudo_domo_mcp.transpiler import pipeline
    from pseudo_domo_mcp.core.domo_client import get_provider
    from pseudo_domo_mcp.core import sdp
    import tempfile, os
    p = get_provider()
    d = tempfile.mkdtemp()
    r = pipeline.run("customer360", p.lineages_dir_path(),
                     os.path.join(d, "o"), os.path.join(d, "s"))
    sql = sdp.render(r, "sql")
    assert "STREAMING TABLE" in sql and "MATERIALIZED VIEW" in sql
    assert "EXPECT" in sql                       # gold expectations
    assert "WITH METRICS" in sql                 # metric view for Beast Modes
    py = sdp.render(r, "python")
    assert "@dlt.table" in py and "expect_all_or_drop" in py
    assert "METRIC VIEW" in py                   # recommends metric view
