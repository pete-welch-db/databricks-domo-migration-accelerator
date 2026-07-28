"""MCP tool modules.

Each module exposes plain sync functions (listed in its __all__) that the
server wraps with @mcp.tool. Keeping them as plain functions means they're
directly unit-testable without an MCP client, and the business logic they call
lives in pseudo_domo_mcp.core.
"""
