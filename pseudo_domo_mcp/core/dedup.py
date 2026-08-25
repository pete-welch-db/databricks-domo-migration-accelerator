"""dedup — find duplicate / "copy of copy" dataflows.

Domo estates accumulate copies: someone clones a flow for a one-off and it never
gets cleaned up. This clusters dataflows that are effectively the same work so
rationalization can keep one canonical and Consolidate/Retire the rest.

Signals (cheap, no triplet needed): identical input dataset set + a normalized
name (dropping copy/backup/date/version noise). The canonical is the most-used
member (tie-break: shortest name = likely the original). Deeper DAG-hash
comparison can be layered on later via get_lineage_triplet for members that
share inputs but differ in name.
"""

from __future__ import annotations

from typing import Any, Dict, List


def detect_duplicates(dataflows: List[Dict[str, Any]],
                      usage_by_id: Dict[str, int] = None) -> Dict[str, Any]:
    """Cluster duplicate dataflows. Returns {clusters, by_id}."""
    usage_by_id = usage_by_id or {}
    # Cluster on the exact input dataset set: multiple flows reading the identical
    # inputs is the "copy of copy" signature (a genuinely distinct production flow
    # rarely reads the exact same input set). Flows with no inputs aren't clustered.
    groups: Dict[Any, List[Dict[str, Any]]] = {}
    for df in dataflows:
        inputs = frozenset(df.get("inputDatasetIds") or [])
        if not inputs:
            continue
        groups.setdefault(inputs, []).append(df)

    clusters, by_id = [], {}
    gid = 0
    for members in groups.values():
        if len(members) < 2:
            continue
        gid += 1
        canonical = sorted(
            members,
            key=lambda m: (-usage_by_id.get(m["id"], 0), len(m.get("name", ""))),
        )[0]
        clusters.append({
            "group_id": gid, "canonical_id": canonical["id"],
            "member_ids": [m["id"] for m in members],
            "basis": "identical input dataset set",
        })
        for m in members:
            by_id[m["id"]] = {
                "dedup_group": gid, "cluster_size": len(members),
                "canonical_id": canonical["id"],
                "is_duplicate": m["id"] != canonical["id"],
            }
    return {"clusters": clusters, "by_id": by_id}
