"""Pseudo-Domo MCP — a Domo->Databricks migration discovery/assessment toolkit
packaged as an MCP server.

The name is deliberate: this server *impersonates the surface of a Domo tenant*
(datasets, dataflows, cards, pages, sources) so an AI client can drive the
discovery + assessment + draft-migration of a Domo estate onto Databricks —
without a live tenant. All tenant reads go through a provider abstraction
(see `pseudo_domo_mcp.providers`) that today reads synthetic fixtures grounded
in Domo's PUBLIC REST API shapes, and swaps to a live Domo client the moment
credentials + API scope land.
"""

__version__ = "0.1.0"
