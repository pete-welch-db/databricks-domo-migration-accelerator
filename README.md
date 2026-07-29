# Databricks Domo Migration Accelerator

**Assess a Domo estate and migrate it to Databricks — via an MCP server *and* a
web console.**

> The Python package is `pseudo_domo_mcp` (it impersonates a Domo tenant's API
> surface so the whole workflow runs offline). The product is the *Databricks
> Domo Migration Accelerator*.

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

## Quick start

```bash
uv venv --python 3.11 .venv && source .venv/bin/activate
uv pip install -e .            # add --index-url <your-mirror> behind a proxy

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
| `store_backend` + `lakebase_instance` | State persistence: `local` (JSON file, default) or `lakebase` (Databricks Postgres) for durable, shared scan history / migration status / bundle registry. |
| `git_provider` + `git_repo` + `GIT_TOKEN` (env) | Optional: link a **GitHub** or **Azure DevOps** repo so Create commits the generated bundle as a PR. Token read from env, never stored. |

### Staying current with Databricks conventions

The SDP/DAB patterns the tool generates against are **not hardcoded** — they
track the [ai-dev-kit](https://github.com/databricks-solutions/ai-dev-kit) repo.
A pattern manifest is cached locally and refreshed on install; re-refresh
anytime via **⚙ Config → Refresh patterns from ai-dev-kit**. Fully offline-safe:
with no network, built-in defaults apply.

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
pseudo_domo_mcp/
  server.py            FastMCP server (stdio + streamable-http)
  webapp/              FastAPI console + zero-build HTML/CSS/JS frontend
  tools/               thin @mcp.tool wrappers (one per capability)
  core/                engine: provider select, DDL parse, classify, governance
                       inference, map, feasibility, assets (typed inventory),
                       graph (DAG), config, bundle (DAB writer), gitlink
  providers/           FixtureProvider (offline) | LiveProvider (Domo REST stub)
  transpiler/          6-agent Domo→Databricks transpiler + importable pipeline.run()
fixtures/
  tenant/              synthetic Domo census (datasets/dataflows/cards/pages)
  lineages/            full triplets (Magic ETL + schema + Beast Modes) for transpile
models/                vendored industry-model DDL (automotive, transport_shipping)
tests/                 end-to-end pytest
```

## License

See `LICENSE`. Vendored industry-model DDL retains its upstream license (see
`models/README.md`).
