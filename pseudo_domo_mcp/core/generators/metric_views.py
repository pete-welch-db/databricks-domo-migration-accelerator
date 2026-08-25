"""Generator: standalone Unity Catalog metric-view YAML (Beast Modes)."""

from __future__ import annotations

from typing import Any, Dict


def render(result: Dict[str, Any]) -> str:
    """Return the Beast-Mode metric-view YAML the transpiler already produced,
    as a standalone artifact (it's otherwise embedded in the SDP output)."""
    yml = (result.get("sql") or {}).get("gold_semantic_metrics")
    if yml and yml.strip():
        return ("-- Unity Catalog metric view(s) — folded Domo Beast Modes.\n"
                "-- Governed semantic layer so cards/Genie share one definition.\n" + yml)
    return "-- No card Beast Modes for this asset — no metric view generated.\n"
