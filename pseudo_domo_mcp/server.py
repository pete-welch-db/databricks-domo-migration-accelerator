"""Pseudo-Domo MCP server.

A FastMCP server that packages the Domo discovery/assessment/migration API
surface as MCP tools, so any MCP client (Claude Code, Genie Code, Cursor) can
drive a Domo -> Databricks migration assessment conversationally.

Transports (choose with PSEUDO_DOMO_TRANSPORT, default "stdio"):
    stdio            — local dev / Claude Code (default)
    streamable-http  — HTTP server (Databricks App / remote); honors PORT.

Run locally:
    python -m pseudo_domo_mcp.server            # stdio
    PSEUDO_DOMO_TRANSPORT=http python -m pseudo_domo_mcp.server
"""

from __future__ import annotations

import asyncio
import functools
import inspect
import os

from fastmcp import FastMCP

mcp = FastMCP("pseudo-domo-mcp")


def _register_sync(fn):
    """Register a sync function as an MCP tool, run off the event loop.

    FastMCP runs sync tool bodies on the asyncio loop thread, which would block
    the stdio transport during any file IO. We wrap every tool in
    asyncio.to_thread while preserving its signature/docstring so the schema is
    generated correctly (same approach as the ai-dev-kit server).
    """
    @functools.wraps(fn)
    async def _async(**kwargs):
        return await asyncio.to_thread(fn, **kwargs)

    _async.__signature__ = inspect.signature(fn)
    return mcp.tool(_async)


# Import tool implementations and register them. Each tools module exposes
# plain sync functions; we wrap+register here so the modules stay import-safe
# and unit-testable without FastMCP.
from .tools import (discovery, assessment, mapping, feasibility, transpile, plan,  # noqa: E402
                    filters, rationalize, estimate, orchestration)

for _mod in (discovery, assessment, mapping, feasibility, transpile, plan,
             filters, rationalize, estimate, orchestration):
    for _name in _mod.__all__:
        _register_sync(getattr(_mod, _name))


def main() -> None:
    transport = os.environ.get("PSEUDO_DOMO_TRANSPORT", "stdio").lower()
    if transport in ("http", "streamable-http"):
        port = int(os.environ.get("PORT", "8000"))
        mcp.run(transport="streamable-http", host="0.0.0.0", port=port)
    else:
        mcp.run()  # stdio


if __name__ == "__main__":
    main()
