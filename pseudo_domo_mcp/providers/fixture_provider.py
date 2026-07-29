"""FixtureProvider — reads the synthetic Domo tenant census from fixtures/.

This is the default provider. It lets the entire MCP (discovery, assessment,
mapping, feasibility, transpile) run end-to-end with zero network / tenant /
Databricks access, on data whose SHAPES match Domo's public REST API.
"""

from __future__ import annotations

import json
import os
from typing import Any, Dict, List, Optional

from .base import DomoProvider

# fixtures/ lives at the repo root, two levels up from this file's package.
_PKG_ROOT = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
_DEFAULT_FIXTURES = os.path.join(_PKG_ROOT, "fixtures")


class FixtureProvider(DomoProvider):
    def __init__(self, fixtures_dir: str = _DEFAULT_FIXTURES):
        self.fixtures_dir = fixtures_dir
        self.tenant_dir = os.path.join(fixtures_dir, "tenant")
        self.lineages_dir = os.path.join(fixtures_dir, "lineages")

    # -- census reads ------------------------------------------------------ #
    def list_datasets(self) -> List[Dict[str, Any]]:
        return self._read("datasets.json")["datasets"]

    def list_dataflows(self) -> List[Dict[str, Any]]:
        return self._read("dataflows.json")["dataflows"]

    def list_cards(self) -> List[Dict[str, Any]]:
        return self._read("cards.json")["cards"]

    def list_pages(self) -> List[Dict[str, Any]]:
        return self._read("pages.json")["pages"]

    # -- per-lineage triplet ---------------------------------------------- #
    def get_lineage_triplet(self, lineage_id: str) -> Optional[Dict[str, Any]]:
        df = self._read_lineage(f"dataflow_{lineage_id}_magic_etl.json", optional=True)
        if df is None:
            df = self._read_lineage(f"dataflow_{lineage_id}_sql.json", optional=True)
        schema = self._read_lineage(f"dataset_{lineage_id}_schema.json", optional=True)
        card = self._read_lineage(f"card_{lineage_id}_beastmodes.json", optional=True)
        if df is None or schema is None or card is None:
            return None
        return {"dataflow": df, "schema": schema, "card": card}

    def lineages_dir_path(self) -> str:
        """Directory the transpiler's IngestAgent reads triplets from."""
        return self.lineages_dir

    def triplet_dir(self, lineage_id: str):
        """Fixtures already live on disk in the IngestAgent's naming
        convention — return that dir directly (skip the temp materialization
        the base class does for API-backed providers). Returns None if the
        lineage has no triplet."""
        import os
        if os.path.exists(os.path.join(
                self.lineages_dir, f"dataset_{lineage_id}_schema.json")):
            return self.lineages_dir
        return None

    # -- io ---------------------------------------------------------------- #
    def _read(self, filename: str) -> Dict[str, Any]:
        with open(os.path.join(self.tenant_dir, filename), "r", encoding="utf-8") as fh:
            return json.load(fh)

    def _read_lineage(self, filename: str, optional: bool = False):
        path = os.path.join(self.lineages_dir, filename)
        if not os.path.exists(path):
            if optional:
                return None
            raise FileNotFoundError(path)
        with open(path, "r", encoding="utf-8") as fh:
            # Tolerate any trailing non-JSON in imperfect exports.
            return json.JSONDecoder().raw_decode(fh.read().lstrip())[0]
