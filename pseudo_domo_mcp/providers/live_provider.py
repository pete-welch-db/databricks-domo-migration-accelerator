"""LiveProvider — STUB for a real Domo tenant.

Not wired yet: Domo API credentials are the gating dependency. This file
documents the ACCURATE Domo REST endpoint map (verified against
developer.domo.com) so enabling live discovery is a matter of filling these
methods in — the tools above never change.

IMPORTANT — Domo exposes TWO API planes, and a full migration inventory needs
BOTH (this is why "just the public API" is not enough):

  A) PUBLIC API  — host `https://api.domo.com`, OAuth2 bearer.
     Auth:  POST https://api.domo.com/oauth/token?grant_type=client_credentials
            &scope=data%20user%20dashboard%20audit   (Basic auth id:secret)
            -> access_token, expires_in ~3600s. Valid scopes: data, user,
            dashboard, audit, buzz, account, workflow (space-separated).
     Reads:
       list_datasets  -> GET /v1/datasets?limit=50&offset=N            (paginate)
       dataset detail -> GET /v1/datasets/{id}   -> {id,name,description,rows,
                         columns, schema.columns[{name,type}], owner{id,name},
                         createdAt, updatedAt}
       list_pages     -> GET /v1/pages   (+ GET /v1/pages/{id} for cardIds)
       list_cards     -> GET /v1/cards   (metadata only; NO Beast Mode exprs)
       list_streams   -> GET /v1/streams (source/connector detail for ingest)
       users/groups   -> GET /v1/users, /v1/groups (owner enrichment)

  B) INSTANCE API — host `https://{instance}.domo.com`, X-DOMO-Developer-Token
     header (Admin > Access Tokens). This is where transform internals live:
       list_dataflows -> GET /api/dataprocessing/v1/dataflows
       dataflow detail-> GET /api/dataprocessing/v1/dataflows/{id}  (Magic ETL
                         action DAG + SQL DataFlow body — the transpiler input)
       card export    -> GET /api/content/v1/cards?urns=...&parts=...  (Beast
                         Mode expressions live here, NOT in the public /v1/cards)

So the migration TRIPLET (dataflow internals + dataset schema + card Beast
Modes) is assembled from: instance dataprocessing (dataflow) + public dataset
detail (schema) + instance content (card export). The public API alone gives
the census + schemas but not the transform logic or Beast Modes.
"""

from __future__ import annotations

from typing import Any, Dict, List, Optional

from .base import DomoProvider


class LiveProvider(DomoProvider):
    def __init__(self, client_id: str, client_secret: str,
                 host: str = "https://api.domo.com",
                 instance: str = "", developer_token: str = ""):
        # Public-API plane (OAuth): datasets, pages, cards-metadata, streams.
        self.client_id = client_id
        self.client_secret = client_secret
        self.host = host
        # Instance plane (developer token): dataflow internals + card export.
        # e.g. instance="acme" -> https://acme.domo.com/api/...
        self.instance = instance
        self.developer_token = developer_token

    def _not_wired(self, what: str):
        raise NotImplementedError(
            f"LiveProvider.{what} is not wired yet. Domo API credentials are the "
            f"gating dependency: an OAuth client id/secret (public api.domo.com) "
            f"and, for dataflow internals + Beast Modes, an instance name + "
            f"X-DOMO-Developer-Token. See the module docstring for the exact "
            f"endpoint map. Until then, use FixtureProvider (the default)."
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
