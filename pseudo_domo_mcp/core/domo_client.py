"""domo_client — selects the active DomoProvider.

Env-driven so the same server binary runs offline (fixtures) in dev and, once
credentials land, against the live tenant with no code change:

    PSEUDO_DOMO_PROVIDER = "fixture" (default) | "live"
    PSEUDO_DOMO_FIXTURES = path to fixtures/ (default: repo fixtures/)
    DOMO_CLIENT_ID / DOMO_CLIENT_SECRET = live credentials (live mode only)
"""

from __future__ import annotations

import os
from functools import lru_cache

from ..providers.base import DomoProvider
from ..providers.fixture_provider import FixtureProvider


@lru_cache(maxsize=1)
def get_provider() -> DomoProvider:
    mode = os.environ.get("PSEUDO_DOMO_PROVIDER", "fixture").lower()
    if mode == "live":
        from ..providers.live_provider import LiveProvider
        return LiveProvider(
            client_id=os.environ["DOMO_CLIENT_ID"],
            client_secret=os.environ["DOMO_CLIENT_SECRET"],
            # Instance plane (dataflow internals + Beast Mode export) — optional
            # until you need the transform triplet; census works without it.
            instance=os.environ.get("DOMO_INSTANCE", ""),
            developer_token=os.environ.get("DOMO_DEVELOPER_TOKEN", ""),
        )
    fixtures = os.environ.get("PSEUDO_DOMO_FIXTURES")
    return FixtureProvider(fixtures) if fixtures else FixtureProvider()
