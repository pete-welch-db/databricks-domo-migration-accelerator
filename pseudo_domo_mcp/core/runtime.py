"""runtime — detect where the app is running (local laptop vs Databricks App).

One codebase serves both surfaces. The download-and-run local story is the
default; when the same code runs inside a Databricks App, a few seams flip:

  * config     — persisted to the shared store (Lakebase) instead of a local
                 JSON file, since an App's filesystem is ephemeral + per-replica.
  * store      — backend/instance come from injected env, not the config file.
  * llm        — OAuth token comes from the App's service principal (SDK),
                 not a static DATABRICKS_TOKEN.
  * webapp     — binds 0.0.0.0 on the App-provided port, not 127.0.0.1:8010.

Detection: the Databricks Apps runtime injects DATABRICKS_APP_NAME. Nothing
else changes, so local behaviour is untouched.
"""

from __future__ import annotations

import os


def is_app() -> bool:
    """True when running inside a Databricks App (runtime sets DATABRICKS_APP_NAME)."""
    return bool(os.environ.get("DATABRICKS_APP_NAME"))


def mode() -> str:
    return "app" if is_app() else "local"


def bind_host() -> str:
    """Host to bind the web server to (Apps must listen on all interfaces)."""
    return "0.0.0.0" if is_app() else "127.0.0.1"


def bind_port(default_local: int = 8010, default_app: int = 8000) -> int:
    """Port for the web server. Apps provide DATABRICKS_APP_PORT (or we honor a
    PORT set in app.yaml); locally we keep the historical 8010."""
    env = os.environ.get("DATABRICKS_APP_PORT") or os.environ.get("PORT")
    if env:
        return int(env)
    return default_app if is_app() else default_local
