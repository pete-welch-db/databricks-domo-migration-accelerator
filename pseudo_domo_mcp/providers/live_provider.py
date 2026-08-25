"""LiveProvider — a real Domo tenant, over the two documented API planes.

Verified against developer.domo.com. Domo exposes TWO planes and a full
migration inventory needs both:

  A) PUBLIC API  — host `https://api.domo.com`, OAuth2 client_credentials.
     Auth:  POST /oauth/token?grant_type=client_credentials
            &scope=data%20user%20dashboard%20audit   (Basic auth id:secret)
            -> access_token, expires_in ~3600s. Valid scopes: data, user,
            dashboard, audit, buzz, account, workflow (space-separated).
     Reads:
       list_datasets  -> GET /v1/datasets?limit=50&offset=N            (paginate)
       dataset detail -> GET /v1/datasets/{id}   -> {id,name,description,rows,
                         columns, schema.columns[{name,type}], owner{id,name},
                         createdAt, updatedAt}
       list_streams   -> GET /v1/streams  (dataSource + dataProvider → the
                         source system behind each dataset; Domo has no
                         source field on the dataset object itself)
       list_pages     -> GET /v1/pages   (+ GET /v1/pages/{id} for cardIds)
       list_cards     -> GET /v1/cards   (metadata only; NO Beast Mode exprs)

  B) INSTANCE API — host `https://{instance}.domo.com`, X-DOMO-Developer-Token.
     This is where transform internals + Beast Modes live:
       list_dataflows -> GET /api/dataprocessing/v1/dataflows
       dataflow detail-> GET /api/dataprocessing/v1/dataflows/{id}  (Magic ETL
                         action DAG + SQL DataFlow body — the transpiler input)
       card export    -> GET /api/content/v1/cards?urns=...&parts=...  (Beast
                         Mode expressions live here, not in public /v1/cards)

Each read is NORMALIZED to the same internal shape the FixtureProvider returns,
so the tools/UI never branch on provider. The instance plane is optional: the
census + schemas come from the public plane; only the transform TRIPLET
(get_lineage_triplet) needs the instance token, and it returns None (skips) when
that isn't configured — matching how a public-API-only object behaves.
"""

from __future__ import annotations

import base64
import json
import time
import urllib.parse
import urllib.request
from typing import Any, Dict, List, Optional

from .base import DomoProvider


class LiveProvider(DomoProvider):
    def __init__(self, client_id: str, client_secret: str,
                 host: str = "https://api.domo.com",
                 instance: str = "", developer_token: str = "",
                 scopes: str = "data user dashboard audit"):
        # Public-API plane (OAuth): datasets, streams, pages, cards-metadata.
        self.client_id = client_id
        self.client_secret = client_secret
        self.host = host.rstrip("/")
        self.scopes = scopes
        # Instance plane (developer token): dataflow internals + card export.
        self.instance = instance
        self.developer_token = developer_token
        self._token: Optional[str] = None
        self._token_exp: float = 0.0

    # -- auth -------------------------------------------------------------- #
    def _bearer(self) -> str:
        """Cached OAuth2 client_credentials token (public plane)."""
        if self._token and time.time() < self._token_exp - 60:
            return self._token
        creds = base64.b64encode(
            f"{self.client_id}:{self.client_secret}".encode()).decode()
        q = urllib.parse.urlencode(
            {"grant_type": "client_credentials", "scope": self.scopes})
        req = urllib.request.Request(
            f"{self.host}/oauth/token?{q}", method="GET",
            headers={"Authorization": f"Basic {creds}"})
        data = self._json(req)
        self._token = data["access_token"]
        self._token_exp = time.time() + int(data.get("expires_in", 3600))
        return self._token

    def _public_get(self, path: str) -> Any:
        req = urllib.request.Request(
            f"{self.host}{path}",
            headers={"Authorization": f"Bearer {self._bearer()}",
                     "Accept": "application/json"})
        return self._json(req)

    def _instance_get(self, path: str) -> Any:
        if not (self.instance and self.developer_token):
            return None
        req = urllib.request.Request(
            f"https://{self.instance}.domo.com{path}",
            headers={"X-DOMO-Developer-Token": self.developer_token,
                     "Accept": "application/json"})
        return self._json(req)

    @staticmethod
    def _json(req) -> Any:
        with urllib.request.urlopen(req, timeout=30) as resp:
            return json.loads(resp.read().decode() or "null")

    def _paginate(self, path: str, limit: int = 50) -> List[Dict[str, Any]]:
        """Walk a public list endpoint using limit/offset."""
        out: List[Dict[str, Any]] = []
        offset = 0
        sep = "&" if "?" in path else "?"
        while True:
            page = self._public_get(f"{path}{sep}limit={limit}&offset={offset}")
            if not page:
                break
            out.extend(page)
            if len(page) < limit:
                break
            offset += limit
        return out

    # -- source-system enrichment (from the Stream API) -------------------- #
    def _source_by_dataset(self) -> Dict[str, str]:
        """dataset_id -> source system, derived from Stream dataProvider.

        Domo datasets carry no source field; the Stream API links a dataset to
        the connector (dataProvider) that feeds it. Best-effort; datasets with
        no stream (derived/manual) fall back to 'Domo (derived)'.
        """
        mapping: Dict[str, str] = {}
        try:
            for st in self._paginate("/v1/streams"):
                ds = (st.get("dataSet") or {})
                ds_id = ds.get("id")
                provider = (st.get("dataProvider") or {}).get("name") \
                    or st.get("dataProviderType") or "Unknown"
                if ds_id:
                    mapping[ds_id] = provider
        except Exception:
            pass
        return mapping

    # -- census reads (normalized to the fixture shape) -------------------- #
    def list_datasets(self) -> List[Dict[str, Any]]:
        raw = self._paginate("/v1/datasets")
        src = self._source_by_dataset()
        out = []
        for d in raw:
            ds_id = d.get("id")
            source = src.get(ds_id, "Domo (derived)")
            out.append({
                "id": ds_id, "name": d.get("name"),
                "description": d.get("description", ""),
                "rows": d.get("rows"), "columns": d.get("columns"),
                "owner": d.get("owner", {}),
                "dataCurrentAt": d.get("dataCurrentAt"),
                "createdAt": d.get("createdAt"), "updatedAt": d.get("updatedAt"),
                "pdpEnabled": d.get("pdpEnabled", False),
                "schema": d.get("schema"),          # present on detail calls
                "_source_system": source,           # inferred (not a Domo field)
            })
        return out

    def list_dataflows(self) -> List[Dict[str, Any]]:
        """Instance plane. Empty list when no instance token (census still
        works from datasets/streams; the transform layer is just unavailable)."""
        raw = self._instance_get("/api/dataprocessing/v1/dataflows") or []
        out = []
        for df in raw:
            # Domo dataflow objects vary; map the fields the tools use.
            inputs = [i.get("dataSourceId") or i.get("id")
                      for i in (df.get("inputs") or [])]
            outputs = [o.get("dataSourceId") or o.get("id")
                       for o in (df.get("outputs") or [])]
            db_type = str(df.get("databaseType", "MAGIC")).upper()
            out.append({
                "id": df.get("id"), "name": df.get("name"),
                "databaseType": "SQL" if db_type in ("MYSQL", "SQL", "REDSHIFT")
                                else "MAGIC",
                "inputDatasetIds": [i for i in inputs if i],
                "outputDatasetIds": [o for o in outputs if o],
                "actionCount": len(df.get("actions") or []),
                "owner": {"name": df.get("responsibleUserName")
                          or df.get("owner", "")},
                "runCadence": df.get("runState") or df.get("executionType", ""),
                "_has_writeback": bool(df.get("onboardFlowId")),
                # Live dataflows are addressable directly by their Domo id.
                "_triplet_lineage_id": df.get("id"),
            })
        return out

    def list_cards(self) -> List[Dict[str, Any]]:
        raw = self._paginate("/v1/cards")
        out = []
        for c in raw:
            out.append({
                "id": c.get("id"), "title": c.get("title") or c.get("name"),
                "type": c.get("type", "unknown"),
                "pageId": c.get("pageId", ""),
                "boundDatasetIds": c.get("datasources")
                or c.get("datasetIds", []),
                # public /v1/cards has no Beast Mode exprs; count via export.
                "beastModeCount": len(c.get("beastModes") or []),
            })
        return out

    def list_pages(self) -> List[Dict[str, Any]]:
        raw = self._paginate("/v1/pages")
        out = []
        for pg in raw:
            out.append({
                "id": pg.get("id"), "name": pg.get("name"),
                "owner": {"name": (pg.get("owner") or {}).get("name", "")},
                "cardIds": pg.get("cardIds", []),
            })
        return out

    # -- usage / activity -------------------------------------------------- #
    def activity_log(self, hours: int = 720) -> List[Dict[str, Any]]:
        """Activity/audit events (public plane, `audit` scope). Normalized to
        {timestamp, actor, eventType, objectType, objectId, details}. Degrades to
        [] when the audit scope isn't granted. Domo audit endpoint (confirm exact
        path/params against the tenant): GET /v1/audit?start=<ms>&end=<ms>."""
        try:
            import time
            end = int(time.time() * 1000)
            start = end - int(hours * 3600 * 1000)
            raw = self._paginate(f"/v1/audit?start={start}&end={end}") or []
        except Exception:
            return []
        out = []
        for e in raw:
            out.append({
                "timestamp": e.get("time") or e.get("eventTime"),
                "actor": {"id": e.get("userId"), "name": e.get("userName")},
                "eventType": e.get("eventType") or e.get("actionType"),
                "objectType": (e.get("objectType") or "").lower(),
                "objectId": e.get("objectId") or e.get("resourceId"),
                "details": e.get("additionalComment") or {},
            })
        return out

    def dataflow_executions(self, dataflow_id: str, limit: int = 50) -> List[Dict[str, Any]]:
        """DataFlow run history (instance plane). [] when no instance token.
        GET /api/dataprocessing/v1/dataflows/{id}/executions (confirm on tenant)."""
        raw = self._instance_get(
            f"/api/dataprocessing/v1/dataflows/{dataflow_id}/executions?limit={limit}") or []
        out = []
        for r in raw:
            out.append({
                "startTime": r.get("beginTime") or r.get("startTime"),
                "endTime": r.get("endTime"),
                "status": (r.get("state") or r.get("status") or "").upper(),
                "triggeredBy": r.get("activationType") or r.get("triggeredBy", ""),
                "rowsProcessed": r.get("dataProcessed") or r.get("rowsProcessed", 0),
            })
        return out

    # -- per-lineage triplet (instance plane) ------------------------------ #
    def get_lineage_triplet(self, lineage_id: str) -> Optional[Dict[str, Any]]:
        """Assemble a migration unit from both planes. Returns None (skip) when
        the instance token isn't configured — same as a public-only object."""
        if not (self.instance and self.developer_token):
            return None
        df = self._instance_get(f"/api/dataprocessing/v1/dataflows/{lineage_id}")
        if not df:
            return None
        out_ids = [o.get("dataSourceId") or o.get("id")
                   for o in (df.get("outputs") or [])]
        out_id = next((o for o in out_ids if o), None)
        schema_doc = self._public_get(f"/v1/datasets/{out_id}") if out_id else None
        # Beast Modes via the instance content export for cards bound to output.
        card_doc = self._card_export(out_id) if out_id else None
        if df is None or schema_doc is None:
            return None
        return {"dataflow": df, "schema": schema_doc,
                "card": card_doc or {"id": "", "beastModes": []}}

    def _card_export(self, dataset_id: str) -> Optional[Dict[str, Any]]:
        try:
            return self._instance_get(
                "/api/content/v1/cards?parts=metadata,properties"
                f"&datasetId={urllib.parse.quote(dataset_id)}")
        except Exception:
            return None
