"""Provider abstraction — the single seam between "synthetic today" and
"live Domo tenant tomorrow".

Every discovery read the MCP does goes through a `DomoProvider`. The default
`FixtureProvider` reads the JSON census under fixtures/ (works offline, no
tenant). `LiveProvider` is a stub that documents the exact Domo REST calls to
wire once an API client id/secret + scope land — swapping it in is a one-line
change in `core.domo_client.get_provider()`.
"""

from .base import DomoProvider
from .fixture_provider import FixtureProvider

__all__ = ["DomoProvider", "FixtureProvider"]
