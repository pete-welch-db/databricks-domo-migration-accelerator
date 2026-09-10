"""config — runtime configuration for the operator UI.

Nothing is hardcoded to a workspace or tenant: the customer downloads the repo,
stands up the app, and configures everything here (persisted to a local JSON
file next to the repo). Two auth surfaces:

  * Databricks workspace — a CLI **profile** (set up via `databricks auth login`,
    OAuth U2M/M2M). The Create step shells out to the `databricks` CLI, which
    handles the OAuth token, so we never store workspace secrets here.
  * Domo tenant — OAuth2 **client_credentials** (client_id + client_secret ->
    short-lived bearer). We store the client id here and read the secret from
    the environment (DOMO_CLIENT_SECRET) so a secret never lands in the file.

Config is layered: file values <- environment overrides. The env keys mirror
the MCP server's (PSEUDO_DOMO_*) so the two stay consistent.
"""

from __future__ import annotations

import json
import os
from dataclasses import asdict, dataclass, field
from typing import Any, Dict

_REPO_ROOT = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
_CONFIG_PATH = os.path.join(_REPO_ROOT, ".pseudo_domo_config.json")


@dataclass
class AppConfig:
    # Target Databricks objects for generated pipelines.
    catalog: str = "domo_migration"
    schema: str = "aftermarket"
    # Databricks workspace. The CLI profile encodes host + auth; the host is
    # also surfaced explicitly for display and the App/API deploy path.
    databricks_profile: str = ""
    databricks_host: str = ""               # https://<workspace>.cloud.databricks.com
    # Domo provider selection + OAuth client id (secret stays in env).
    domo_provider: str = "fixture"          # "fixture" | "live"
    domo_client_id: str = ""
    domo_api_host: str = "https://api.domo.com"
    # Generated-pipeline language: SDP in SQL or Python notebooks.
    pipeline_language: str = "sql"          # "sql" | "python"
    # Which industry data model(s) to draft-map onto (universal; references the
    # vendored Databricks Industry Data Models). Comma-separated keys.
    industry_models: str = "automotive"
    # Optional version control for generated bundles (token stays in env).
    git_provider: str = ""                  # "" | "github" | "azure_devops"
    git_repo: str = ""                      # owner/name  OR  org/project/repo
    # Persistence backend for scan history / migration status / mappings.
    store_backend: str = "local"            # "local" | "lakebase"
    lakebase_instance: str = ""             # Lakebase instance name (if used)
    # OPTIONAL LLM enhancement via a Databricks model serving endpoint. Empty =
    # off (tool stays fully deterministic/offline). Token from DATABRICKS_TOKEN.
    llm_endpoint: str = ""                  # serving endpoint name

    def public(self) -> Dict[str, Any]:
        """Config safe to send to the browser (no secrets are stored here,
        but we still surface whether required tokens are present in env)."""
        d = asdict(self)
        d["domo_secret_present"] = bool(os.environ.get("DOMO_CLIENT_SECRET"))
        d["git_token_present"] = bool(os.environ.get("GIT_TOKEN"))
        d["deploy_ready"] = bool(self.databricks_profile)
        # Mirror llm.enabled(): in an App the SP token is minted via the SDK, so
        # DATABRICKS_TOKEN is not required. Keep both reports consistent.
        from .runtime import is_app
        has_token = bool(os.environ.get("DATABRICKS_TOKEN")) or is_app()
        d["llm_enabled"] = bool(
            self.llm_endpoint
            and (self.databricks_host or os.environ.get("DATABRICKS_HOST"))
            and has_token)
        return d


def _load_persisted() -> Dict[str, Any]:
    """User-editable prefs from wherever they live for this runtime.

    Local: a JSON file next to the repo. App: the shared store (Lakebase) —
    an App's filesystem is ephemeral and per-replica, so a file would not
    survive a restart or be shared across replicas. The store's backend is
    chosen from env in app mode (see store.get_store), so there is no cycle.
    """
    from .runtime import is_app
    if is_app():
        try:
            from .store import get_store
            rows = get_store().list("config")
            latest = rows[-1] if rows else None
            return latest if isinstance(latest, dict) else {}
        except Exception:
            return {}
    if os.path.exists(_CONFIG_PATH):
        try:
            with open(_CONFIG_PATH, "r", encoding="utf-8") as fh:
                data = json.load(fh)
            # Tolerate a corrupt/hand-edited/older-format file that isn't an
            # object — fall back to defaults rather than crashing every request.
            return data if isinstance(data, dict) else {}
        except (json.JSONDecodeError, OSError):
            return {}
    return {}


def load_config() -> AppConfig:
    cfg = AppConfig()
    for k, v in _load_persisted().items():
        if hasattr(cfg, k):
            setattr(cfg, k, v)
    # Environment overrides (keep parity with the MCP server env). In an App
    # these carry the infra config (store backend, Lakebase instance, serving
    # endpoint, host) injected via app.yaml + the App runtime.
    cfg.catalog = os.environ.get("PSEUDO_DOMO_CATALOG", cfg.catalog)
    cfg.schema = os.environ.get("PSEUDO_DOMO_SCHEMA", cfg.schema)
    cfg.databricks_profile = os.environ.get("DATABRICKS_CONFIG_PROFILE",
                                            cfg.databricks_profile)
    cfg.domo_provider = os.environ.get("PSEUDO_DOMO_PROVIDER", cfg.domo_provider)
    cfg.store_backend = os.environ.get("PSEUDO_DOMO_STORE_BACKEND", cfg.store_backend)
    cfg.lakebase_instance = os.environ.get("PSEUDO_DOMO_LAKEBASE_INSTANCE",
                                           cfg.lakebase_instance)
    cfg.llm_endpoint = os.environ.get(
        "PSEUDO_DOMO_LLM_ENDPOINT",
        os.environ.get("SERVING_ENDPOINT", cfg.llm_endpoint))
    # Apps inject DATABRICKS_HOST as a bare hostname (no scheme); llm.py adds it.
    cfg.databricks_host = os.environ.get("DATABRICKS_HOST", cfg.databricks_host)
    return cfg


def save_config(updates: Dict[str, Any]) -> AppConfig:
    cfg = load_config()
    for k, v in updates.items():
        if hasattr(cfg, k) and k != "domo_client_secret":
            setattr(cfg, k, v)
    from .runtime import is_app
    data = asdict(cfg)
    if is_app():
        try:
            from .store import get_store
            get_store().put("config", "current", data)
        except Exception:
            pass  # never block the UI on a persistence hiccup
    else:
        with open(_CONFIG_PATH, "w", encoding="utf-8") as fh:
            json.dump(data, fh, indent=2)
        # A backend/instance change here must rebuild the memoized store.
        try:
            from .store import get_store
            get_store.cache_clear()
        except Exception:
            pass
    return cfg
