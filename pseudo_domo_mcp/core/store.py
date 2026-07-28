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
from abc import ABC, abstractmethod
from typing import Any, Dict, List

_REPO_ROOT = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
_LOCAL_PATH = os.path.join(_REPO_ROOT, ".pseudo_domo_state.json")

# Every table prefixed to stay tidy in a shared Lakebase (matches common
# Lakebase conventions of namespacing app tables).
_TABLES = ("scans", "asset_status", "mappings", "bundles")


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
        self._fallback = LocalStore()
        self._ok = False

    def _connect(self):
        if self._conn is not None:
            return self._conn
        try:
            import psycopg  # noqa: F401
            from databricks.sdk import WorkspaceClient
            w = WorkspaceClient()
            inst = w.database.get_database_instance(name=self.instance)
            cred = w.database.generate_database_credential(
                instance_names=[self.instance])
            import psycopg
            self._conn = psycopg.connect(
                host=inst.read_write_dns, dbname="databricks_postgres",
                user=w.current_user.me().user_name, password=cred.token,
                sslmode="require", autocommit=True)
            self._ensure_tables()
            self._ok = True
            return self._conn
        except Exception:
            # Any failure (no SDK, no psycopg, unreachable) → local fallback.
            self._ok = False
            return None

    def _ensure_tables(self):
        with self._conn.cursor() as cur:
            for t in _TABLES:
                cur.execute(
                    f"CREATE TABLE IF NOT EXISTS pseudo_domo_{t} "
                    f"(key TEXT PRIMARY KEY DEFAULT gen_random_uuid()::text, "
                    f"record JSONB NOT NULL, ts TIMESTAMPTZ DEFAULT now())")

    def append(self, collection, record):
        if self._connect() is None:
            return self._fallback.append(collection, record)
        with self._conn.cursor() as cur:
            cur.execute(f"INSERT INTO pseudo_domo_{collection} (record) VALUES (%s)",
                        (json.dumps(record),))

    def put(self, collection, key, record):
        if self._connect() is None:
            return self._fallback.put(collection, key, record)
        with self._conn.cursor() as cur:
            cur.execute(
                f"INSERT INTO pseudo_domo_{collection} (key, record) VALUES (%s, %s) "
                f"ON CONFLICT (key) DO UPDATE SET record = EXCLUDED.record",
                (key, json.dumps(record)))

    def list(self, collection):
        if self._connect() is None:
            return self._fallback.list(collection)
        with self._conn.cursor() as cur:
            cur.execute(f"SELECT record FROM pseudo_domo_{collection} ORDER BY ts")
            return [r[0] for r in cur.fetchall()]

    def backend(self):
        return "lakebase" if self._ok else "local (lakebase unavailable)"


# --------------------------------------------------------------------------- #
def get_store() -> StateStore:
    """Build the configured store (imported here to avoid a config cycle)."""
    from .config import load_config
    cfg = load_config()
    if cfg.store_backend == "lakebase" and cfg.lakebase_instance:
        return LakebaseStore(cfg.lakebase_instance)
    return LocalStore()
