"""rationalize — portfolio rationalization: the decision layer between Assess
and Convert.

Lakebridge assesses (Profiler/Analyzer) then converts; the value-driven step in
between — decide what to do with each asset before porting anything — is where a
Domo estate is actually rationalized. Every asset gets a **disposition** and a
**target surface**:

    DISPOSITIONS   Retire · Repoint · Rebuild · Elevate · Consolidate
    TARGET SURFACES ai_bi_genie · genie_app_builder · sigma_input_tables ·
                    apps_lakebase · none  (product-based, customer-agnostic)

`suggest_disposition(asset)` proposes a default from the Assess signals
(governance / usage / value / complexity / writeback) so a human starts from a
recommendation and edits, rather than a blank grid. Pure logic — persistence
(the `rationalizations` store collection) lives in tools/rationalize.py.
"""

from __future__ import annotations

from typing import Any, Dict, List

DISPOSITIONS = ["Retire", "Repoint", "Rebuild", "Elevate", "Consolidate"]

# Master label map for every target surface across all asset types.
SURFACE_LABELS = {
    "ai_bi_genie": "AI/BI + Genie",
    "ai_bi_dashboard": "AI/BI Dashboard",
    "genie": "Genie Space",
    "genie_app_builder": "Genie App Builder",
    "sigma_input_tables": "Sigma Input Tables",
    "apps_lakebase": "Databricks Apps + Lakebase",
    "etl_pipeline": "Lakeflow Pipeline (SDP)",
    "metric_views": "Unity Catalog Metric Views",
    "repoint": "Repoint to gold (connector swap)",
    "lakeflow_connect": "Lakeflow Connect (managed)",
    "uc_connection_secrets": "UC Connection + credentials/secrets",
    "auto_loader": "Auto Loader (files)",
    "custom_python": "Custom Python ingestion",
    "none": "None (retire)",
}


def _surfaces(*keys):
    return [{"key": k, "label": SURFACE_LABELS[k]} for k in keys]


# Default surfaces (kept for back-compat / unknown types).
TARGET_SURFACES = _surfaces("ai_bi_genie", "genie_app_builder", "sigma_input_tables",
                            "apps_lakebase", "none")

# Surfaces make sense only for certain asset types — connectors are an ingestion
# decision (Lakeflow Connect / UC Connection + secrets / Auto Loader / custom
# Python), not a BI one; cards/pages are BI; transforms produce pipelines.
TARGET_SURFACES_BY_TYPE = {
    "connector": _surfaces("lakeflow_connect", "uc_connection_secrets", "auto_loader",
                           "apps_lakebase", "custom_python", "none"),
    "magic_etl": _surfaces("etl_pipeline", "metric_views", "ai_bi_genie", "apps_lakebase", "none"),
    "sql_dataflow": _surfaces("etl_pipeline", "metric_views", "ai_bi_genie", "apps_lakebase", "none"),
    "card": _surfaces("ai_bi_dashboard", "repoint", "genie", "none"),
    "page": _surfaces("ai_bi_dashboard", "repoint", "none"),
    "beast_mode": _surfaces("metric_views", "none"),
    "dataset": _surfaces("none"),
}


def surfaces_for(asset_type):
    """Return the target surfaces that make sense for a given asset type."""
    return TARGET_SURFACES_BY_TYPE.get(asset_type, TARGET_SURFACES)


def _has_writeback(asset: Dict[str, Any]) -> bool:
    # Prefer the explicit flag (surfaced by build_inventory from the provider);
    # fall back to the driver/factor text and the asset name so detection works
    # regardless of how the signal arrived.
    if asset.get("has_writeback"):
        return True
    text = " ".join((asset.get("complexity") or {}).get("drivers", [])
                    + (asset.get("effort") or {}).get("factors", [])
                    + [asset.get("name") or ""]).lower()
    return "writeback" in text


def suggest_disposition(asset: Dict[str, Any]) -> Dict[str, str]:
    """Recommend a disposition + target surface + rationale from Assess signals."""
    atype = asset.get("asset_type", "")
    gov = asset.get("governance")
    usage_band = (asset.get("usage") or {}).get("band", "LOW")
    usage_score = (asset.get("usage") or {}).get("usage_score", 0)
    value_band = (asset.get("value") or {}).get("band", "LOW")

    def out(disp, surface, why):
        return {"disposition": disp, "target_surface": surface, "rationale": why}

    if atype == "beast_mode":
        return out("Elevate", "metric_views",
                   "Fold this calc field into a governed Unity Catalog metric view.")

    if atype == "connector":
        remap = asset.get("databricks_remap") or {}
        pattern = (remap.get("pattern", "") + " " + remap.get("connector", "")).lower()
        if remap.get("rating") == "RED" or "lakebase" in pattern or "writeback" in pattern:
            return out("Rebuild", "apps_lakebase",
                       "Writeback/transactional source — re-platform to Apps + Lakebase.")
        if "auto loader" in pattern:
            return out("Rebuild", "auto_loader",
                       "No managed connector — land periodic exports via Auto Loader.")
        if "managed" in pattern or "lakeflow" in pattern:
            return out("Rebuild", "lakeflow_connect",
                       "Managed Lakeflow Connect connector available — ingest directly.")
        return out("Rebuild", "custom_python",
                   "No managed path — custom ingestion (UC connection + secrets).")

    if atype == "dataset":
        return out("", "none", "Derivative asset — disposition follows its pipeline/connector.")

    # Low usage + low value → retire (the dead-weight cull) — only for the
    # transform + BI asset types that actually carry usage/value signals.
    if usage_band == "LOW" and value_band == "LOW" and usage_score < 20:
        return out("Retire", "none",
                   "Low usage and low value — retire rather than migrate.")

    if atype in ("magic_etl", "sql_dataflow"):
        if _has_writeback(asset):
            return out("Rebuild", "apps_lakebase",
                       "Writeback pipeline — re-platform to Databricks Apps + Lakebase.")
        if value_band == "HIGH":
            return out("Elevate", "ai_bi_genie",
                       "High-value domain — transpile and elevate to Genie / AI-BI / ML.")
        return out("Rebuild", "ai_bi_genie",
                   "Transpile the transform to a Lakeflow pipeline on governed gold.")

    if atype in ("card", "page"):
        if value_band == "HIGH":
            return out("Elevate", "ai_bi_genie",
                       "High-value dashboard — rebuild as AI/BI with Genie.")
        return out("Repoint", "ai_bi_genie",
                   "Keep the visualization; repoint its dataset to the new gold table.")

    return out("", "none", "Derivative asset — disposition follows its pipeline/connector.")


def merge_dispositions(assets: List[Dict[str, Any]],
                       dispositions: Dict[str, Dict[str, Any]]) -> List[Dict[str, Any]]:
    """Attach the saved disposition (if any) onto each asset, in place, and return."""
    for a in assets:
        d = dispositions.get(a.get("id"))
        if d:
            a["disposition"] = d
    return assets


def rollup(dispositions: List[Dict[str, Any]]) -> Dict[str, Any]:
    """Summarize saved dispositions by disposition, target surface, and wave."""
    by_disp: Dict[str, int] = {}
    by_surface: Dict[str, int] = {}
    by_wave: Dict[str, int] = {}
    for d in dispositions:
        by_disp[d.get("disposition", "")] = by_disp.get(d.get("disposition", ""), 0) + 1
        s = d.get("target_surface") or "none"
        by_surface[s] = by_surface.get(s, 0) + 1
        w = str(d.get("assigned_wave") or "unassigned")
        by_wave[w] = by_wave.get(w, 0) + 1
    return {"by_disposition": by_disp, "by_target_surface": by_surface,
            "by_wave": by_wave, "total": len(dispositions)}
