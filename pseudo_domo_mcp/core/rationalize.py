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
TARGET_SURFACES = [
    {"key": "ai_bi_genie", "label": "AI/BI + Genie"},
    {"key": "genie_app_builder", "label": "Genie App Builder"},
    {"key": "sigma_input_tables", "label": "Sigma Input Tables"},
    {"key": "apps_lakebase", "label": "Databricks Apps + Lakebase"},
    {"key": "none", "label": "None (retire)"},
]


def _has_writeback(asset: Dict[str, Any]) -> bool:
    text = " ".join((asset.get("complexity") or {}).get("drivers", [])
                    + (asset.get("effort") or {}).get("factors", [])).lower()
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

    # Low usage + low value → retire, regardless of type (the dead-weight cull).
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

    if atype == "beast_mode":
        return out("Elevate", "ai_bi_genie",
                   "Fold this calc field into a governed Unity Catalog metric view.")

    # datasets / connectors are derivative (produced by / ingested via a pipeline).
    return out("", "", "Derivative asset — disposition follows its pipeline/connector.")


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
