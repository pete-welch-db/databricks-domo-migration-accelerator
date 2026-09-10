# Databricks Domo Migration Accelerator

**Assess a Domo estate and migrate it to Databricks — via an MCP server *and* a
web console.**

> The Python package is `pseudo_domo_mcp` (it impersonates a Domo tenant's API
> surface so the whole workflow runs offline). The product is the *Databricks
> Domo Migration Accelerator*.

The methodology mirrors Databricks **Lakebridge** (Profiler + Analyzer →
Convert → Reconcile), extended with a value-driven decision step:

**Assess → Rationalize → Convert → Reconcile**

- **Assess** — inventory + governance inference + per-asset **complexity, value,
  effort (1-5), and a usage proxy** (dependent cards + refresh cadence + scale).
- **Rationalize** — decide each asset's **disposition** (Retire · Repoint ·
  Rebuild · Elevate · Consolidate) and **target surface** (AI/BI + Genie ·
  Genie App Builder · Sigma Input Tables · Apps + Lakebase); suggestions are
  pre-filled from the assess signals. **Filtered discovery** narrows the estate,
  and a saved filter set is a migration **wave**.
- **Convert** — transpile Magic ETL / SQL DataFlows to Lakeflow pipelines +
  Unity Catalog metric views; recover Domo **orchestration** (schedules +
  dataflow dependencies) and map it to Databricks Workflows.
- **Reconcile** — schema-parity gate on the rebuilt gold.

A **future-state estimate** rolls the effort scores + decisions into migration
FTE-weeks, a target consumption size, and (with your Domo spend) a savings frame.

It packages the Domo discovery / assessment / migration workflow two ways over
one engine:

- an **MCP server** (FastMCP, stdio + streamable-HTTP) so an AI client (Claude
  Code, Cursor, Genie Code, …) can drive the migration conversationally, and
- an **operator web console** (FastAPI + a zero-build HTML/JS frontend) that
  lets you click a Magic ETL or dashboard, **Analyze** its data flow, **Draft**
  the Databricks pipeline code, and **Create** it — with catalog/schema config.

It runs **fully offline on synthetic fixtures** shaped after Domo's public REST
API — no live tenant, no Databricks workspace, no network required. When you're
ready, point it at a real Domo tenant (OAuth) and a real Databricks workspace
(CLI/OAuth) via config, and the same tools deploy real Lakeflow Declarative
Pipelines.

> Everything ships customer-agnostic. The bundled data is a fictional company
> ("Northwind Manufacturing"). The industry data models under `models/` are
> vendored from the open-source
> [Databricks Industry Data Models](https://github.com/databricks-industry-solutions/lakehouse-industry-data-models);
> the MCP scaffold follows the
> [ai-dev-kit](https://github.com/databricks-solutions/ai-dev-kit)
> `databricks-mcp-server` pattern.

## Why "pseudo-Domo"

It impersonates the *surface* of a Domo tenant (datasets, dataflows, cards,
pages, sources) so the whole discover → assess → analyze → draft → create
workflow is exercisable before you have tenant credentials. All tenant reads go
through a provider abstraction (`pseudo_domo_mcp/providers/`): `FixtureProvider`
(default, offline) today; `LiveProvider` (real Domo REST — OAuth2
client_credentials) when creds land. Swapping is one config change; the tools
never change.

## The workflow

The console is a **wizard**:

```
 Configure ─► Connect ─► Discover ─► Assess ─► Plan ─► Build & Deploy
```

- **Configure / Connect** — set the Databricks target + Domo provider, then
  connect (fixture mode connects instantly to the bundled sample tenant).
- **Discover** — a **Discovery Scan** builds a typed, searchable inventory of
  every asset: **connectors, Magic ETL, SQL DataFlows, DataSets, cards, Beast
  Modes, pages**. Search by name and filter by type. **Connectors are
  first-class** and each carries a Databricks ingestion remap plan (Lakeflow
  Connect / Auto Loader / Apps+Lakebase), because source connections are what
  must be explicitly re-mapped.
- **Assess** — governed vs. shadow IT is **inferred** (Domo has no governance
  field) from source/connector type, writeback, owner shape, and refresh
  cadence, with a confidence score and the **signals behind each call** shown
  for confirm/override.
- **Plan** — a value-driven wave plan + per-connector ingestion strategy.
- **Build & Deploy** — pick a migratable asset →
  - **Analyze**: the Magic ETL DAG as a medallion-layered (bronze → silver →
    gold) SVG, built from the *same* parser that transpiles it.
  - **Draft**: the 6-agent transpiler returns bronze/silver/gold Spark SQL + a
    semantic view folding the card's Beast Modes + a **PASS/FAIL reconcile gate**.
  - **Create** (progressive): *always* writes a deployable Databricks Asset
    Bundle (`databricks.yml` + SQL) and shows the deploy command; deploys via
    `databricks bundle deploy` when a profile is set; optionally commits the
    bundle to a linked **GitHub / Azure DevOps** repo as a PR.

Config is reachable anytime via **⚙ Config**.

## The MCP tools

| Tool | What it does |
|---|---|
| `domo_discover` | Inventory the tenant — datasets/dataflows/cards/pages/sources + an inferred governed/shadow split. |
| `domo_inventory` | Typed, searchable asset inventory (connector / magic_etl / sql_dataflow / dataset / card / beast_mode / page); connectors carry a Databricks remap plan. |
| `domo_assess` | Classify each object by data **domain** + **source**, **infer** governance (with signals + confidence), score **complexity** and **value**. |
| `list_industry_models` | List vendored industry models (`automotive`, `transport_shipping`) + their domains/tables. |
| `industry_model_map` | Draft-map a Domo DataSet's columns → a canonical industry-model table (similarity + confidence + unmapped flags). |
| `lakeflow_feasibility` | Score each source system GREEN/AMBER/RED for **Lakeflow Connect** ingestion + recommended pattern. |
| `transpile_lineage` | 6-agent transpiler → medallion Spark SQL + folded Beast Modes + repoint plan + reconcile gate. |
| `migration_plan` | Aggregate all of the above into a prioritized, value-driven **wave plan**. |

## Requirements

Python 3.11+. Runtime dependencies are declared in `pyproject.toml` and
mirrored in `requirements.txt` (the Databricks App runtime installs from the
latter):

| Package | Why |
|---|---|
| `fastmcp` | the MCP server (stdio + streamable-HTTP) |
| `fastapi`, `uvicorn[standard]`, `python-multipart` | the web console + file uploads |
| `databricks-sdk==0.137.0` | Lakebase credentials + App service-principal auth. **Pinned** — a loose range lets the App runtime resolve a version without the `w.database` Lakebase API, which silently falls back to local storage. |
| `psycopg[binary]` | the Lakebase (Postgres) store backend |

`databricks-sdk` + `psycopg` are only exercised when `store_backend=lakebase`
(or when running as an App); with the default local file store the tool needs
neither at runtime.

> Databricks machines have no direct PyPI egress, so `pyproject.toml`'s
> `[tool.uv]` pins the internal mirror. Off-network, override it with
> `uv pip install -e . --index-url https://pypi.org/simple/`.

## Quick start

```bash
uv venv --python 3.11 .venv && source .venv/bin/activate
uv pip install -e .            # uses the mirror pinned in pyproject [tool.uv]

# 1) Web console (browse → analyze → draft → create)
python -m pseudo_domo_mcp.webapp.app        # http://127.0.0.1:8010

# 2) MCP server — stdio (for Claude Code / Cursor)
python -m pseudo_domo_mcp.server

# 3) MCP server — HTTP
PSEUDO_DOMO_TRANSPORT=http PORT=8000 python -m pseudo_domo_mcp.server
```

> `127.0.0.1:8000/mcp` is the **MCP protocol** endpoint (it speaks
> `text/event-stream`), not a web page — open a browser at the **web console**
> port instead.

### Connect the MCP to Claude Code

`.mcp.json` in this repo registers the stdio server. Then ask, e.g.:

> "Discover the Domo tenant, give me the migration plan, then transpile the pilot."

## Configuration

Set in the web console's **⚙ Config** panel or via env (persisted to
`.pseudo_domo_config.json`, git-ignored):

| Setting | Purpose |
|---|---|
| `catalog` / `schema` | Default Unity Catalog target for generated pipelines. **Overridable per asset** at Create (a domain/BU can target its own catalog/schema). |
| `pipeline_language` | `sql` or `python` — the SDP source language. Overridable per asset. |
| `industry_models` | Which Databricks Industry Data Model(s) to draft-map onto (universal; references the open-source repo). Multi-select. |
| `databricks_profile` | Databricks CLI profile (`databricks auth login`). Empty = write bundle files only; set = deploy for real. OAuth handled by the CLI; no workspace secret stored. |
| `domo_provider` | `fixture` (offline) or `live` (Domo REST). |
| `domo_client_id` + `DOMO_CLIENT_SECRET` (env) | Domo OAuth2 client_credentials. The **secret** is read from the environment, never written to config. |
| `store_backend` + `lakebase_instance` | State persistence: `local` (JSON file, default) or `lakebase` (Databricks Postgres) for durable, shared scan history / migration status / bundle registry / saved config. As an App these come from env (`PSEUDO_DOMO_STORE_BACKEND` / `PSEUDO_DOMO_LAKEBASE_INSTANCE`). |
| `llm_endpoint` (+ `DATABRICKS_TOKEN` env locally) | **Optional** LLM enhancement via a Databricks model serving endpoint (e.g. `databricks-claude-sonnet-5`). Off by default — the tool stays fully deterministic and offline; when set, the LLM only *augments* (governance rationale, mapping second-opinion, SQL-flow / Beast-Mode drafts) and always falls back. Locally authenticates with `DATABRICKS_TOKEN`; in an App with the service-principal token (no static token). |
| `git_provider` + `git_repo` + `GIT_TOKEN` (env) | Optional: link a **GitHub** or **Azure DevOps** repo so Create commits the generated bundle as a PR. Token read from env, never stored. |

> **Precedence:** persisted config (local file, or the store in an App) is
> overlaid by environment variables, so `app.yaml` / shell env always win.

### Staying current with Databricks conventions

The SDP/DAB patterns the tool generates against are **not hardcoded** — they
track the [ai-dev-kit](https://github.com/databricks-solutions/ai-dev-kit) repo.
A pattern manifest is cached locally and refreshed on install; re-refresh
anytime via **⚙ Config → Refresh patterns from ai-dev-kit**. Fully offline-safe:
with no network, built-in defaults apply.

## Deploy as a Databricks App

The **same codebase** runs locally *and* as a fully managed Databricks App — no
fork. `core/runtime.py` detects the App runtime (the `DATABRICKS_APP_NAME` env
var the platform injects) and flips a few seams; local behaviour is untouched:

| Seam | Local | Databricks App |
|---|---|---|
| Web bind | `127.0.0.1:8010` | `0.0.0.0` on the App port |
| Config persistence | `.pseudo_domo_config.json` | the store (Lakebase) — an App's filesystem is ephemeral + per-replica |
| Store backend | from the config file | from injected env (`PSEUDO_DOMO_STORE_BACKEND` / `PSEUDO_DOMO_LAKEBASE_INSTANCE`) |
| LLM auth | `DATABRICKS_TOKEN` | the App service principal's OAuth token (via the SDK) |

It ships as **two apps** over one engine:

- **Console** — `app.yaml` (repo root): `python -m pseudo_domo_mcp.webapp.app`.
- **MCP server** — `deploy/mcp.app.yaml`: `python -m pseudo_domo_mcp.server`
  over streamable-HTTP. For Genie Code discovery the app **name must start with
  `mcp-`**.

**App env (set in `app.yaml`):** `PORT=8000`, `PSEUDO_DOMO_PROVIDER=fixture`,
`PSEUDO_DOMO_STORE_BACKEND` (`lakebase` for the console / `local` for the MCP),
`PSEUDO_DOMO_LAKEBASE_INSTANCE`, `PSEUDO_DOMO_LLM_ENDPOINT`.

### Deploy the console

```bash
P=<your-cli-profile>
WS=/Workspace/Users/<you>/domo-migration-console

# 1) Create the app (provisions its service principal)
databricks apps create domo-migration-console -p $P

# 2) Sync source + deploy
databricks sync . $WS --full \
  --exclude .venv --exclude .git --exclude __pycache__ \
  --exclude generated --exclude .pytest_cache -p $P
databricks apps deploy domo-migration-console --source-code-path $WS -p $P
```

Then attach two **resources** (CLI `databricks apps update`, or App UI → Edit):

- **Database** → your Lakebase instance, permission *Can connect and create*
  (auto-injects `PGHOST/PGUSER/PGDATABASE/PGPORT`).
- **Model serving** → the LLM endpoint, permission *Can query*.

…and register the app's service principal as a **Lakebase Postgres role** so its
OAuth token can log in (Lakebase identity federation):

```bash
databricks api post /api/2.0/database/instances/<instance>/roles -p $P --json '{
  "name": "<app-service-principal-client-id>",
  "identity_type": "SERVICE_PRINCIPAL",
  "membership_role": "DATABRICKS_SUPERUSER"
}'
```

**Redeploy** after attaching resources so the injected env is picked up. Verify
with `GET /api/debug/store` (backend + connect error) and `/api/debug/llm`
(a live model round-trip) — both behind the App's SSO.

### Deploy the MCP app

Apps only read `app.yaml` at the source root, so deploy the MCP manifest by
importing it over that folder's `app.yaml`:

```bash
WS=/Workspace/Users/<you>/mcp-domo-migration
databricks apps create mcp-domo-migration -p $P
databricks sync . $WS --full --exclude .venv --exclude .git \
  --exclude __pycache__ --exclude generated --exclude .pytest_cache -p $P
databricks workspace import $WS/app.yaml --file deploy/mcp.app.yaml \
  --format RAW --overwrite -p $P
databricks apps deploy mcp-domo-migration --source-code-path $WS -p $P
```

The MCP app uses `store_backend=local` (assessment tools are stateless), so its
service principal needs **no** Lakebase role.

### Deploy gotchas

- **Pin `databricks-sdk`** (see Requirements) — a loose range silently drops
  Lakebase to local storage.
- **App updates drop the SP's Lakebase grants** — re-attach the Database
  resource after editing the app.
- **Two `app.yaml`s, one repo** — a `databricks sync` into the MCP app's folder
  overwrites its `app.yaml` with the console's; re-import `deploy/mcp.app.yaml`
  before deploying the MCP app.
- **`Create` in an App** writes the bundle and (optionally) opens a git PR — it
  does **not** shell out to `databricks bundle deploy` (no CLI on the App path);
  use a configured CLI profile locally for in-place deploys.

## Test

```bash
python -m pytest -q      # end-to-end: discover→assess→map→feasibility→transpile gate→plan
```

## Going live

`LiveProvider` (`pseudo_domo_mcp/providers/live_provider.py`) documents the exact
Domo REST endpoint map (verified against developer.domo.com). Domo has **two API
planes**, and a full migration inventory needs both:

- **Public API** (`https://api.domo.com`, OAuth2 client_credentials; scopes
  `data user dashboard audit …`) — the census + schemas: `GET /v1/datasets`,
  `/v1/datasets/{id}` (schema.columns), `/v1/pages`, `/v1/cards` (metadata
  only), `/v1/streams`, `/v1/users`, `/v1/groups`.
- **Instance API** (`https://{instance}.domo.com`, `X-DOMO-Developer-Token`) —
  the transform internals: `GET /api/dataprocessing/v1/dataflows[/{id}]` (Magic
  ETL DAG + SQL body) and `/api/content/v1/cards` (Beast Mode expressions).

So the migration triplet = instance dataflow internals + public dataset schema +
instance card export. The public API alone gives the census + schemas but not the
transform logic or Beast Modes. To go live: set `domo_provider=live` + OAuth
credentials (and `DOMO_INSTANCE` + `DOMO_DEVELOPER_TOKEN` for the transform
triplet), then implement the stubbed reads.

## Layout

```
app.yaml               Databricks App manifest — CONSOLE (repo root)
requirements.txt       runtime deps for the App runtime (mirrors pyproject)
deploy/
  mcp.app.yaml         Databricks App manifest — MCP server
pseudo_domo_mcp/
  server.py            FastMCP server (stdio + streamable-http)
  webapp/              FastAPI console + zero-build HTML/CSS/JS frontend
  tools/               thin @mcp.tool wrappers (one per capability)
  core/                engine: runtime (local vs App detection), provider
                       select, DDL parse, classify, governance inference, map,
                       feasibility, assets (typed inventory), graph (DAG),
                       config, store (local JSON | Lakebase), llm (optional
                       serving-endpoint enhancement), bundle (DAB writer), gitlink
  providers/           FixtureProvider (offline) | LiveProvider (Domo REST stub)
  transpiler/          6-agent Domo→Databricks transpiler + importable pipeline.run()
fixtures/
  tenant/              synthetic Domo census (datasets/dataflows/cards/pages)
  lineages/            full triplets (Magic ETL + schema + Beast Modes) for transpile
models/                vendored industry-model DDL (automotive, transport_shipping)
tests/                 end-to-end pytest
```

## Documentation

- **[docs/GUIDE.md](docs/GUIDE.md)** — install, the full Assess → Rationalize →
  Convert → Reconcile workflow, the MCP tool + REST reference, and going live.
- **[docs/FAQ.md](docs/FAQ.md)** — what it is, how it relates to Lakebridge,
  scoring/usage, dispositions & surfaces, orchestration, estimation, and more.

## License

See `LICENSE`. Vendored industry-model DDL retains its upstream license (see
`models/README.md`).
