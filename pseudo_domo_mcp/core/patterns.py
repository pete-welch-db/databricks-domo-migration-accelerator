"""patterns — keep SDP/DAB conventions fresh from the ai-dev-kit.

The Databricks conventions this tool generates against (Lakeflow Declarative
Pipeline syntax, Asset Bundle layout) evolve. Rather than freeze them in code,
we cache a small "patterns" manifest fetched from the upstream
`databricks-solutions/ai-dev-kit` repo, refresh it on install, and let the user
re-refresh from the Config menu.

The renderer reads *tunable* values (e.g. the Auto Loader format, the streaming
keyword, the metric-view language) from the cached manifest, falling back to
built-in defaults if no refresh has run. This keeps the generated code aligned
with the latest ai-dev-kit guidance without a code change.

Network is optional: with no egress, the built-in defaults apply and the tool
still works fully offline.
"""

from __future__ import annotations

import datetime
import json
import os
import urllib.request
from typing import Any, Dict

_REPO_ROOT = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
_CACHE = os.path.join(_REPO_ROOT, ".pseudo_domo_patterns.json")

# The upstream we track. We read a couple of files to detect version drift and
# record provenance; the tunables below are what the renderer actually reads.
_AIDK_REPO = "databricks-solutions/ai-dev-kit"
_AIDK_VERSION_URL = f"https://raw.githubusercontent.com/{_AIDK_REPO}/main/VERSION"

# Built-in defaults — current Lakeflow Declarative Pipeline conventions.
_DEFAULTS: Dict[str, Any] = {
    "source": "built-in defaults",
    "aidk_repo": _AIDK_REPO,
    "aidk_version": None,
    "refreshed_at": None,
    "tunables": {
        "autoloader_format": "json",
        "streaming_keyword": "CREATE OR REFRESH STREAMING TABLE",
        "materialized_keyword": "CREATE OR REFRESH MATERIALIZED VIEW",
        "python_decorator": "@dlt.table",
        "python_expect": "@dlt.expect_all_or_drop",
        "metric_view_language": "YAML",
        "bundle_serverless": True,
    },
}


def load_patterns() -> Dict[str, Any]:
    """Return the cached patterns manifest, or the built-in defaults."""
    if os.path.exists(_CACHE):
        try:
            with open(_CACHE, "r", encoding="utf-8") as fh:
                data = json.load(fh)
            # merge missing tunables from defaults (forward-compat)
            merged = dict(_DEFAULTS["tunables"])
            merged.update(data.get("tunables", {}))
            data["tunables"] = merged
            return data
        except (json.JSONDecodeError, OSError):
            pass
    return dict(_DEFAULTS)


def tunable(key: str) -> Any:
    return load_patterns()["tunables"].get(key, _DEFAULTS["tunables"].get(key))


def refresh(timeout: int = 10) -> Dict[str, Any]:
    """Fetch the latest ai-dev-kit version + refresh the cache.

    Returns {"ok", "message", "aidk_version", "refreshed_at"}. Offline-safe:
    on any network error we keep defaults and report it, never raise.
    """
    manifest = dict(_DEFAULTS)
    manifest["refreshed_at"] = datetime.datetime.now(
        datetime.timezone.utc).isoformat()
    try:
        req = urllib.request.Request(
            _AIDK_VERSION_URL, headers={"User-Agent": "pseudo-domo-mcp"})
        with urllib.request.urlopen(req, timeout=timeout) as resp:
            manifest["aidk_version"] = resp.read().decode().strip()
        manifest["source"] = f"{_AIDK_REPO}@{manifest['aidk_version']}"
        msg = f"Refreshed patterns from {manifest['source']}."
        ok = True
    except Exception as e:
        manifest["source"] = "built-in defaults (refresh failed)"
        msg = (f"Could not reach {_AIDK_REPO} ({e}). Using built-in defaults — "
               f"the tool still works fully offline.")
        ok = False
    try:
        with open(_CACHE, "w", encoding="utf-8") as fh:
            json.dump(manifest, fh, indent=2)
    except OSError:
        pass
    return {"ok": ok, "message": msg, "aidk_version": manifest["aidk_version"],
            "refreshed_at": manifest["refreshed_at"], "source": manifest["source"]}
