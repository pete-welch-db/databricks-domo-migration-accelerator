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

    # -- convenience, shared by all providers ------------------------------ #
    def source_systems(self) -> List[str]:
        """Distinct upstream source systems across the dataset census."""
        seen = []
        for ds in self.list_datasets():
            src = ds.get("_source_system", "Unknown")
            if src not in seen:
                seen.append(src)
        return seen
