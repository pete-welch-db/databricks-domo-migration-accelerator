"""store — pluggable persistence for scan history, migration status, mappings.

Two backends, chosen in config (`store_backend`):

  local     — a JSON file next to the repo (default). Zero setup; the
              download-and-run story survives.
  lakebase  — a Databricks Lakebase (managed Postgres) instance, for teams that
              want durable, shared, multi-user state. Requires
              `lakebase_instance` in config + the Databricks SDK to mint a token.

Both implement the same StateStore interface, so the app code never branches on
backend. The store records:
  * scans          — one row per discovery scan (when, counts)
  * asset_status   — per-asset migration status (assessed / drafted / built / deployed)
  * mappings       — accepted industry-model column mappings (human decisions)
  * bundles        — generated bundle registry (path, pipeline, target, deployed)

The Lakebase backend is written against psycopg (v3). If it's unavailable or the
instance can't be reached, callers fall back to local so a DB hiccup never
blocks assessment work.
"""

from __future__ import annotations

import json
import os
import threading
import time
from abc import ABC, abstractmethod
from functools import lru_cache
from typing import Any, Dict, List

# Recycle a Lakebase connection before its 1-hour OAuth token expires.
_CONN_MAX_AGE_S = 2700  # 45 min

_REPO_ROOT = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
_LOCAL_PATH = os.path.join(_REPO_ROOT, ".pseudo_domo_state.json")

# Every table prefixed to stay tidy in a shared Lakebase (matches common
# Lakebase conventions of namespacing app tables).
_TABLES = ("scans", "asset_status", "mappings", "bundles",
           "filter_sets", "rationalizations", "config")


class StateStore(ABC):
    @abstractmethod
    def append(self, collection: str, record: Dict[str, Any]) -> None: ...
    @abstractmethod
    def put(self, collection: str, key: str, record: Dict[str, Any]) -> None: ...
    @abstractmethod
    def list(self, collection: str) -> List[Dict[str, Any]]: ...
    @abstractmethod
    def backend(self) -> str: ...


# --------------------------------------------------------------------------- #
class LocalStore(StateStore):
    """JSON-file store. Append-only lists + keyed dicts, atomic-ish writes."""

    def __init__(self, path: str = _LOCAL_PATH):
        self.path = path
        self._lock = threading.Lock()

    def _read(self) -> Dict[str, Any]:
        if not os.path.exists(self.path):
            return {"scans": [], "asset_status": {}, "mappings": {}, "bundles": []}
        try:
            with open(self.path, "r", encoding="utf-8") as fh:
                return json.load(fh)
        except (json.JSONDecodeError, OSError):
            return {"scans": [], "asset_status": {}, "mappings": {}, "bundles": []}

    def _write(self, data: Dict[str, Any]) -> None:
        tmp = self.path + ".tmp"
        with open(tmp, "w", encoding="utf-8") as fh:
            json.dump(data, fh, indent=2)
        os.replace(tmp, self.path)

    def append(self, collection, record):
        with self._lock:
            d = self._read(); d.setdefault(collection, []).append(record); self._write(d)

    def put(self, collection, key, record):
        with self._lock:
            d = self._read(); d.setdefault(collection, {})[key] = record; self._write(d)

    def list(self, collection):
        d = self._read().get(collection, [])
        return d if isinstance(d, list) else list(d.values())

    def backend(self):
        return "local"


# --------------------------------------------------------------------------- #
class LakebaseStore(StateStore):
    """Databricks Lakebase (Postgres) store. Lazy-connects; degrades to local.

    Tables are created on first use. Auth: the Databricks SDK mints a short-lived
    OAuth token for the Lakebase instance (no static password stored).
    """

    def __init__(self, instance: str):
        self.instance = instance
        self._conn = None
        self._born = 0.0        # monotonic time the current connection opened
        self._fallback = LocalStore()
        self._ok = False
        self.last_error = ""    # last connect failure, for diagnostics
        # One connection is reused across requests (the store is a process
        # singleton — see get_store), so serialize access: a psycopg3
        # connection is not safe for concurrent use from FastAPI's threadpool.
        self._lock = threading.Lock()

    def _connect(self):
        # Reuse a live, non-expired connection; otherwise (re)connect with a
        # fresh token. Recycling before the token TTL avoids a stale-token
        # failure on a long-lived App process.
        if (self._conn is not None and not self._conn.closed
                and (time.monotonic() - self._born) < _CONN_MAX_AGE_S):
            return self._conn
        if self._conn is not None:
            try:
                self._conn.close()
            except Exception:
                pass
            self._conn = None
        try:
            import psycopg
            from databricks.sdk import WorkspaceClient
            w = WorkspaceClient()
            # A short-lived OAuth token for the instance (works for a user via
            # U2M locally, or the App's service principal remotely).
            cred = w.database.generate_database_credential(
                instance_names=[self.instance])
            # Connection coordinates. When the App has a Database resource
            # attached, the runtime injects PG* — prefer those; otherwise
            # derive them from the instance + caller identity.
            host = os.environ.get("PGHOST") or \
                w.database.get_database_instance(name=self.instance).read_write_dns
            user = os.environ.get("PGUSER") or w.current_user.me().user_name
            dbname = os.environ.get("PGDATABASE", "databricks_postgres")
            port = os.environ.get("PGPORT", "5432")
            self._conn = psycopg.connect(
                host=host, port=port, dbname=dbname,
                user=user, password=cred.token,
                sslmode=os.environ.get("PGSSLMODE", "require"), autocommit=True)
            self._ensure_tables()
            self._ok = True
            self._born = time.monotonic()
            self.last_error = ""
            return self._conn
        except Exception as e:
            # Any failure (no SDK, no psycopg, unreachable, no role) → local.
            self._ok = False
            self.last_error = f"{type(e).__name__}: {e}"
            return None

    def _ensure_tables(self):
        with self._conn.cursor() as cur:
            for t in _TABLES:
                cur.execute(
                    f"CREATE TABLE IF NOT EXISTS pseudo_domo_{t} "
                    f"(key TEXT PRIMARY KEY DEFAULT gen_random_uuid()::text, "
                    f"record JSONB NOT NULL, ts TIMESTAMPTZ DEFAULT now())")

    def append(self, collection, record):
        with self._lock:
            if self._connect() is None:
                return self._fallback.append(collection, record)
            with self._conn.cursor() as cur:
                cur.execute(f"INSERT INTO pseudo_domo_{collection} (record) VALUES (%s)",
                            (json.dumps(record),))

    def put(self, collection, key, record):
        with self._lock:
            if self._connect() is None:
                return self._fallback.put(collection, key, record)
            with self._conn.cursor() as cur:
                cur.execute(
                    f"INSERT INTO pseudo_domo_{collection} (key, record) VALUES (%s, %s) "
                    f"ON CONFLICT (key) DO UPDATE SET record = EXCLUDED.record",
                    (key, json.dumps(record)))

    def list(self, collection):
        with self._lock:
            if self._connect() is None:
                return self._fallback.list(collection)
            with self._conn.cursor() as cur:
                cur.execute(f"SELECT record FROM pseudo_domo_{collection} ORDER BY ts")
                return [r[0] for r in cur.fetchall()]

    def backend(self):
        return "lakebase" if self._ok else "local (lakebase unavailable)"


# --------------------------------------------------------------------------- #
@lru_cache(maxsize=1)
def get_store() -> StateStore:
    """Build the configured store, memoized to a process singleton.

    Memoizing matters for the Lakebase backend: without it every load_config()
    (several per request) would open — and leak — a fresh connection. The
    singleton reuses one connection (recycled before token expiry, guarded by a
    lock). Call get_store.cache_clear() when the backend selection changes.

    In an App the backend + instance come straight from injected env, so this
    never calls load_config (which itself reads the store for user prefs — that
    would recurse). Locally the choice comes from the persisted config file.
    """
    from .runtime import is_app
    if is_app():
        backend = os.environ.get("PSEUDO_DOMO_STORE_BACKEND", "lakebase")
        instance = os.environ.get("PSEUDO_DOMO_LAKEBASE_INSTANCE", "")
        if backend == "lakebase" and instance:
            return LakebaseStore(instance)
        return LocalStore()
    from .config import load_config
    cfg = load_config()
    if cfg.store_backend == "lakebase" and cfg.lakebase_instance:
        return LakebaseStore(cfg.lakebase_instance)
    return LocalStore()
