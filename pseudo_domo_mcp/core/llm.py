"""llm — OPTIONAL LLM enhancement via a Databricks model serving endpoint.

The tool is fully deterministic and works 100% offline. When the user points it
at a Databricks model serving endpoint (in Config), that model can *enhance*
certain steps — but never replace the deterministic result, and never block:

  * explain_governance   — a natural-language rationale for a governance call
  * suggest_mapping       — a second opinion on an ambiguous industry-model column map
  * translate_sql_flow    — a first-draft Spark SQL translation of a SQL DataFlow
  * review_beast_mode     — sanity-check a Beast Mode → Spark expression

Design rules:
  * Off by default. `enabled()` is False unless a serving endpoint is configured.
  * Every helper takes a deterministic `fallback` and returns it on ANY error
    (unset, unreachable, bad response) — the tool never degrades.
  * Auth: the serving host + endpoint name come from config; the token comes
    from DATABRICKS_TOKEN in the environment (never stored). Uses the
    OpenAI-compatible chat route Databricks serving exposes.

No new dependencies — plain urllib.
"""

from __future__ import annotations

import json
import os
import urllib.request
from typing import Any, Callable, Dict, List, Optional


def _cfg():
    from .config import load_config
    return load_config()


def enabled() -> bool:
    c = _cfg()
    return bool(c.llm_endpoint and (c.databricks_host or os.environ.get("DATABRICKS_HOST"))
               and os.environ.get("DATABRICKS_TOKEN"))


def status() -> Dict[str, Any]:
    c = _cfg()
    return {
        "enabled": enabled(),
        "endpoint": c.llm_endpoint or None,
        "host_present": bool(c.databricks_host or os.environ.get("DATABRICKS_HOST")),
        "token_present": bool(os.environ.get("DATABRICKS_TOKEN")),
    }


def _chat(messages: List[Dict[str, str]], max_tokens: int = 500) -> Optional[str]:
    """Call the serving endpoint's OpenAI-compatible chat route. None on failure."""
    c = _cfg()
    host = (c.databricks_host or os.environ.get("DATABRICKS_HOST", "")).rstrip("/")
    token = os.environ.get("DATABRICKS_TOKEN", "")
    if not (host and token and c.llm_endpoint):
        return None
    url = f"{host}/serving-endpoints/{c.llm_endpoint}/invocations"
    body = json.dumps({"messages": messages, "max_tokens": max_tokens}).encode()
    req = urllib.request.Request(
        url, data=body, method="POST",
        headers={"Authorization": f"Bearer {token}", "Content-Type": "application/json"})
    try:
        with urllib.request.urlopen(req, timeout=30) as resp:
            data = json.loads(resp.read().decode())
        return data["choices"][0]["message"]["content"].strip()
    except Exception:
        return None


def _enhance(prompt_sys: str, prompt_user: str, fallback: Any) -> Any:
    """Run a chat completion, returning its text or the deterministic fallback."""
    if not enabled():
        return fallback
    out = _chat([{"role": "system", "content": prompt_sys},
                 {"role": "user", "content": prompt_user}])
    return out if out else fallback


# --------------------------------------------------------------------------- #
# Enhancement helpers — each ALWAYS returns something usable.
# --------------------------------------------------------------------------- #
def explain_governance(name: str, signals: List[str], label: str, fallback: str = "") -> str:
    return _enhance(
        "You are a Databricks migration assistant. In 1-2 sentences, explain "
        "plainly why this Domo asset is classified as its governance type. Be "
        "concise and non-committal; this is a draft signal.",
        f"Asset: {name}\nClassification: {label}\nSignals:\n- " + "\n- ".join(signals),
        fallback or "; ".join(signals))


def review_beast_mode(name: str, domo_expr: str, spark_expr: str, fallback: str) -> str:
    return _enhance(
        "You are a Spark SQL expert. Given a Domo Beast Mode expression and a "
        "proposed Spark SQL translation, reply with either 'OK' or a corrected "
        "Spark SQL expression. Output only the expression, no prose.",
        f"Beast Mode '{name}'\nDomo: {domo_expr}\nProposed Spark: {spark_expr}",
        fallback)


def translate_sql_flow(sql: str, target_cols: List[str], fallback: str = "") -> str:
    return _enhance(
        "You translate MySQL/Redshift-dialect SQL to Databricks Spark SQL. "
        "Output only the translated SQL, no prose.",
        f"Translate to Spark SQL (target columns: {', '.join(target_cols)}):\n{sql}",
        fallback or f"-- TODO: hand-translate to Spark SQL\n{sql}")


def suggest_mapping(domo_col: str, domo_type: str, candidates: List[str],
                    fallback: str) -> str:
    return _enhance(
        "You map source columns to a canonical data model. Given a Domo column "
        "and candidate target columns, reply with the single best target name "
        "only, or 'NONE'.",
        f"Domo column: {domo_col} ({domo_type})\nCandidates: {', '.join(candidates)}",
        fallback)
