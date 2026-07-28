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
                 profile: str = "") -> Dict[str, Any]:
    """Materialize a deployable DAB for a transpiled lineage.

    Args:
        result:  the dict from transpile pipeline.run() (has result["sql"]).
        out_root: directory to write the bundle into.
        catalog/schema: the configured Databricks target.
        profile: Databricks CLI profile; if set, we also deploy for real.
    """
    lineage = result["lineage"]
    lid = lineage["id"]
    name = re.sub(r"[^a-z0-9_]+", "_", lineage["name"].lower()).strip("_")
    bundle_dir = os.path.join(out_root, f"bundle_{lid}")
    sql_dir = os.path.join(bundle_dir, "src", "sql")
    os.makedirs(sql_dir, exist_ok=True)

    # 1) Write retargeted medallion SQL files.
    written: List[str] = []
    for layer in ("bronze", "silver", "gold", "gold_semantic_metrics"):
        sql = result.get("sql", {}).get(layer)
        if not sql:
            continue
        sql = retarget_sql(sql, catalog, schema_prefix="")
        path = os.path.join(sql_dir, f"{layer}.sql")
        with open(path, "w", encoding="utf-8") as fh:
            fh.write(sql)
        written.append(os.path.relpath(path, bundle_dir))

    # 2) databricks.yml — a DAB with one Lakeflow Declarative Pipeline.
    pipeline_name = f"pseudo_domo_{name}"
    databricks_yml = _databricks_yml(pipeline_name, catalog, schema, written)
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
                    sql_files: List[str]) -> str:
    libs = "\n".join(f"        - file:\n            path: {p}" for p in sql_files)
    return f"""# Databricks Asset Bundle — generated by Pseudo-Domo MCP.
# Deploy:  databricks bundle deploy -p <profile>
bundle:
  name: {pipeline_name}

resources:
  pipelines:
    {pipeline_name}:
      name: {pipeline_name}
      catalog: {catalog}
      schema: {schema}
      serverless: true
      libraries:
{libs}

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
