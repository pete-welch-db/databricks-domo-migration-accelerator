"""bundle — the progressive "Create" step.

Given a transpiled lineage, write a deployable **Databricks Asset Bundle**
(DAB) to disk: the medallion Spark SQL + a Lakeflow Declarative Pipeline
(pipeline) definition + a `databricks.yml`. Then:

  * always  — files are written locally and the exact `databricks bundle deploy`
              command is returned (works with zero workspace access);
  * if a Databricks CLI profile is configured — we additionally shell out to
    `databricks bundle deploy -p <profile>` to create the pipeline for real.

The transpiler emits SQL against its own default catalog/schema; we retarget
that text to the UI-configured catalog/schema here (a scoped string rewrite of
the fully-qualified names) rather than forking the vendored agent.
"""

from __future__ import annotations

import os
import re
import shutil
import subprocess
from typing import Any, Dict, List

# The transpiler's built-in identifiers (emit.py module constants).
_SRC_CATALOG = "domo_migration"
_SRC_SCHEMAS = ("raw", "bronze", "silver", "gold")


def retarget_sql(sql: str, catalog: str, schema_prefix: str = "") -> str:
    """Rewrite `domo_migration.<layer>.` -> `<catalog>.<layer>.` in emitted SQL.

    We keep the medallion layer schemas (bronze/silver/gold/raw) so the target
    stays a clean medallion; only the catalog is swapped to the configured one.
    If `schema_prefix` is given, layers become `<prefix>_<layer>` (lets a
    customer land everything under one schema when they lack multi-schema DDL).
    """
    out = sql
    for layer in _SRC_SCHEMAS:
        src = f"{_SRC_CATALOG}.{layer}."
        if schema_prefix:
            dst = f"{catalog}.{schema_prefix}_{layer}."
        else:
            dst = f"{catalog}.{layer}."
        out = out.replace(src, dst)
    return out


def write_bundle(result: Dict[str, Any], out_root: str,
                 catalog: str, schema: str,
                 profile: str = "", language: str = "sql",
                 mapping: Dict[str, Any] = None,
                 build_targets: List[str] = None,
                 orchestration: Dict[str, Any] = None,
                 connectors: List[Dict[str, Any]] = None) -> Dict[str, Any]:
    """Materialize a deployable DAB for a transpiled lineage.

    Args:
        result:  the dict from transpile pipeline.run() (has result["sql"]).
        out_root: directory to write the bundle into.
        catalog/schema: the configured Databricks target.
        profile: Databricks CLI profile; if set, we also deploy for real.
        language: "sql" | "python" — the SDP source language to emit.
        build_targets: which artifacts to generate (defaults to ["etl_pipeline"]).
            Any of: etl_pipeline · metric_views · ai_bi_dashboard · genie_space ·
            databricks_workflow · uc_ingestion.
        orchestration: orchestration graph (for databricks_workflow).
        connectors: connector assets (for uc_ingestion).
    """
    from . import sdp  # local import avoids a cycle
    from .generators import (DEFAULT_TARGETS, metric_views as gen_mv,
                             dashboard as gen_dash, genie as gen_genie,
                             workflow as gen_wf, ingestion as gen_ing)
    targets = build_targets or DEFAULT_TARGETS
    lineage = result["lineage"]
    lid = lineage["id"]
    name = re.sub(r"[^a-z0-9_]+", "_", lineage["name"].lower()).strip("_")
    bundle_dir = os.path.join(out_root, f"bundle_{lid}")
    ext = "py" if language == "python" else "sql"
    src_dir = os.path.join(bundle_dir, "src", "pipeline")
    os.makedirs(src_dir, exist_ok=True)
    structured = result.get("structured") or {}
    gold_fqn = retarget_sql(structured.get("gold_view_fqn", f"{catalog}.gold.{name}"), catalog)
    gold_cols = structured.get("gold_schema", [])

    def _write(rel, content):
        path = os.path.join(bundle_dir, rel)
        os.makedirs(os.path.dirname(path), exist_ok=True)
        with open(path, "w", encoding="utf-8") as fh:
            fh.write(content)
        written.append(rel)

    written: List[str] = []
    pipeline_name = f"pseudo_domo_{name}"
    has_workflow = "databricks_workflow" in targets and orchestration

    # 1) ETL pipeline — the real SDP source, retargeted to the configured catalog.
    if "etl_pipeline" in targets:
        sdp_code = retarget_sql(sdp.render(result, language, mapping=mapping), catalog)
        _write(os.path.join("src", "pipeline", f"pipeline.{ext}"), sdp_code)
    # 2) Standalone metric views (Beast Modes).
    if "metric_views" in targets:
        _write(os.path.join("src", "metric_views", f"{name}.sql"),
               retarget_sql(gen_mv.render(result), catalog))
    # 3) AI/BI dashboard (.lvdash.json).
    if "ai_bi_dashboard" in targets:
        _write(os.path.join("src", "dashboards", f"{name}.lvdash.json"),
               gen_dash.render(gold_fqn, gold_cols, lineage["name"]))
    # 4) Genie space definition.
    if "genie_space" in targets:
        _write(os.path.join("src", "genie", f"{name}.genie.yml"),
               gen_genie.render(gold_fqn, gold_cols, lineage["name"]))
    # 5) Databricks Workflow from the orchestration graph.
    if has_workflow:
        _write(os.path.join("resources", "orchestration.job.yml"),
               gen_wf.render(orchestration, f"{pipeline_name}_orchestration"))
    # 6) UC ingestion scaffolding per connector.
    if "uc_ingestion" in targets and connectors:
        for c in connectors:
            for rel, content in gen_ing.render_connector(c, catalog, schema).items():
                _write(rel, content)

    # databricks.yml — pipelines (if etl) + include resources/*.yml (if workflow).
    databricks_yml = _databricks_yml(pipeline_name, catalog, schema, written, targets, has_workflow)
    with open(os.path.join(bundle_dir, "databricks.yml"), "w", encoding="utf-8") as fh:
        fh.write(databricks_yml)

    # 3) A README with the exact deploy command.
    deploy_cmd = f"databricks bundle deploy" + (f" -p {profile}" if profile else "")
    run_cmd = f"databricks bundle run {pipeline_name}" + (f" -p {profile}" if profile else "")
    with open(os.path.join(bundle_dir, "README.md"), "w", encoding="utf-8") as fh:
        fh.write(_bundle_readme(lineage, catalog, schema, deploy_cmd, run_cmd))

    out = {
        "bundle_dir": bundle_dir,
        "pipeline_name": pipeline_name,
        "catalog": catalog,
        "schema": schema,
        "sql_files": written,
        "deploy_command": deploy_cmd,
        "run_command": run_cmd,
        "deployed": False,
        "deploy_log": "",
    }

    # 4) Progressive deploy — only if a profile is configured AND the CLI exists.
    if profile:
        out.update(_deploy(bundle_dir, profile))
    else:
        out["deploy_log"] = ("No Databricks profile configured — wrote bundle "
                             "files only. Configure a profile (databricks auth "
                             "login) then click Create again to deploy.")
    return out


def _deploy(bundle_dir: str, profile: str) -> Dict[str, Any]:
    if shutil.which("databricks") is None:
        return {"deployed": False,
                "deploy_log": "databricks CLI not found on PATH; bundle written "
                              "but not deployed."}
    try:
        proc = subprocess.run(
            ["databricks", "bundle", "deploy", "-p", profile],
            cwd=bundle_dir, capture_output=True, text=True, timeout=300,
            stdin=subprocess.DEVNULL,
        )
        ok = proc.returncode == 0
        return {"deployed": ok,
                "deploy_log": (proc.stdout + proc.stderr).strip()[-4000:]}
    except (subprocess.TimeoutExpired, OSError) as e:
        return {"deployed": False, "deploy_log": f"deploy error: {e}"}


def _databricks_yml(pipeline_name: str, catalog: str, schema: str,
                    written: List[str], targets: List[str] = None,
                    has_workflow: bool = False) -> str:
    targets = targets or ["etl_pipeline"]
    include = "\ninclude:\n  - resources/*.yml\n" if has_workflow else ""
    pipelines = ""
    if "etl_pipeline" in targets:
        pipe_libs = [p for p in written if p.startswith(os.path.join("src", "pipeline"))]
        libs = "\n".join(f"        - file:\n            path: {p}" for p in pipe_libs)
        pipelines = f"""
resources:
  pipelines:
    {pipeline_name}:
      name: {pipeline_name}
      catalog: {catalog}
      schema: {schema}
      serverless: true
      libraries:
{libs}
"""
    return f"""# Databricks Asset Bundle — generated by the Domo Migration Accelerator.
# Deploy:  databricks bundle deploy -p <profile>
bundle:
  name: {pipeline_name}
{include}{pipelines}
targets:
  dev:
    default: true
"""


def _bundle_readme(lineage, catalog, schema, deploy_cmd, run_cmd) -> str:
    return f"""# {lineage['name']} — generated SDP pipeline

Generated by the Pseudo-Domo MCP operator UI from Domo lineage
`{lineage['id']}`.

- **Target:** `{catalog}.{schema}`
- **Value driver:** {lineage.get('value_driver') or 'n/a'} ({lineage.get('value_per_year') or 'n/a'})

## Deploy

```bash
{deploy_cmd}
{run_cmd}
```

`src/sql/` holds the bronze → silver → gold medallion plus the
`gold_semantic_metrics.sql` view that reproduces the Domo card's Beast Modes.
The gold view is schema-parity-matched to the original Domo DataSet so a
connector swap is transparent to every bound card.
"""
