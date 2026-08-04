"""uploads — accept a manually-uploaded Magic ETL JSON as a migratable unit.

The transpiler works on a *triplet* (DataFlow JSON + output DataSet schema +
card Beast Modes). A live tenant supplies all three; a user who just has a
Magic ETL export off their desk has only the first. This module bridges that
gap: given a raw Magic ETL DataFlow, it **synthesizes the missing two files**
so the upload flows through Analyze -> Draft -> Create exactly like a fixture.

  * The output DataSet **schema** is *inferred* by propagating columns through
    the parsed transform DAG (the same ParseAgent the rest of the tool uses).
    This is honest, not faked: if a raw source column passes straight through
    to PUBLISH (so the exact output columns are unknowable from the flow alone),
    inference declines and we ask the user to also upload the DataSet schema.
  * The **card** is synthesized empty (no Beast Modes) — a bare flow has no
    card. The reconcile gate then passes on schema-parity + lineage-completeness
    with zero Beast Modes to fold, which is the truthful result.

Synthesized triplets are materialized to disk under `generated/_uploads/<id>/`
in the IngestAgent naming convention, so `triplet_dir(id)` just returns that
directory and every downstream agent is unchanged.
"""

from __future__ import annotations

import datetime
import json
import os
import re
import uuid
from typing import Any, Dict, List, Optional, Tuple

# Importing pipeline first puts the vendored transpiler dir on sys.path so the
# bare `ingest`/`parse` imports below resolve (mirrors core/graph.py).
from ..transpiler import pipeline  # noqa: F401
from ingest import Lineage  # noqa: E402
from parse import ParseAgent, IRNode  # noqa: E402

# generated/ is gitignored; uploads live in a dedicated subdir.
_REPO_ROOT = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
_UPLOAD_ROOT = os.path.join(_REPO_ROOT, "generated", "_uploads")

# Domo GroupBy aggregation function -> a reasonable Domo output type. Types are
# only advisory (the reconcile gate compares names/order); STRING is the safe
# default when we cannot tell.
_AGG_TYPE = {"COUNT": "LONG", "SUM": "DECIMAL", "AVG": "DECIMAL"}


class _Avail:
    """Column availability at a DAG node: a set of KNOWN columns plus whether
    an unresolved `*` (raw source columns) is still in play."""

    __slots__ = ("known", "star")

    def __init__(self, known: Optional["OrderedSet"] = None, star: bool = False):
        self.known: "OrderedSet" = known if known is not None else OrderedSet()
        self.star = star


class OrderedSet:
    """Tiny insertion-ordered set (stdlib has none) for deterministic column order."""

    def __init__(self, items: Optional[List[str]] = None):
        self._d: Dict[str, None] = {}
        for it in (items or []):
            self._d[it] = None

    def add(self, item: str) -> None:
        self._d[item] = None

    def update(self, items) -> None:
        for it in items:
            self._d[it] = None

    def __iter__(self):
        return iter(self._d)

    def __len__(self):
        return len(self._d)

    def copy(self) -> "OrderedSet":
        o = OrderedSet()
        o._d = dict(self._d)
        return o

    def to_list(self) -> List[str]:
        return list(self._d)


# --------------------------------------------------------------------------- #
# Schema inference
# --------------------------------------------------------------------------- #
def infer_output_schema(flow: Dict[str, Any]) -> Tuple[Optional[List[Dict[str, str]]], List[str]]:
    """Infer the gold output DataSet columns by propagating columns through the
    Magic ETL DAG. Returns (columns | None, notes). None means the exact output
    columns can't be determined from the flow alone (a raw `*` reaches PUBLISH).
    """
    notes: List[str] = []
    # Build a throwaway Lineage the ParseAgent can walk (it only reads .actions
    # and .is_sql). SQL DataFlows have no action DAG to infer from.
    if str(flow.get("databaseType", "MAGIC")).upper() == "SQL":
        return None, ["SQL DataFlow: output columns can't be inferred from the "
                      "flow; upload the DataSet schema or hand-review."]

    tmp = Lineage(
        lineage_id=flow.get("id", "upload"), name=flow.get("name", ""),
        description="", database_type="MAGIC",
        inputs=[], actions=flow.get("actions", []) or [], raw_sql=None,
        output_dataset_id="", output_dataset_name="", gold_schema=[],
        card=_EMPTY_CARD_OBJ(), warnings=[])
    try:
        ir = ParseAgent().parse(tmp)
    except (NotImplementedError, ValueError, KeyError) as e:
        return None, [f"Could not parse the Magic ETL DAG: {e}"]

    avail: Dict[str, _Avail] = {}
    types: Dict[str, str] = {}   # inferred Domo type per known column
    for n in ir:
        avail[n.node_id] = _node_avail(n, avail, types)

    publish = next((n for n in ir if n.op == "PUBLISH"), None)
    producer_id = publish.inputs[0] if (publish and publish.inputs) else (
        ir[-1].node_id if ir else None)
    if producer_id is None or producer_id not in avail:
        return None, ["No producing node found ahead of PUBLISH."]

    out = avail[producer_id]
    if out.star or len(out.known) == 0:
        notes.append("Output columns pass through from a raw source, so the "
                     "exact DataSet contract can't be inferred from the flow "
                     "alone. Upload the DataSet schema JSON too, or the gold "
                     "parity gate can't be checked.")
        return None, notes

    cols = [{"name": c, "type": types.get(c, "STRING")} for c in out.known]
    notes.append(f"Inferred {len(cols)} output column(s) from the transform DAG "
                 "(types are best-effort — verify).")
    return cols, notes


def _node_avail(n: IRNode, avail: Dict[str, _Avail], types: Dict[str, str]) -> _Avail:
    """Column availability produced by one IR node given its parents'."""
    p = n.params
    parents = [avail[i] for i in n.inputs if i in avail]

    if n.op == "LOAD":
        return _Avail(star=True)                        # raw source cols unknown
    if n.op == "FILTER":
        return _clone(parents[0]) if parents else _Avail(star=True)
    if n.op == "FORMULA":
        base = _clone(parents[0]) if parents else _Avail(star=True)
        for f in p.get("formulas", []):
            base.known.add(f["outputColumn"])           # derived col is now known
        return base
    if n.op == "GROUP_BY":                              # RESETS to a known set
        known = OrderedSet(p.get("group_by", []))
        for ag in p.get("aggregations", []):
            oc = ag["outputColumn"]
            known.add(oc)
            types[oc] = _AGG_TYPE.get(str(ag.get("function", "")).upper(), "STRING")
        return _Avail(known=known, star=False)
    if n.op == "SELECT":                                # RESETS to selected cols
        return _Avail(known=OrderedSet(p.get("selected", [])), star=False)
    if n.op == "JOIN":
        known = OrderedSet()
        star = False
        for par in parents:
            known.update(par.known)
            star = star or par.star
        return _Avail(known=known, star=star)
    if n.op == "PUBLISH":
        return _clone(parents[0]) if parents else _Avail(star=True)
    # Unknown op: pass parent through conservatively as star.
    return _clone(parents[0]) if parents else _Avail(star=True)


def _clone(a: _Avail) -> _Avail:
    return _Avail(known=a.known.copy(), star=a.star)


def _EMPTY_CARD_OBJ():
    from ingest import Card
    return Card(card_id="", title="", card_type="synthetic", page_id="")


# --------------------------------------------------------------------------- #
# Persist a synthesized triplet
# --------------------------------------------------------------------------- #
def register_upload(flow: Dict[str, Any],
                    schema: Optional[Dict[str, Any]] = None,
                    card: Optional[Dict[str, Any]] = None) -> Dict[str, Any]:
    """Persist an uploaded Magic ETL flow (+ optional real schema/card) as a
    synthesized triplet on disk. Returns a build-asset descriptor, or an error
    dict with `needs_schema` when the output schema can't be inferred and none
    was supplied."""
    if not isinstance(flow, dict) or "actions" not in flow:
        return {"error": "Not a Magic ETL DataFlow JSON (missing 'actions')."}

    lid = _mint_lineage_id(flow)
    is_sql = str(flow.get("databaseType", "MAGIC")).upper() == "SQL"
    flow.setdefault("id", lid)

    # -- resolve the output DataSet id / name from the PUBLISH action -------- #
    publish = next((a for a in flow.get("actions", [])
                    if a.get("type") == "PublishToVault"), {})
    out_id = publish.get("dataSourceId") or f"{lid}-out"
    out_name = publish.get("dataSourceName") or f"{flow.get('name', lid)} (output)"

    # -- schema: use uploaded, else infer ----------------------------------- #
    schema_inferred = False
    infer_notes: List[str] = []
    if schema is None:
        cols, infer_notes = infer_output_schema(flow)
        if cols is None and not is_sql:
            return {"error": "Couldn't infer the output DataSet schema from the "
                             "flow alone.", "needs_schema": True,
                    "notes": infer_notes}
        schema_inferred = True
        schema = {
            "id": out_id, "name": out_name,
            "schema": {"columns": cols or []},
            "_note": "SYNTHESIZED by upload: output schema inferred from the "
                     "Magic ETL transform DAG. Verify column names/types.",
        }
    else:
        schema.setdefault("id", out_id)
        schema.setdefault("name", out_name)

    # -- card: use uploaded, else synthesize empty --------------------------- #
    if card is None:
        card = {
            "id": f"{lid}-card", "title": f"{flow.get('name', lid)}",
            "type": "synthetic", "pageId": "",
            "datasources": [{"dataSourceId": out_id}],
            "beastModes": [], "filters": [], "series": [],
            "_note": "SYNTHESIZED by upload: no card was provided, so there are "
                     "no Beast Modes to fold. If the source card had calculated "
                     "fields, upload it too or the dashboard numbers may differ.",
        }

    # -- materialize the triplet in IngestAgent naming ----------------------- #
    d = os.path.join(_UPLOAD_ROOT, lid)
    os.makedirs(d, exist_ok=True)
    df_name = f"dataflow_{lid}_{'sql' if is_sql else 'magic_etl'}.json"
    _write(os.path.join(d, df_name), flow)
    _write(os.path.join(d, f"dataset_{lid}_schema.json"), schema)
    _write(os.path.join(d, f"card_{lid}_beastmodes.json"), card)

    action_count = len(flow.get("actions", []) or [])
    meta = {
        "triplet_lineage_id": lid,
        "asset_type": "sql_dataflow" if is_sql else "magic_etl",
        "name": flow.get("name", lid),
        "database_type": "SQL" if is_sql else "MAGIC",
        "action_count": action_count,
        "governance": "uncertain",
        "build": True,
        "has_triplet": True,
        "uploaded": True,
        "schema_inferred": schema_inferred,
        "output_dataset_id": out_id,
        "output_dataset_name": out_name,
        "columns": len((schema.get("schema") or {}).get("columns", [])),
        "notes": infer_notes,
        "uploaded_at": datetime.datetime.now(datetime.timezone.utc).isoformat(),
    }
    _write(os.path.join(d, "meta.json"), meta)
    return meta


def triplet_dir(lineage_id: str) -> Optional[str]:
    """Directory holding an uploaded lineage's triplet, or None."""
    d = os.path.join(_UPLOAD_ROOT, lineage_id)
    return d if os.path.isdir(d) else None


def list_uploads() -> List[Dict[str, Any]]:
    """All persisted uploaded build-assets (newest first)."""
    if not os.path.isdir(_UPLOAD_ROOT):
        return []
    out: List[Dict[str, Any]] = []
    for name in os.listdir(_UPLOAD_ROOT):
        meta_path = os.path.join(_UPLOAD_ROOT, name, "meta.json")
        if os.path.exists(meta_path):
            try:
                with open(meta_path, "r", encoding="utf-8") as fh:
                    out.append(json.load(fh))
            except (json.JSONDecodeError, OSError):
                pass
    out.sort(key=lambda m: m.get("uploaded_at", ""), reverse=True)
    return out


def get_upload(lineage_id: str) -> Optional[Dict[str, Any]]:
    meta_path = os.path.join(_UPLOAD_ROOT, lineage_id, "meta.json")
    if not os.path.exists(meta_path):
        return None
    with open(meta_path, "r", encoding="utf-8") as fh:
        return json.load(fh)


def upload_schema_columns(lineage_id: str) -> Optional[List[Dict[str, str]]]:
    """The synthesized/uploaded output-DataSet columns for a lineage (for map)."""
    d = triplet_dir(lineage_id)
    if not d:
        return None
    path = os.path.join(d, f"dataset_{lineage_id}_schema.json")
    if not os.path.exists(path):
        return None
    with open(path, "r", encoding="utf-8") as fh:
        doc = json.load(fh)
    return (doc.get("schema") or {}).get("columns")


def delete_upload(lineage_id: str) -> bool:
    import shutil
    d = triplet_dir(lineage_id)
    if not d:
        return False
    shutil.rmtree(d, ignore_errors=True)
    return True


# --------------------------------------------------------------------------- #
# helpers
# --------------------------------------------------------------------------- #
def _mint_lineage_id(flow: Dict[str, Any]) -> str:
    base = flow.get("name") or flow.get("id") or "flow"
    slug = re.sub(r"[^a-z0-9]+", "_", str(base).lower()).strip("_")[:40] or "flow"
    return f"upload_{slug}_{uuid.uuid4().hex[:6]}"


def _write(path: str, obj: Any) -> None:
    with open(path, "w", encoding="utf-8") as fh:
        json.dump(obj, fh, indent=2)
