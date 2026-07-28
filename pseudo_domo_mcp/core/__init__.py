"""Core business logic for the Pseudo-Domo MCP.

Mirrors the ai-dev-kit split: the `tools/` layer is thin `@mcp.tool` wrappers,
while all real work (provider selection, DDL parsing, classification,
feasibility scoring) lives here so it's unit-testable without an MCP client.
"""
