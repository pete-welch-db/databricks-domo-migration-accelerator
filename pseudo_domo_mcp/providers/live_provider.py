"""LiveProvider — STUB for a real Domo tenant.

Not wired yet: a Domo API client id/secret with the right scopes is the gating
dependency. This file documents the exact Domo REST endpoints each read maps
to, so enabling live discovery is a matter of filling these methods in — the
tools above never change.

Auth (production):
    POST https://api.domo.com/oauth/token?grant_type=client_credentials
        &scope=data%20dashboard   (Basic auth: client_id:client_secret)
    -> Bearer token, ~1h TTL.

Endpoints:
    list_datasets   -> GET  /v1/datasets?limit=50&offset=N   (paginate)
    dataset detail  -> GET  /v1/datasets/{id}                (schema.columns)
    list_dataflows  -> GET  /v1/dataflows        (Magic ETL internals + SQL body
                            require the dataflow EXPORT / private API, not public)
    list_cards      -> GET  /v1/cards  (+ card export for Beast Mode expressions)
    list_pages      -> GET  /v1/pages
    triplet         -> dataflow export + dataset schema + card export, joined.
"""

from __future__ import annotations

from typing import Any, Dict, List, Optional

from .base import DomoProvider


class LiveProvider(DomoProvider):
    def __init__(self, client_id: str, client_secret: str,
                 host: str = "https://api.domo.com"):
        self.client_id = client_id
        self.client_secret = client_secret
        self.host = host

    def _not_wired(self, what: str):
        raise NotImplementedError(
            f"LiveProvider.{what} is not wired yet. A Domo API client id/secret "
            f"with the right scopes is the gating dependency. See the module "
            f"docstring for the exact endpoint map. Until then, use "
            f"FixtureProvider (the default)."
        )

    def list_datasets(self) -> List[Dict[str, Any]]:
        self._not_wired("list_datasets")

    def list_dataflows(self) -> List[Dict[str, Any]]:
        self._not_wired("list_dataflows")

    def list_cards(self) -> List[Dict[str, Any]]:
        self._not_wired("list_cards")

    def list_pages(self) -> List[Dict[str, Any]]:
        self._not_wired("list_pages")

    def get_lineage_triplet(self, lineage_id: str) -> Optional[Dict[str, Any]]:
        self._not_wired("get_lineage_triplet")
