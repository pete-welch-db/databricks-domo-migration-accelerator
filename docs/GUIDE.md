# Guide — Databricks Domo Migration Accelerator

A detailed walkthrough of installing, running, and driving the accelerator, and
the full **Assess → Rationalize → Convert → Reconcile** workflow. See also the
[FAQ](./FAQ.md).

---

## 1. Install & run

Requires Python 3.11+.

```bash
git clone <repo-url> databricks-domo-migration-accelerator
cd databricks-domo-migration-accelerator
python -m venv .venv && source .venv/bin/activate
pip install -e .
```

**Operator web console:**

```bash
python -m pseudo_domo_mcp.webapp.app        # → http://127.0.0.1:8010
```

**MCP server** (for Claude Code / Cursor / Genie Code):

```bash
python -m pseudo_domo_mcp.server                                  # stdio
PSEUDO_DOMO_TRANSPORT=http PORT=8000 python -m pseudo_domo_mcp.server   # HTTP
```

Both run **offline on synthetic fixtures** out of the box — no Domo tenant,
Databricks workspace, or network required.

**Run the tests:** `pytest -q` (offline, fixtures).

---

## 2. The workflow (Assess → Rationalize → Convert → Reconcile)

### Configure
Set catalog/schema, an optional Databricks CLI profile (enables deploy), and the
Domo provider (`fixture` default, or `live`). Secrets are read from the
environment, never stored.

### Connect
One click runs a discovery scan and lands you on **Discover** with results
loaded.

### Discover  *(Assess — Profiler/Analyzer)*
The full typed inventory: **connector · magic_etl · sql_dataflow · dataset ·
card · beast_mode · page**. Each asset carries inferred **governance** (with a
confidence % and the "why" signals) and the assess scores — **value,
complexity, effort (1-5), usage (0-100 proxy)**.

**Filter it.** Beyond type + search, the filter bar narrows by governance,
domain, value, complexity, effort, and usage — built from the estate's own
facets. **★ Save as wave** persists the current filter as a named filter set
(a migration-wave candidate).

### Rationalize  *(the decision layer)*
The heart of the tool. Each asset gets a **disposition** and a **target
surface**, pre-filled with a suggestion from the assess signals:

| Disposition | When | Typical target |
|---|---|---|
| **Retire** | low usage + low value (dead weight) | none |
| **Repoint** | live card/dataset — keep it, swap its source | AI/BI + Genie |
| **Rebuild** | transform to re-express natively | AI/BI + Genie, or Apps+Lakebase (writeback) |
| **Elevate** | high-value — make it more than a static card | AI/BI + Genie / ML |
| **Consolidate** | duplicate / near-duplicate | fold into a shared asset |

Edit and **Save** per row, or **bulk-apply** a disposition to everything
currently shown. The rollup shows the split by disposition/surface, and
**∑ Estimate future state** rolls it into FTE-weeks + a consumption size (+
savings if you enter your Domo spend).

### Model
Pick the canonical industry data model(s) to draft-map Domo columns onto
(universal — the open-source Databricks Industry Data Models).

### Plan
A value-driven **wave plan** + per-connector ingestion strategy. If you assigned
waves in Rationalize, the plan honors them (retired excluded); otherwise it
auto-sequences by value-to-effort with shadow-IT as its own wave. **Orchestration**
(schedules + dataflow dependencies) maps to a Databricks Workflow.

### Build & Deploy  *(Convert → Reconcile)*
Pick a migratable asset → **Analyze** its DAG → **Map** columns to the model →
**Draft** the Lakeflow pipeline (SQL or Python) with Beast Modes folded into a
metric view → **Create** the deployable bundle (and deploy if a profile is set).
The **reconcile gate** verifies gold schema parity before you ship the pipeline.

**Selectable build targets.** Create isn't ETL-only — a checkbox group picks
what to generate into the bundle:

| Target | Artifact written |
|---|---|
| ETL Pipeline (SDP) | `src/pipeline/pipeline.{sql,py}` — Lakeflow Declarative Pipeline (gate-protected) |
| Metric Views | `src/metric_views/*.sql` — UC metric views from Beast Modes |
| AI/BI Dashboard | `src/dashboards/*.lvdash.json` — Lakeview dashboard on the gold view |
| Genie Space | `src/genie/*.genie.yml` — Genie space over gold + metric views |
| Databricks Workflow | `resources/*.job.yml` — multi-task Job from the orchestration graph |
| UC Ingestion | `src/ingestion/*` — per-connector Lakeflow Connect / Auto Loader / UC connection + secrets / custom Python |

Non-ETL targets don't require the reconcile gate (only the pipeline does).
Generated artifacts are honest scaffolds grounded in the recovered Domo shapes —
review before deploying.

---

## 3. MCP tools reference

Every tool is a thin wrapper over a `core/` function (also callable from the
console). Registered automatically by `server.py`.

| Tool | What it does |
|---|---|
| `domo_discover(scope)` | Tenant census + governance split + sources |
| `domo_inventory(asset_type, search)` | Typed, searchable asset inventory (with scores) |
| `domo_assess(scope)` | Per-asset classification + complexity/value/effort/usage |
| `filter_inventory(criteria)` | Multi-criteria filtered inventory + facets |
| `save_filter_set / list_filter_sets / apply_saved_filter` | Saved filter sets (= waves) |
| `suggest_dispositions(criteria)` | Suggested + saved disposition per asset |
| `rationalize_asset / rationalize_bulk / list_rationalizations` | Persist disposition decisions |
| `estimate_migration(domo_annual_spend)` | Future-state effort / consumption / savings |
| `orchestration_plan()` | Domo schedules + dependency graph → Databricks Workflows |
| `list_industry_models / industry_model_map(...)` | Model catalog + column mapping |
| `lakeflow_feasibility(source_system)` | Per-source ingestion rating (GREEN/AMBER/RED) |
| `transpile_lineage(lineage_id, ...)` | Magic ETL/SQL → SDP SQL + reconcile gate |
| `migration_plan()` | Disposition-aware, value-driven wave plan |

**REST equivalents** (web console) mirror these under `/api/*` — e.g.
`/api/inventory`, `/api/inventory/filter`, `/api/filter-sets`,
`/api/rationalize` (+`/suggest`, `/bulk`), `/api/rationalizations`,
`/api/estimate`, `/api/orchestration`, `/api/plan`, `/api/draft/{id}`,
`/api/create/{id}`.

---

## 4. Going live (real Domo + Databricks)

1. **Domo provider = live** in Configure; set `DOMO_CLIENT_ID` + export
   `DOMO_CLIENT_SECRET` (public plane — OAuth client-credentials). For dataflow
   internals + Beast Mode exports, add the instance developer token
   (`DOMO_INSTANCE` + `DOMO_DEVELOPER_TOKEN`).
2. **Databricks**: set a CLI profile (and host) in Configure to enable deploy;
   Create then runs `databricks bundle deploy`/`run`. Without a profile it writes
   a deployable bundle + prints the commands.
3. **Persistence**: set the store backend to Lakebase to share state across a
   team (defaults to a local JSON file).
4. To transpile a real flow you need its **export triplet** (Magic ETL JSON +
   dataset schema + card Beast Modes) — via the live instance plane, or upload it
   manually in the Build step.

State, scans, mappings, bundles, filter sets, and rationalizations persist to
the configured store throughout.

---

## 5. Design notes
- **Three layers:** `core/` (pure logic), `tools/` (MCP wrappers), `webapp/`
  (REST) — all over one engine, unit-testable offline.
- **Provider abstraction** is the seam to go live (`FixtureProvider` →
  `LiveProvider`), so tools never change.
- Scores and governance are **transparent, rule-based, and human-reviewable** —
  draft-grade triage signals, not authoritative labels. Confirm before relying
  on them, and override the value defaults with your own model.
