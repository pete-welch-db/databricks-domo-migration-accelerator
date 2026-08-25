# FAQ — Databricks Domo Migration Accelerator

## What is this, in one line?
An offline-first accelerator that **assesses a Domo estate and migrates it to
Databricks**, exposed both as an **MCP server** (drive it from an AI client) and
an **operator web console**. It follows a Lakebridge-style methodology:
**Assess → Rationalize → Convert → Reconcile**.

## How does it relate to Databricks Lakebridge?
Lakebridge (Databricks Labs) migrates SQL/ETL/BI to Databricks via
**Profiler + Analyzer → Convert → Reconcile**. This accelerator brings that
same discipline to **Domo specifically** — which Lakebridge and Genie Code
`/importBI` do not cover today (`/importBI` handles Power BI & Tableau) — and
adds an explicit **Rationalize** step (decide what to migrate before porting).
Where Lakebridge has a Profiler/Analyzer, we have scoring (complexity, value,
effort, usage); where it has Reconcile, we have a schema-parity gate.

## Does it need a live Domo tenant or a Databricks workspace?
No. It runs **fully offline** on synthetic fixtures shaped after Domo's public
REST API — no network, no tenant, no workspace. Point it at a real tenant +
workspace via config when you're ready (see the Guide → *Going live*).

## What are the steps / phases?
1. **Configure** — catalog/schema, Databricks profile, Domo provider.
2. **Connect** — one click connects + runs a discovery scan.
3. **Discover** — the full typed inventory with governance + scores; filter it.
4. **Rationalize** — set a disposition + target surface per asset.
5. **Model** — pick the industry data model(s) to map onto.
6. **Plan** — a value-driven, disposition-aware wave plan.
7. **Build & Deploy** — analyze → map → draft → create the Lakeflow pipeline.

## What does the accelerator score, and how?
Every dataflow carries transparent, rule-based signals (no ML — all explainable):
- **Complexity** (0-100): SQL vs Magic ETL, action count, joins, Beast Modes, writeback.
- **Value** (band): illustrative per-domain default — override with your model.
- **Effort** (1-5): anchored on complexity, bumped for raw SQL without a triplet and for writeback.
- **Usage** (0-100, **proxy**): dependent-card count + refresh cadence + relative scale.

## Is usage measured or estimated?
**Measured when available.** The provider pulls the Domo **Activity Log** (views
+ distinct users) and **DataFlow execution history** (run recency/frequency,
last status); `score_usage` uses those and marks `is_proxy: False`. When a tenant
doesn't expose them, it falls back to a **proxy** (dependent-card count + refresh
cadence + scale, `is_proxy: True`) so discovery still works offline. The bundled
fixtures ship a synthetic activity log + run history, so the whole
usage → duplicates → priority story is demoable with no tenant.

## How does it find "copies of copies" and what to migrate first?
- **Duplicate detection** (`core/dedup.py`) clusters dataflows that read the
  **identical input dataset set** — the copy-of-a-copy signature — picks the
  most-used member as **canonical**, and flags the rest. In Rationalize, unused
  duplicates default to **Retire** and used ones to **Consolidate** (into the
  canonical) — suggestions only; you confirm.
- **Migration priority** (`priority_score`, 0–100) = usage (heaviest) + business
  value − migration effort − a duplicate penalty. The Plan leads with the
  highest-priority objects; the low-usage / unused-duplicate "garbage pile" sinks
  to the bottom and shows up under the **Retire candidates** filter.

## What are the disposition options and target surfaces?
- **Dispositions:** Retire · Repoint · Rebuild · Elevate · Consolidate.
- **Target surfaces:** AI/BI + Genie · Genie App Builder · Sigma Input Tables ·
  Databricks Apps + Lakebase · none (retire).
Suggestions are pre-filled from the assess signals; you confirm or override, and
decisions persist and flow into the plan and estimate.

## What is a "filter set" / wave?
A saved set of discovery filters (governance, domain, value, complexity, effort,
usage). A saved filter set **is a migration-wave candidate** — scope a slice,
then rationalize or bulk-assign it.

## How is the wave plan built?
If you've assigned waves in Rationalize, the plan **honors your decisions**
(retired assets excluded, grouped by assigned wave). Otherwise it falls back to
an auto heuristic: governed pipelines ranked by value-to-effort into Wave 1/2,
shadow-IT (Apps+Lakebase re-platform) as Wave 3.

## What does the future-state estimate include?
Directional migration **FTE-weeks** (from the effort scores), a **target
consumption t-shirt size**, the split by target surface, and — if you pass your
current Domo annual spend — a **savings framing**. It's directional until
discovery runs on the live tenant; size precisely with the Databricks sizing
tools (Quicksizer / Lakemeter) once scope is fixed.

## Does it handle Domo orchestration (schedules / dependencies)?
Yes. It recovers per-dataflow **schedule/cadence** and the **dependency graph**
(edge A→B when A's output dataset feeds B's input), and maps the chain to a
**Databricks Workflow** (a multi-task Job with `depends_on` links) + Lakeflow
schedules. Dependencies are derived from API-observable output→input links;
confirm exact triggers from the Domo instance plane before finalizing.

## What actually gets migrated, and how are dashboards handled?
- **Magic ETL / SQL DataFlows** → Lakeflow Declarative Pipelines (the Build step).
- **Beast Modes** → Unity Catalog **metric views** (the #1 gotcha — folded into
  the gold semantic layer so cards render correct numbers).
- **Cards / pages** → **repoint** the Domo dataset to the new governed gold
  table (connector swap, schema parity) — avoids rebuilding every dashboard —
  or **elevate** high-value ones to AI/BI + Genie.
- **Connectors** → a Databricks ingestion path (Lakeflow Connect / Auto Loader /
  Apps + Lakebase for writeback).

## What's the "reconcile gate"?
Before Create, the transpiler verifies the rebuilt gold table matches the Domo
DataSet's exact columns/types and that every Beast Mode is folded in
(PASS / NEEDS_REVIEW). SQL DataFlows route to human review rather than failing.

## MCP server or web console — which do I use?
Both are the same engine. Use the **MCP server** to drive the migration
conversationally from Claude Code / Cursor / Genie Code; use the **web console**
for a click-through operator experience. Every console endpoint wraps the same
`core/` function an MCP tool calls.

## What Domo API access is needed to go live?
Domo has two planes: **public** (OAuth client-credentials — datasets, streams,
pages, card metadata) and **instance** (developer token — dataflow internals +
Beast Mode exports). Discovery/assessment work on the public plane; transpiling a
flow needs the instance-plane export triplet (Magic ETL JSON + dataset schema +
card Beast Modes). See the Guide → *Going live*.

## Is any of this customer-specific?
No. The package ships customer-agnostic on a fictional company. Industry models
are vendored from the open-source Databricks Industry Data Models; the MCP
scaffold follows ai-dev-kit.

## Where is state stored?
A local JSON file by default (`.pseudo_domo_state.json`), or **Lakebase**
(managed Postgres) when configured — same interface, degrades to local on any
failure. Scans, mappings, bundles, **filter sets**, and **rationalizations** all
persist there.
