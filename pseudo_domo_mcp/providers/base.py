"""DomoProvider — the read contract every provider implements.

Kept deliberately small: the discovery/assessment tools only ever need to
*list* and *get* the five Domo object families. Anything richer (a full Magic
ETL export, Beast Mode expressions) is fetched per-lineage through
`get_lineage_triplet`, which is the only call that needs the private/export
API in production.
"""

from __future__ import annotations

from abc import ABC, abstractmethod
from typing import Any, Dict, List, Optional


class DomoProvider(ABC):
    """Abstract read surface over a Domo tenant (or a synthetic stand-in)."""

    @abstractmethod
    def list_datasets(self) -> List[Dict[str, Any]]:
        """Public DataSet API shape: id, name, description, rows, columns,
        owner, dataCurrentAt, created/updatedAt, pdpEnabled (+ enrichment)."""

    @abstractmethod
    def list_dataflows(self) -> List[Dict[str, Any]]:
        """DataFlow census: id, name, databaseType (MAGIC|SQL), input/output
        dataset ids, actionCount, owner, runCadence."""

    @abstractmethod
    def list_cards(self) -> List[Dict[str, Any]]:
        """Card census: id, title, type, pageId, boundDatasetIds,
        beastModeCount."""

    @abstractmethod
    def list_pages(self) -> List[Dict[str, Any]]:
        """Page census: id, name, owner, cardIds."""

    @abstractmethod
    def get_lineage_triplet(self, lineage_id: str) -> Optional[Dict[str, Any]]:
        """Return {'dataflow','schema','card'} raw dicts for a migratable unit,
        or None if the full triplet isn't available (public-API-only object).
        In production this is the call that requires the export/private API."""

    # -- usage / activity (optional; default empty so census still works) --- #
    def activity_log(self, hours: int = 720) -> List[Dict[str, Any]]:
        """Recent activity events: {timestamp, actor, eventType, objectType,
        objectId, details}. Powers real usage scoring. Default [] — a provider
        without audit access degrades to the proxy usage signal."""
        return []

    def dataflow_executions(self, dataflow_id: str, limit: int = 50) -> List[Dict[str, Any]]:
        """DataFlow run history: {startTime, endTime, status, triggeredBy,
        rowsProcessed}, newest first. Default [] when execution history is
        unavailable (e.g. no instance token)."""
        return []

    # -- convenience, shared by all providers ------------------------------ #
    def source_systems(self) -> List[str]:
        """Distinct upstream source systems across the dataset census."""
        seen = []
        for ds in self.list_datasets():
            src = ds.get("_source_system", "Unknown")
            if src not in seen:
                seen.append(src)
        return seen

    def triplet_dir(self, lineage_id: str) -> Optional[str]:
        """A directory holding a lineage's triplet in the IngestAgent's naming
        convention (dataflow_<id>_*.json / dataset_<id>_schema.json /
        card_<id>_beastmodes.json), which the transpiler reads.

        FixtureProvider overrides this to point at its on-disk lineages dir.
        Any other provider (e.g. LiveProvider) falls back to fetching the
        triplet via `get_lineage_triplet` and materializing it to a temp dir —
        so the transpiler works uniformly regardless of source. Returns None
        when no triplet is available (e.g. instance token not configured)."""
        import json
        import os
        import tempfile
        trip = self.get_lineage_triplet(lineage_id)
        if not trip:
            return None
        d = tempfile.mkdtemp(prefix=f"triplet_{lineage_id}_")
        df = trip["dataflow"]
        is_sql = str(df.get("databaseType", "MAGIC")).upper() == "SQL"
        df_name = f"dataflow_{lineage_id}_{'sql' if is_sql else 'magic_etl'}.json"
        _write = lambda fn, obj: json.dump(obj, open(os.path.join(d, fn), "w"))
        _write(df_name, df)
        _write(f"dataset_{lineage_id}_schema.json", trip["schema"])
        _write(f"card_{lineage_id}_beastmodes.json", trip.get("card") or {})
        return d
