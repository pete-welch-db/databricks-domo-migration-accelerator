"""Generate tool — expose the selectable build targets to MCP clients."""

from __future__ import annotations

from typing import Any, Dict

from ..core import generators

__all__ = ["list_build_targets"]


def list_build_targets() -> Dict[str, Any]:
    """List the build targets the Create step can generate, and which asset
    types each applies to. Pass the chosen `key`s as `build_targets` to Create."""
    return {"build_targets": generators.BUILD_TARGETS,
            "default": generators.DEFAULT_TARGETS}
