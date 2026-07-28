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
    # Databricks workspace CLI profile (empty = local artifacts only).
    databricks_profile: str = ""
    # Domo provider selection + OAuth client id (secret stays in env).
    domo_provider: str = "fixture"          # "fixture" | "live"
    domo_client_id: str = ""
    domo_api_host: str = "https://api.domo.com"

    def public(self) -> Dict[str, Any]:
        """Config safe to send to the browser (no secrets are stored here,
        but we still surface whether the Domo secret is present in env)."""
        d = asdict(self)
        d["domo_secret_present"] = bool(os.environ.get("DOMO_CLIENT_SECRET"))
        d["deploy_ready"] = bool(self.databricks_profile)
        return d


def load_config() -> AppConfig:
    cfg = AppConfig()
    if os.path.exists(_CONFIG_PATH):
        try:
            with open(_CONFIG_PATH, "r", encoding="utf-8") as fh:
                data = json.load(fh)
            for k, v in data.items():
                if hasattr(cfg, k):
                    setattr(cfg, k, v)
        except (json.JSONDecodeError, OSError):
            pass
    # Environment overrides (keep parity with the MCP server env).
    cfg.catalog = os.environ.get("PSEUDO_DOMO_CATALOG", cfg.catalog)
    cfg.schema = os.environ.get("PSEUDO_DOMO_SCHEMA", cfg.schema)
    cfg.databricks_profile = os.environ.get("DATABRICKS_CONFIG_PROFILE",
                                            cfg.databricks_profile)
    cfg.domo_provider = os.environ.get("PSEUDO_DOMO_PROVIDER", cfg.domo_provider)
    return cfg


def save_config(updates: Dict[str, Any]) -> AppConfig:
    cfg = load_config()
    for k, v in updates.items():
        if hasattr(cfg, k) and k != "domo_client_secret":
            setattr(cfg, k, v)
    with open(_CONFIG_PATH, "w", encoding="utf-8") as fh:
        json.dump(asdict(cfg), fh, indent=2)
    return cfg
