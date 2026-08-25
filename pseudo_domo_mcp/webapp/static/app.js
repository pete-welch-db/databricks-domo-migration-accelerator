"use strict";
const $ = (s, r = document) => r.querySelector(s);
const $$ = (s, r = document) => [...r.querySelectorAll(s)];
const api = async (path, opts) => (await fetch(path, opts)).json();

const PHASES = ["configure", "connect", "discover", "rationalize", "model", "plan", "build"];
const PHASE_LABEL = { configure: "Configure", connect: "Connect", discover: "Discover",
  rationalize: "Rationalize", model: "Model", plan: "Plan", build: "Build & Deploy" };

// Plain-language glossary — surfaced as hover tooltips throughout the UI.
const TIP = {
  complexity: "Migration complexity (0–100): how much effort to rebuild this on Databricks. Higher = harder. SQL DataFlows and writeback push it up.",
  value: "Estimated annual business value of the outcome this asset supports. Illustrative defaults — override with your own value model.",
  governance: "Governed (IT-owned pipeline) vs. shadow IT (citizen-dev). Inferred from source type, writeback, owner, and cadence — with a confidence %. Domo has no governance field, so confirm before relying on it.",
  domain: "The business data domain (customer, aftersales, quality, manufacturing, supply, logistics, finance) this asset serves.",
  type: "Domo object type. MAGIC = visual Magic ETL (deterministic transpile); SQL = SQL DataFlow (needs hand-review).",
  connector: "A source connection. Each must be re-mapped to a Databricks ingestion path: Lakeflow Connect (managed), Auto Loader (files), or Apps + Lakebase (writeback).",
  beast_mode: "A Domo card-level calculated field. Not in the Magic ETL export — migrates into the gold semantic view, or the card renders wrong numbers.",
  magic_etl: "Domo's visual transform builder. Its DAG transpiles deterministically to a Databricks Lakeflow Declarative Pipeline.",
  sql_dataflow: "A Domo transform written in SQL. Captured and flagged for hand-translation to Spark SQL.",
  rating: "Lakeflow Connect feasibility. GREEN = managed connector exists; AMBER = Auto Loader / file path; RED = re-platform to Apps + Lakebase.",
  gate: "Reconcile gate: verifies the rebuilt gold table matches the Domo DataSet's exact columns/types and that every Beast Mode is folded in.",
};
const tip = (k, cls = "") => `data-tip="${esc(TIP[k] || k)}"${cls ? ` class="${cls}"` : ""}`;

const state = {
  phase: "configure", reached: { configure: true }, connected: false,
  config: null, inventory: null, assets: [], filterType: "", search: "",
  filters: {}, facets: {}, dispositions: {}, ratSearch: "",
  buildAsset: null, draft: null, activeSql: "gold",
};

// ------------------------------------------------------------ wizard rail --
function renderRail() {
  const rail = $("#wizard-rail");
  rail.innerHTML = "";
  PHASES.forEach((p, i) => {
    const step = document.createElement("button");
    const reached = state.reached[p];
    step.className = "rail-step" +
      (p === state.phase ? " active" : "") + (reached ? " reached" : " locked");
    step.innerHTML = `<span class="rail-num">${i + 1}</span><span>${PHASE_LABEL[p]}</span>`;
    step.onclick = () => { if (reached) goPhase(p); };
    rail.appendChild(step);
    if (i < PHASES.length - 1) {
      const sep = document.createElement("span");
      sep.className = "rail-sep"; sep.textContent = "›"; rail.appendChild(sep);
    }
  });
}

function goPhase(p) {
  state.phase = p;
  state.reached[p] = true;
  $$(".phase").forEach(s => s.classList.toggle("hidden", s.dataset.phase !== p));
  renderRail();
  if (p === "discover") onEnterDiscover();
  if (p === "rationalize") loadRationalize();
  if (p === "model") loadModel();
  if (p === "plan") loadPlan();
  if (p === "build") loadBuild();
}
function nextPhase() { const i = PHASES.indexOf(state.phase); if (i < PHASES.length - 1) advance(PHASES[i + 1]); }
function prevPhase() { const i = PHASES.indexOf(state.phase); if (i > 0) goPhase(PHASES[i - 1]); }

async function advance(target) {
  // side-effects when leaving a phase
  if (state.phase === "configure") await saveWizardConfig();
  goPhase(target);
}

// ------------------------------------------------------------ configure ----
function fillConfigureForm() {
  const c = state.config || {};
  $("#w-catalog").value = c.catalog || "";
  $("#w-schema").value = c.schema || "";
  $("#w-profile").value = c.databricks_profile || "";
  $("#w-host").value = c.databricks_host || "";
  $("#w-provider").value = c.domo_provider || "fixture";
  $("#w-domo-id").value = c.domo_client_id || "";
  $("#w-secret-note").textContent = c.domo_secret_present
    ? "DOMO_CLIENT_SECRET detected in environment ✓"
    : "Live mode reads DOMO_CLIENT_SECRET from the environment (not stored here).";
}
async function saveWizardConfig() {
  const updates = {
    catalog: $("#w-catalog").value, schema: $("#w-schema").value,
    databricks_profile: $("#w-profile").value, databricks_host: $("#w-host").value,
    domo_provider: $("#w-provider").value, domo_client_id: $("#w-domo-id").value };
  state.config = await api("/api/config",
    { method: "POST", headers: { "Content-Type": "application/json" }, body: JSON.stringify(updates) });
  refreshPills();
}

// ------------------------------------------------------------ connect ------
async function doConnect() {
  const s = $("#connect-status");
  s.className = "connect-status working";
  s.textContent = "Connecting…";
  const btn = $("#btn-connect");
  btn.disabled = true; btn.textContent = "Connecting…";
  try {
    // fixture mode: a discovery summary call IS the connection test.
    const sum = await api("/api/estate");
    state.connected = true;
    const prov = state.config.domo_provider;
    s.className = "connect-status ok";
    s.innerHTML = `Connected (<b>${prov}</b>) — ${sum.summary.counts.dataflows} flows, `
      + `${sum.summary.counts.datasets} datasets, ${sum.summary.counts.cards} cards. `
      + `Running discovery scan…`;
    btn.textContent = "Scanning…";
    // One click: connect → scan → land on Discover with results loaded.
    await runScan();
    goPhase("discover");
  } catch (e) {
    s.className = "connect-status err";
    s.textContent = "Connection failed: " + e;
  } finally {
    btn.disabled = false; btn.textContent = "🔌 Connect & Scan";
  }
}

// ------------------------------------------------------------ discover -----
function onEnterDiscover() {
  // Scan already ran during Connect; if somehow not, run it now.
  if (!state.inventory) runScan();
}
async function runScan() {
  const btn = $("#btn-scan");
  if (btn) { btn.disabled = true; btn.textContent = "Scanning…"; }
  const inv = await api("/api/inventory");
  state.inventory = inv;
  state.assets = inv.assets;
  state.facets = inv.facets || {};
  if (btn) { btn.disabled = false; btn.textContent = "↻ Re-scan"; }

  // summary tiles
  const sum = $("#scan-summary");
  sum.classList.remove("hidden");
  sum.innerHTML = inv.asset_types.map(t => {
    const n = inv.counts_by_type[t.key] || 0;
    return `<button class="tile" data-type="${t.key}" title="${t.hint}">
      <div class="tile-n">${n}</div><div class="tile-l">${t.label}</div>
      ${t.build ? '<div class="tile-tag">build</div>' : ''}</button>`;
  }).join("");
  $$("#scan-summary .tile").forEach(b => b.onclick = () => setFilter(b.dataset.type));

  // type filter chips
  const tf = $("#type-filters");
  tf.innerHTML = `<button class="tfilter active" data-type="">All</button>` +
    inv.asset_types.map(t => `<button class="tfilter" data-type="${t.key}">${t.label}</button>`).join("");
  $$("#type-filters .tfilter").forEach(b => b.onclick = () => setFilter(b.dataset.type));

  renderFilterBar();
  $("#discover-body").classList.remove("hidden");
  const nextBtn = $("#btn-to-model"); if (nextBtn) nextBtn.disabled = false;
  renderAssets();
}
function setFilter(type) {
  state.filterType = type;
  $$("#type-filters .tfilter").forEach(b => b.classList.toggle("active", b.dataset.type === type));
  renderAssets();
}

// Multi-criteria filter bar (governance / domain / value / effort / usage),
// built from the facets the backend returns. A saved set = a migration wave.
const FILTER_DIMS = [
  ["governance", "Governance"], ["data_domain", "Domain"],
  ["value_band", "Value"], ["complexity_band", "Complexity"],
  ["effort_band", "Effort"], ["usage_band", "Usage"],
];
function renderFilterBar() {
  const bar = $("#filter-bar");
  if (!bar) return;
  const sel = (dim, label) => {
    const opts = (state.facets[dim] || []);
    if (!opts.length) return "";
    return `<label class="fsel"><span>${label}</span>
      <select data-dim="${dim}"><option value="">any</option>
        ${opts.map(o => `<option value="${esc(o)}" ${state.filters[dim] === o ? "selected" : ""}>${esc(o)}</option>`).join("")}
      </select></label>`;
  };
  bar.innerHTML = FILTER_DIMS.map(([d, l]) => sel(d, l)).join("")
    + `<button id="f-clear" class="btn ghost tiny">Clear</button>`
    + `<button id="f-save" class="btn ghost tiny">★ Save as wave</button>`
    + `<span id="f-count" class="muted small"></span>`;
  $$("#filter-bar select").forEach(s => s.onchange = () => {
    const d = s.dataset.dim; if (s.value) state.filters[d] = s.value; else delete state.filters[d];
    renderAssets();
  });
  $("#f-clear").onclick = () => { state.filters = {}; renderFilterBar(); renderAssets(); };
  $("#f-save").onclick = saveFilterSet;
}
function matchFilters(a) {
  const f = state.filters;
  if (f.governance && a.governance !== f.governance) return false;
  if (f.data_domain && a.data_domain !== f.data_domain) return false;
  if (f.value_band && (a.value || {}).band !== f.value_band) return false;
  if (f.complexity_band && (a.complexity || {}).band !== f.complexity_band) return false;
  if (f.effort_band && (a.effort || {}).band !== f.effort_band) return false;
  if (f.usage_band && (a.usage || {}).band !== f.usage_band) return false;
  return true;
}
function filteredAssets() {
  const s = state.search.toLowerCase();
  let items = state.assets;
  if (state.filterType) items = items.filter(a => a.asset_type === state.filterType);
  if (s) items = items.filter(a => (a.name || "").toLowerCase().includes(s));
  items = items.filter(matchFilters);
  return items;
}
function renderAssets() {
  const list = $("#asset-list");
  const items = filteredAssets();
  const c = $("#f-count"); if (c) c.textContent = `${items.length} of ${state.assets.length} assets`;
  list.innerHTML = items.map(assetCard).join("") || `<div class="loading">No matching assets.</div>`;
}
async function saveFilterSet() {
  const name = prompt("Name this wave / filter set:", "Wave — " +
    (state.filters.data_domain || state.filters.governance || "custom"));
  if (!name) return;
  await api("/api/filter-sets", { method: "POST", headers: { "Content-Type": "application/json" },
    body: JSON.stringify({ name, criteria: { ...state.filters, asset_type: state.filterType || undefined } }) });
  const b = $("#f-save"); b.textContent = "✓ Saved"; setTimeout(() => b.textContent = "★ Save as wave", 1500);
}
function assetCard(a) {
  const gov = a.governance && a.governance !== "n/a"
    ? `<span class="chip gov-${a.governance}">${a.governance}${a.governance_confidence ? " " + Math.round(a.governance_confidence * 100) + "%" : ""}</span>` : "";
  let extra = "";
  if (a.asset_type === "connector") {
    const r = a.databricks_remap;
    extra = `<div class="remap"><span class="rate ${r.rating}" ${tip("rating")}>${r.rating}</span> → ${esc(r.connector)}<div class="muted small">${esc(r.rationale)}</div></div>`;
  } else if (a.asset_type === "magic_etl" || a.asset_type === "sql_dataflow") {
    extra = `<div class="muted small">${a.action_count ?? 0} actions · ${a.has_triplet ? "full lineage" : "metadata only"}</div>`;
  } else if (a.asset_type === "dataset") {
    extra = `<div class="muted small">${(a.rows || 0).toLocaleString()} rows · ${a.columns} cols · ${a.source_system}</div>`;
  } else if (a.asset_type === "card") {
    extra = `<div class="muted small">${a.card_type} · ${a.beast_mode_count} Beast Modes</div>`;
  }
  // Assess scores (Profiler/Analyzer) — value / complexity / effort / usage.
  const sc = [];
  if (a.value && a.value.band) sc.push(`<span class="chip sc val-${a.value.band}" ${tip("value")}>val ${a.value.band}</span>`);
  if (a.complexity && a.complexity.band) sc.push(`<span class="chip sc cx-${a.complexity.band}" ${tip("complexity")}>cx ${a.complexity.band}</span>`);
  if (a.effort && a.effort.effort_1_5) sc.push(`<span class="chip sc ef-${a.effort.band}">effort ${a.effort.effort_1_5}/5</span>`);
  if (a.usage && typeof a.usage.usage_score === "number") sc.push(`<span class="chip sc us-${a.usage.band}">use ${a.usage.usage_score}</span>`);
  const scores = sc.length ? `<div class="scores">${sc.join("")}</div>` : "";
  const sig = (a.governance_signals || []).length
    ? `<details class="why"><summary>why ${a.governance}?</summary><ul>${a.governance_signals.map(x => `<li>${esc(x)}</li>`).join("")}</ul></details>` : "";
  const path = a.migration_path_label
    ? `<div class="mpath ${a.build ? "buildable" : ""}">↳ ${esc(a.migration_path_label)}</div>` : "";
  return `<div class="asset-card">
    <div class="ac-head"><span class="atype at-${a.asset_type}" ${tip(a.asset_type)}>${typeLabel(a.asset_type)}</span>
      <span class="ac-name">${esc(a.name || a.id)}</span>${gov}</div>
    ${extra}${scores}${path}${sig}</div>`;
}
const TYPE_LABEL = { connector: "Connector", magic_etl: "Magic ETL", sql_dataflow: "SQL DataFlow",
  dataset: "DataSet", card: "Card", beast_mode: "Beast Mode", page: "Page" };
const typeLabel = t => TYPE_LABEL[t] || t;

// ------------------------------------------------------------ rationalize --
const DISPOSITIONS = ["Retire", "Repoint", "Rebuild", "Elevate", "Consolidate"];
const SURFACES = [["ai_bi_genie", "AI/BI + Genie"], ["genie_app_builder", "Genie App Builder"],
  ["sigma_input_tables", "Sigma Input Tables"], ["apps_lakebase", "Apps + Lakebase"], ["none", "None (retire)"]];

async function loadRationalize() {
  const wrap = $("#rat-table-wrap");
  wrap.innerHTML = `<div class="loading">Loading suggestions…</div>`;
  const sug = await api("/api/rationalize/suggest", { method: "POST",
    headers: { "Content-Type": "application/json" }, body: "{}" });
  state.ratRows = sug.rows || [];
  renderRatBulk();
  renderRatTable();
  await refreshRatRollup();
}
function ratVisible() {
  const s = (state.ratSearch || "").toLowerCase();
  return state.ratRows.filter(r => !s || (r.name || "").toLowerCase().includes(s));
}
function renderRatTable() {
  const rows = ratVisible().map(r => {
    const cur = r.decided || r.suggested || {};
    const disp = cur.disposition || "";
    const surf = cur.target_surface || "";
    const dsel = `<select class="rat-disp" data-id="${esc(r.asset_id)}"><option value="">—</option>` +
      DISPOSITIONS.map(d => `<option value="${d}" ${d === disp ? "selected" : ""}>${d}</option>`).join("") + `</select>`;
    const ssel = `<select class="rat-surf" data-id="${esc(r.asset_id)}"><option value="">—</option>` +
      SURFACES.map(([k, l]) => `<option value="${k}" ${k === surf ? "selected" : ""}>${l}</option>`).join("") + `</select>`;
    const badge = r.decided ? `<span class="chip gov-governed">saved</span>` : `<span class="chip sc">suggested</span>`;
    const scores = `${r.value_band ? `<span class="chip sc val-${r.value_band}">val ${r.value_band}</span>` : ""}
      ${r.effort_1_5 ? `<span class="chip sc">eff ${r.effort_1_5}/5</span>` : ""}
      ${typeof r.usage_score === "number" ? `<span class="chip sc">use ${r.usage_score}</span>` : ""}`;
    return `<tr>
      <td><div class="rat-name">${esc(r.name || r.asset_id)}</div>
        <div class="muted small">${typeLabel(r.asset_type)}${r.governance && r.governance !== "n/a" ? " · " + r.governance : ""}</div></td>
      <td class="rat-scores">${scores}</td>
      <td>${dsel}</td>
      <td>${ssel}</td>
      <td><input class="rat-rat" data-id="${esc(r.asset_id)}" type="text" value="${esc(cur.rationale || "")}" placeholder="rationale…" /></td>
      <td>${badge} <button class="btn ghost tiny rat-save" data-id="${esc(r.asset_id)}">Save</button></td>
    </tr>`;
  }).join("") || `<tr><td colspan="6" class="loading">No assets.</td></tr>`;
  $("#rat-table-wrap").innerHTML = `<table class="rat-table">
    <thead><tr><th>Asset</th><th>Signals</th><th>Disposition</th><th>Target surface</th><th>Rationale</th><th></th></tr></thead>
    <tbody>${rows}</tbody></table>`;
  $$(".rat-save").forEach(b => b.onclick = () => saveDisposition(b.dataset.id));
}
async function saveDisposition(id) {
  const row = $(`.rat-save[data-id="${CSS.escape(id)}"]`).closest("tr");
  const disposition = $(".rat-disp", row).value;
  if (!disposition) { alert("Pick a disposition first."); return; }
  await api("/api/rationalize", { method: "POST", headers: { "Content-Type": "application/json" },
    body: JSON.stringify({ asset_id: id, disposition,
      target_surface: $(".rat-surf", row).value, rationale: $(".rat-rat", row).value }) });
  const r = state.ratRows.find(x => x.asset_id === id);
  if (r) r.decided = { disposition, target_surface: $(".rat-surf", row).value, rationale: $(".rat-rat", row).value };
  renderRatTable(); refreshRatRollup();
}
function renderRatBulk() {
  $("#rat-bulk").innerHTML =
    `<span class="muted small">Bulk-apply to shown:</span>
     <select id="rat-bulk-disp"><option value="">disposition…</option>${DISPOSITIONS.map(d => `<option>${d}</option>`).join("")}</select>
     <button id="rat-bulk-go" class="btn ghost tiny">Apply</button>`;
  $("#rat-bulk-go").onclick = async () => {
    const d = $("#rat-bulk-disp").value; if (!d) return;
    const vis = ratVisible();
    if (!confirm(`Set ${vis.length} shown asset(s) to "${d}"?`)) return;
    for (const r of vis) {
      await api("/api/rationalize", { method: "POST", headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ asset_id: r.asset_id, disposition: d,
          target_surface: (r.suggested || {}).target_surface || "", rationale: "bulk" }) });
      r.decided = { disposition: d, target_surface: (r.suggested || {}).target_surface || "", rationale: "bulk" };
    }
    renderRatTable(); refreshRatRollup();
  };
}
async function refreshRatRollup() {
  const data = await api("/api/rationalizations");
  const roll = data.rollup || {};
  const disp = roll.by_disposition || {}; const surf = roll.by_target_surface || {};
  const chip = (k, v) => `<span class="chip sc">${esc(k)}: <b>${v}</b></span>`;
  $("#rat-rollup").innerHTML =
    `<div class="rr-line"><b>${roll.total || 0}</b> decided ·
      ${Object.entries(disp).map(([k, v]) => chip(k, v)).join(" ") || "<span class='muted small'>none yet</span>"}</div>
     ${Object.keys(surf).length ? `<div class="rr-line muted small">surfaces: ${Object.entries(surf).map(([k, v]) => chip(k, v)).join(" ")}</div>` : ""}
     <div id="rr-estimate"></div>`;
}
async function showEstimate() {
  const spend = prompt("Current Domo annual spend to frame savings (optional, $):", "");
  const q = spend ? `?domo_annual_spend=${encodeURIComponent(spend.replace(/[^0-9.]/g, ""))}` : "";
  const e = await api(`/api/estimate${q}`);
  const me = e.migration_effort || {};
  $("#rr-estimate").innerHTML = `<div class="rr-est">
    <b>Future-state estimate (directional)</b>
    <div>Migration effort: <b>${me.est_fte_weeks}</b> FTE-weeks across <b>${e.active_assets}</b> active assets (${me.total_effort_points} effort pts)</div>
    <div>Target consumption: <b>${(e.target_consumption || {}).band}</b> — ${esc((e.target_consumption || {}).rationale || "")}</div>
    ${e.savings ? `<div class="muted small">${esc(e.savings.framing)}</div>` : ""}
    <div class="muted small">${esc(e.note || "")}</div></div>`;
}

// ------------------------------------------------------------ model -------
async function loadModel() {
  const grid = $("#model-grid");
  grid.innerHTML = `<div class="loading">Loading models…</div>`;
  const data = await api("/api/models");
  state.models = data.models || [];
  state.chosenModels = new Set((state.config.industry_models || "")
    .split(",").map(s => s.trim()).filter(Boolean));
  renderModels();
}
function renderModels() {
  const grid = $("#model-grid");
  const s = ($("#model-search").value || "").toLowerCase();
  const items = state.models.filter(m => !s || m.key.includes(s) || m.label.toLowerCase().includes(s));
  grid.innerHTML = items.map(m => {
    const on = state.chosenModels.has(m.key);
    return `<div class="model-card ${on ? "on" : ""}" data-key="${m.key}">
      <div class="mc-check">${on ? "✓" : ""}</div>
      <div><div class="mc-label">${m.label}</div>
        <div class="muted small">${m.vendored ? "vendored · maps offline" : "available · fetched on first map"}</div></div>
    </div>`;
  }).join("") || `<div class="loading">No models match.</div>`;
  $$("#model-grid .model-card").forEach(el => el.onclick = () => toggleModel(el.dataset.key));
}
async function toggleModel(key) {
  if (state.chosenModels.has(key)) state.chosenModels.delete(key);
  else state.chosenModels.add(key);
  renderModels();
  state.config = await api("/api/config", { method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify({ industry_models: [...state.chosenModels].join(",") }) });
}
async function refreshModels() {
  const btn = $("#btn-refresh-models"); btn.disabled = true; btn.textContent = "Refreshing…";
  const r = await api("/api/models/refresh", { method: "POST" });
  btn.disabled = false; btn.textContent = "↻ Refresh list from repo";
  await loadModel();
}

// ------------------------------------------------------------ plan ---------
async function loadPlan() {
  const body = $("#plan-body");
  body.innerHTML = `<div class="loading">Planning…</div>`;
  const p = await api("/api/plan");
  let html = `<p class="muted">${p.value_thesis}</p>`;
  html += `<div class="pilot">★ Recommended pilot: <b>${p.recommended_pilot.name}</b> — ${p.recommended_pilot.why}</div>`;
  p.waves.forEach(w => {
    html += `<div class="wave-title">Wave ${w.wave}: ${w.theme}</div>`;
    html += `<table><tr><th>Asset</th><th>Domain</th><th>Value</th><th>Cx</th></tr>` +
      w.items.map(i => `<tr><td>${esc(i.name)}</td><td>${i.data_domain}</td><td>${i.value.value_per_year}</td><td>${i.complexity_band}</td></tr>`).join("") +
      `</table>`;
  });
  html += `<div class="wave-title">Connector ingestion strategy</div><table><tr><th>Source</th><th>Rating</th><th>Pattern</th></tr>` +
    p.source_feasibility.map(r => `<tr><td>${r.source_system}</td><td class="rate ${r.rating}">${r.rating}</td><td>${r.pattern}</td></tr>`).join("") + `</table>`;
  body.innerHTML = html;
}

// ------------------------------------------------------------ build --------
async function loadBuild() {
  state.buildFilters = state.buildFilters || { search: "", type: "", triplet: "" };
  await refreshUploads();       // pull any previously-uploaded flows
  mergeBuildAll();
  renderBuildList();
}
async function refreshUploads() {
  try { state.uploads = (await api("/api/uploads")).uploads || []; }
  catch (e) { state.uploads = state.uploads || []; }
}
function mergeBuildAll() {
  // Discovered buildable assets + manually-uploaded flows (uploads first).
  const discovered = (state.assets || []).filter(a => a.build);
  state.buildAll = [...(state.uploads || []), ...discovered];
}
function renderBuildList() {
  const list = $("#build-list");
  const all = state.buildAll || [];
  if (!all.length) { list.innerHTML = `<div class="loading">Run a Discovery Scan first.</div>`; return; }
  const f = state.buildFilters, s = f.search.toLowerCase();
  let items = all;
  if (f.type) items = items.filter(a => a.asset_type === f.type);
  if (f.triplet === "yes") items = items.filter(a => a.has_triplet);
  if (f.triplet === "no") items = items.filter(a => !a.has_triplet);
  if (s) items = items.filter(a => (a.name || "").toLowerCase().includes(s));

  const magic = all.filter(a => a.asset_type === "magic_etl").length;
  const sql = all.filter(a => a.asset_type === "sql_dataflow").length;
  const cards = items.map(a => {
    const upTag = a.uploaded ? `<span class="chip up-chip" title="Manually uploaded">⬆ uploaded</span>` : "";
    const sub = a.uploaded
      ? (a.schema_inferred ? "uploaded · schema inferred from DAG" : "uploaded · schema provided")
      : (a.has_triplet ? "full lineage available" : "metadata only — needs export");
    return `<div class="asset-card mini ${a.has_triplet ? "" : "disabled"}" data-lid="${a.triplet_lineage_id || ""}">
      <div class="ac-head"><span class="atype at-${a.asset_type}">${typeLabel(a.asset_type)}</span>
        <span class="ac-name">${esc(a.name)}</span>${upTag}</div>
      <div class="muted small">${sub}</div>
    </div>`; }).join("") || `<div class="loading">No assets match.</div>`;

  list.innerHTML = `
    <div class="build-toolbar">
      <input id="build-search" type="text" class="search" placeholder="Search ${all.length} assets…" value="${esc(f.search)}" />
      <div class="build-filters">
        <button class="tfilter ${f.type === "" ? "active" : ""}" data-bt="">All ${all.length}</button>
        <button class="tfilter ${f.type === "magic_etl" ? "active" : ""}" data-bt="magic_etl">Magic ETL ${magic}</button>
        <button class="tfilter ${f.type === "sql_dataflow" ? "active" : ""}" data-bt="sql_dataflow">SQL ${sql}</button>
        <button class="tfilter ${f.triplet === "yes" ? "active" : ""}" data-btrip="yes">Ready</button>
      </div>
      <div class="muted small build-count">${items.length} shown</div>
    </div>
    <div id="build-items" class="asset-list compact">${cards}</div>`;

  $("#build-search").oninput = e => { state.buildFilters.search = e.target.value; renderBuildList(); };
  $$("#build-list [data-bt]").forEach(b => b.onclick = () => {
    state.buildFilters.type = b.dataset.bt; renderBuildList(); });
  const rb = $('#build-list [data-btrip]');
  if (rb) rb.onclick = () => { state.buildFilters.triplet = f.triplet === "yes" ? "" : "yes"; renderBuildList(); };
  $$("#build-items .asset-card").forEach(el => el.onclick = () => {
    const lid = el.dataset.lid;
    if (!lid) { alert("Metadata-only object: full Magic ETL export (private API) needed to build."); return; }
    $$("#build-items .asset-card").forEach(x => x.classList.remove("active"));
    el.classList.add("active");
    openBuild(state.buildAll.find(m => m.triplet_lineage_id === lid));
  });
}
function openBuild(a) {
  state.buildAsset = a; state.draft = null;
  state.map = null; state.mapTable = null; state.mapOverrides = {}; state.mapIndustry = null;
  $("#build-empty").classList.add("hidden");
  $("#build-detail").classList.remove("hidden");
  $("#bd-title").textContent = a.name;
  $("#bd-sub").textContent = `${a.database_type} · ${a.action_count} actions`;
  $("#bd-badges").innerHTML = `<span class="chip gov-${a.governance}">${a.governance}</span>`;
  buildStage("analyze");
}
function buildStage(stage) {
  $$("#build-detail .stage").forEach(s => s.classList.add("hidden"));
  $(`#stage-${stage}`).classList.remove("hidden");
  $$("#build-detail .step").forEach(s => s.classList.toggle("active", s.dataset.stage === stage));
  if (stage === "analyze") loadAnalyze();
  if (stage === "map") loadMap();
  if (stage === "draft" && !state.draft) loadDraft();
  if (stage === "create") prefillCreate();
}

async function loadAnalyze() {
  const wrap = $("#graph-wrap");
  wrap.innerHTML = `<div class="loading">Analyzing…</div>`;
  const g = await api(`/api/analyze/${state.buildAsset.triplet_lineage_id}`);
  if (g.error) { wrap.innerHTML = `<div class="loading">${g.error}</div>`; return; }
  wrap.innerHTML = ""; wrap.appendChild(renderGraph(g));
  $("#analyze-meta").innerHTML =
    `<div><b>${g.meta.inputs.length}</b> sources</div><div><b>${g.nodes.length}</b> steps</div>
     <div><b>${g.meta.gold_columns.length}</b> gold cols</div><div><b>${g.meta.beast_modes.length}</b> Beast Modes</div>`;
}
function renderGraph(g) {
  const lanes = ["bronze", "silver", "gold"];
  const laneColor = { bronze: "#b87333", silver: "#9aa7b4", gold: "#e3b23c" };
  const LANE_W = 250, NODE_W = 200, NODE_H = 52, GAP_Y = 20, TOP = 46, PAD = 20;
  const byLane = { bronze: [], silver: [], gold: [] };
  g.nodes.forEach(n => (byLane[n.layer] || byLane.silver).push(n));
  const rows = Math.max(...lanes.map(l => byLane[l].length), 1);
  const width = PAD * 2 + LANE_W * lanes.length, height = TOP + rows * (NODE_H + GAP_Y) + PAD;
  const pos = {};
  lanes.forEach((lane, li) => byLane[lane].forEach((n, ri) => {
    pos[n.id] = { x: PAD + li * LANE_W + (LANE_W - NODE_W) / 2, y: TOP + ri * (NODE_H + GAP_Y) }; }));
  const ns = "http://www.w3.org/2000/svg";
  const svg = document.createElementNS(ns, "svg");
  svg.setAttribute("width", width); svg.setAttribute("height", height);
  const mk = (t, a, txt) => { const e = document.createElementNS(ns, t);
    for (const k in a) e.setAttribute(k, a[k]); if (txt != null) e.textContent = txt; return e; };
  lanes.forEach((lane, li) => {
    const x = PAD + li * LANE_W;
    svg.appendChild(mk("text", { x: x + LANE_W / 2, y: 26, "text-anchor": "middle", class: "lane-label", fill: laneColor[lane] }, lane.toUpperCase()));
    if (li > 0) svg.appendChild(mk("line", { x1: x, y1: 36, x2: x, y2: height - 8, stroke: "#1c2330", "stroke-width": 1 }));
  });
  g.edges.forEach(e => { const a = pos[e.from], b = pos[e.to]; if (!a || !b) return;
    const x1 = a.x + NODE_W, y1 = a.y + NODE_H / 2, x2 = b.x, y2 = b.y + NODE_H / 2, mx = (x1 + x2) / 2;
    svg.appendChild(mk("path", { d: `M ${x1} ${y1} C ${mx} ${y1}, ${mx} ${y2}, ${x2} ${y2}`, class: "edge" })); });
  g.nodes.forEach(n => { const p = pos[n.id]; if (!p) return; const col = laneColor[n.layer] || "#9aa7b4";
    const grp = mk("g", {});
    grp.appendChild(mk("rect", { x: p.x, y: p.y, width: NODE_W, height: NODE_H, rx: 8, fill: "#141b24", stroke: n.review ? "#f85149" : col, "stroke-width": 1.6 }));
    grp.appendChild(mk("rect", { x: p.x, y: p.y, width: 4, height: NODE_H, rx: 2, fill: col }));
    grp.appendChild(mk("text", { x: p.x + 14, y: p.y + 21, class: "node-title" }, n.label));
    grp.appendChild(mk("text", { x: p.x + 14, y: p.y + 38, class: "node-detail" }, trunc(n.detail || n.name || "", 30)));
    svg.appendChild(grp); });
  return svg;
}
const trunc = (s, n) => (s.length > n ? s.slice(0, n - 1) + "…" : s);

// ------------------------------------------------------------ map ---------
async function loadMap(reload) {
  const wrap = $("#map-table-wrap");
  if (!reload) wrap.innerHTML = `<div class="loading">Mapping to the industry model…</div>`;
  // industry options come from the configured selection (fallback: all)
  if (!state.mapIndustry) {
    const chosen = (state.config.industry_models || "").split(",").map(s => s.trim()).filter(Boolean);
    state.mapIndustry = chosen[0] || "automotive";
  }
  const url = `/api/map/lineage/${state.buildAsset.triplet_lineage_id}?industry=${state.mapIndustry}`
    + (state.mapTable ? `&force_table=${encodeURIComponent(state.mapTable)}` : "");
  const m = await api(url);
  state.map = m;
  if (m.error) { wrap.innerHTML = `<div class="loading">${esc(m.error)}</div>`; return; }
  state.mapTable = m.target_table;
  state.mapOverrides = state.mapOverrides || {};
  renderMapControls(m);
  renderMapGrid(m);
}
function renderMapControls(m) {
  // industry dropdown (configured models, else this model)
  const chosen = (state.config.industry_models || "").split(",").map(s => s.trim()).filter(Boolean);
  const inds = chosen.length ? chosen : [m.industry];
  $("#map-industry").innerHTML = inds.map(i =>
    `<option value="${i}" ${i === m.industry ? "selected" : ""}>${i}</option>`).join("");
  // table dropdown grouped-ish by domain, current selected
  $("#map-table").innerHTML = (m.model_tables || []).map(t =>
    `<option value="${t.fqn}" ${t.fqn === m.target_table ? "selected" : ""}>${t.domain} · ${t.table} (${t.columns})</option>`).join("");
  const mapped = m.mapped_count, total = m.columns.length;
  const pct = total ? Math.round(mapped / total * 100) : 0;
  $("#map-cov").innerHTML = `<div class="cov-num">${mapped}/${total}</div>
    <div class="cov-lbl">columns mapped</div>
    <div class="cov-bar"><span style="width:${pct}%"></span></div>`;
}
function renderMapGrid(m) {
  const cols = m.table_columns.map(c => c.name);
  const rows = m.columns.map(c => {
    const opts = ['<option value="">— unmapped —</option>'].concat(
      cols.map(name => {
        const cand = c.candidates.find(x => x.name === name);
        const pct = cand ? Math.round(cand.confidence * 100) : null;
        const sel = c.target_column === name ? "selected" : "";
        return `<option value="${name}" ${sel}>${name}${pct != null ? ` · ${pct}%` : ""}</option>`;
      })).join("");
    const conf = Math.round((c.confidence || 0) * 100);
    const band = c.source === "override" ? "ov" : c.target_column ? (c.confidence >= 0.55 ? "hi" : "lo") : "no";
    const badge = c.source === "override" ? "✎ manual"
      : c.target_column ? (c.needs_review ? "review" : "suggested") : "unmapped";
    return `<tr class="maprow ${band}">
      <td class="mc-domo"><span class="mc-name">${esc(c.domo_column)}</span>
        <span class="mc-type">${c.domo_type}</span></td>
      <td class="mc-arrow">→</td>
      <td class="mc-target">
        <select data-col="${esc(c.domo_column)}" class="map-sel">${opts}</select>
      </td>
      <td class="mc-conf"><div class="confbar ${band}"><span style="width:${conf}%"></span></div>
        <span class="conf-badge ${band}">${badge}</span></td>
    </tr>`;
  }).join("");
  $("#map-grid").innerHTML =
    `<thead><tr><th>Domo column</th><th></th><th>${esc(m.target_table)}</th><th>confidence</th></tr></thead>
     <tbody>${rows}</tbody>`;
  $$("#map-grid .map-sel").forEach(sel => sel.onchange = () => {
    state.mapOverrides[sel.dataset.col] = sel.value;
    applyOverrides();
  });
}
async function applyOverrides() {
  const m = await api(`/api/map/lineage/${state.buildAsset.triplet_lineage_id}`, {
    method: "POST", headers: { "Content-Type": "application/json" },
    body: JSON.stringify({ industry: state.mapIndustry, force_table: state.mapTable,
      overrides: state.mapOverrides, accept: false }) });
  state.map = m; renderMapControls(m); renderMapGrid(m);
}
async function saveMap() {
  const btn = $("#btn-save-map"); btn.disabled = true; btn.textContent = "Saving…";
  await api(`/api/map/lineage/${state.buildAsset.triplet_lineage_id}`, {
    method: "POST", headers: { "Content-Type": "application/json" },
    body: JSON.stringify({ industry: state.mapIndustry, force_table: state.mapTable,
      overrides: state.mapOverrides, accept: true }) });
  btn.disabled = false; btn.textContent = "✓ Saved";
  setTimeout(() => { btn.textContent = "Save mapping"; }, 1500);
}

async function loadDraft() {
  $("#draft-gate").innerHTML = `<div class="loading">Transpiling…</div>`; $("#sql-view").textContent = "";
  state.draftLang = state.draftLang || (state.config && state.config.pipeline_language) || "sql";
  const d = await api(`/api/draft/${state.buildAsset.triplet_lineage_id}?language=${state.draftLang}`);
  state.draft = d; const g = d.reconciliation.gate, bm = d.counts;
  $("#draft-gate").className = `gate ${g}`;
  const gateLabel = g === "PASS" ? "PASS" : (g === "NEEDS_REVIEW" ? "NEEDS REVIEW (SQL DataFlow)" : g);
  const conformed = d.sdp && d.sdp.conformed
    ? `<li>✓ conformed view appended — gold projected to your saved industry-model mapping</li>` : "";
  $("#draft-gate").innerHTML = `<span ${tip("gate")}>Reconcile gate: ${gateLabel}</span><ul>
    <li>${bm.gold_columns} gold columns — schema parity with the Domo DataSet</li>
    <li>${bm.beast_modes_translated}/${bm.beast_modes_total} Beast Modes → <b>metric view</b> (governed semantic layer)</li>
    <li>${bm.ir_nodes} transform steps from ${bm.input_datasets} sources</li>${conformed}</ul>`;
  renderDraftTabs();
}
function renderDraftTabs() {
  const d = state.draft;
  const tabs = $("#sql-tabs"); tabs.innerHTML = "";
  // Language toggle for the SDP output.
  const langWrap = document.createElement("div");
  langWrap.className = "lang-toggle";
  langWrap.innerHTML = `<span class="muted small">Pipeline language:</span>
    <button class="langbtn ${state.draftLang === "sql" ? "active" : ""}" data-lang="sql">SDP SQL</button>
    <button class="langbtn ${state.draftLang === "python" ? "active" : ""}" data-lang="python">SDP Python</button>`;
  tabs.appendChild(langWrap);
  $$(".langbtn", langWrap).forEach(b => b.onclick = () => { state.draftLang = b.dataset.lang; loadDraft(); });

  // Views: the real SDP output first, then the raw medallion for reference.
  state.sqlViews = {};
  if (d.sdp) state.sqlViews[`SDP (${d.sdp.language})`] = d.sdp.code;
  const labels = { bronze: "Bronze (raw)", silver: "Silver (raw)", gold: "Gold contract (raw)" };
  for (const k of ["bronze", "silver", "gold"]) if (d.sql[k]) state.sqlViews[labels[k]] = d.sql[k];
  const keys = Object.keys(state.sqlViews);
  state.activeSql = keys[0];
  keys.forEach(k => { const t = document.createElement("div");
    t.className = "tab" + (k === state.activeSql ? " active" : ""); t.textContent = k;
    t.dataset.k = k; t.onclick = () => { state.activeSql = k; showSql(); }; tabs.appendChild(t); });
  showSql();
}
function showSql() {
  $("#sql-view").textContent = state.sqlViews[state.activeSql] || "";
  $$("#sql-tabs .tab").forEach(t => t.classList.toggle("active", t.dataset.k === state.activeSql));
}

function prefillCreate() {
  const c = state.config || {};
  $("#c-catalog").value = c.catalog || ""; $("#c-schema").value = c.schema || "";
  $("#c-profile").value = c.databricks_profile || "";
  $("#c-language").value = state.draftLang || c.pipeline_language || "sql";
  // repo option only if a git provider is configured
  if (c.git_provider) {
    $("#repo-wrap").classList.remove("hidden");
    $("#c-repo").innerHTML = `<option value="">— no —</option><option value="${c.git_repo}">${c.git_provider}: ${c.git_repo}</option>`;
  } else $("#repo-wrap").classList.add("hidden");
  $("#create-hint").innerHTML = c.deploy_ready
    ? `Profile <b>${c.databricks_profile}</b> set — Create writes the bundle <em>and</em> deploys.`
    : `No Databricks profile — Create writes a deployable bundle locally + shows the deploy command.`;
  $("#create-result").classList.add("hidden");
}
async function doCreate() {
  const btn = $("#btn-create"); btn.disabled = true; btn.textContent = "Creating…";
  const body = { catalog: $("#c-catalog").value, schema: $("#c-schema").value,
    profile: $("#c-profile").value, language: $("#c-language").value,
    repo: $("#c-repo") ? $("#c-repo").value : "" };
  const r = await api(`/api/create/${state.buildAsset.triplet_lineage_id}`,
    { method: "POST", headers: { "Content-Type": "application/json" }, body: JSON.stringify(body) });
  btn.disabled = false; btn.textContent = "⚡ Create pipeline";
  const box = $("#create-result"); box.classList.remove("hidden");
  if (r.error) { box.className = "create-result"; box.innerHTML = `<b>${esc(r.error)}</b>`; return; }
  const b = r.bundle;
  box.className = "create-result ok";
  box.innerHTML = `<div style="font-weight:650">${b.deployed ? "✅ Pipeline deployed" : "📦 Bundle written"}: <code>${b.pipeline_name}</code></div>
    <div class="muted small">target: ${b.catalog}.${b.schema}</div>
    ${b.sql_files.map(f => `<div class="muted small">• ${f}</div>`).join("")}
    <div class="muted small" style="margin-top:8px">deploy:</div><pre class="code" style="max-height:70px">${esc(b.deploy_command)}\n${esc(b.run_command)}</pre>
    ${b.git ? `<div class="muted small" style="margin-top:8px">${esc(b.git.message)}</div>` : ""}
    ${b.deploy_log ? `<div class="muted small">${esc(b.deploy_log)}</div>` : ""}`;
}

// ------------------------------------------------------------ upload modal -
function openUpload() {
  $("#up-flow").value = ""; $("#up-schema").value = ""; $("#up-card").value = "";
  $("#up-status").className = "up-status"; $("#up-status").innerHTML = "";
  $("#up-submit").disabled = false; $("#up-submit").textContent = "Add to Build list";
  $("#upload-modal").classList.remove("hidden");
}
async function submitUpload() {
  const flow = $("#up-flow").files[0];
  const st = $("#up-status");
  if (!flow) { st.className = "up-status err"; st.textContent = "Choose a Magic ETL DataFlow JSON first."; return; }
  const fd = new FormData();
  fd.append("file", flow);
  if ($("#up-schema").files[0]) fd.append("schema_file", $("#up-schema").files[0]);
  if ($("#up-card").files[0]) fd.append("card_file", $("#up-card").files[0]);
  const btn = $("#up-submit"); btn.disabled = true; btn.textContent = "Uploading…";
  st.className = "up-status working"; st.textContent = "Parsing & inferring…";
  let r;
  try { r = await (await fetch("/api/upload", { method: "POST", body: fd })).json(); }
  catch (e) { st.className = "up-status err"; st.textContent = "Upload failed: " + e; btn.disabled = false; btn.textContent = "Add to Build list"; return; }
  if (r.error) {
    st.className = "up-status err";
    st.innerHTML = esc(r.error) + (r.needs_schema
      ? `<div class="muted small" style="margin-top:6px">The output columns pass through from a raw source, so they can't be inferred. Add the <b>output DataSet schema JSON</b> above and try again.</div>` : "");
    btn.disabled = false; btn.textContent = "Add to Build list";
    return;
  }
  // success — merge into the build list, select it, close.
  await refreshUploads(); mergeBuildAll(); renderBuildList();
  st.className = "up-status ok";
  st.innerHTML = `Added <b>${esc(r.name)}</b> — ${r.columns} output columns` +
    (r.schema_inferred ? " (inferred)" : "") + ". Opening…";
  setTimeout(() => {
    $("#upload-modal").classList.add("hidden");
    const asset = state.buildAll.find(a => a.triplet_lineage_id === r.triplet_lineage_id);
    if (asset) {
      const el = $(`#build-items .asset-card[data-lid="${r.triplet_lineage_id}"]`);
      if (el) { $$("#build-items .asset-card").forEach(x => x.classList.remove("active")); el.classList.add("active"); }
      openBuild(asset);
    }
  }, 700);
}

// ------------------------------------------------------------ config modal -
async function refreshPills() {
  $("#provider-pill").textContent = `provider: ${state.config.domo_provider}`;
  $("#deploy-pill").textContent = state.config.deploy_ready ? `deploy: ${state.config.databricks_profile}` : "deploy: files only";
  $("#ai-pill").classList.toggle("hidden", !state.config.llm_enabled);
}
async function openConfig() {
  const c = state.config;
  $("#cfg-catalog").value = c.catalog; $("#cfg-schema").value = c.schema; $("#cfg-profile").value = c.databricks_profile;
  $("#cfg-language").value = c.pipeline_language || "sql";
  $("#cfg-provider").value = c.domo_provider; $("#cfg-domo-id").value = c.domo_client_id;
  $("#cfg-secret").textContent = c.domo_secret_present ? "DOMO_CLIENT_SECRET present ✓" : "No DOMO_CLIENT_SECRET in env.";
  $("#cfg-store").value = c.store_backend || "local"; $("#cfg-lakebase").value = c.lakebase_instance || "";
  $("#cfg-llm").value = c.llm_endpoint || ""; $("#cfg-host").value = c.databricks_host || "";
  $("#cfg-llm-status").textContent = c.llm_enabled
    ? "AI enhancement ON ✓" : "AI enhancement off — deterministic only.";
  $("#cfg-git-provider").value = c.git_provider || ""; $("#cfg-git-repo").value = c.git_repo || "";
  $("#cfg-git-token").textContent = c.git_token_present ? "GIT_TOKEN present ✓" : "No GIT_TOKEN in env.";
  // industry-model selection lives in the wizard Model step now; just echo it.
  $("#cfg-models-current").textContent = c.industry_models || "(none selected)";
  // patterns provenance
  const pat = await api("/api/patterns");
  $("#cfg-patterns").textContent = `Source: ${pat.source}${pat.refreshed_at ? " · refreshed " + pat.refreshed_at.slice(0, 10) : " · never refreshed"}.`;
  $("#config-modal").classList.remove("hidden");
}
async function saveConfig() {
  const u = { catalog: $("#cfg-catalog").value, schema: $("#cfg-schema").value, databricks_profile: $("#cfg-profile").value,
    pipeline_language: $("#cfg-language").value,
    domo_provider: $("#cfg-provider").value, domo_client_id: $("#cfg-domo-id").value,
    store_backend: $("#cfg-store").value, lakebase_instance: $("#cfg-lakebase").value,
    llm_endpoint: $("#cfg-llm").value, databricks_host: $("#cfg-host").value,
    git_provider: $("#cfg-git-provider").value, git_repo: $("#cfg-git-repo").value };
  state.config = await api("/api/config", { method: "POST", headers: { "Content-Type": "application/json" }, body: JSON.stringify(u) });
  refreshPills(); $("#config-modal").classList.add("hidden");
}
async function refreshPatterns() {
  const btn = $("#cfg-refresh-patterns"); btn.disabled = true; btn.textContent = "Refreshing…";
  const r = await api("/api/patterns/refresh", { method: "POST" });
  btn.disabled = false; btn.textContent = "↻ Refresh patterns from ai-dev-kit";
  $("#cfg-patterns").textContent = r.message;
}

// ------------------------------------------------------------ wire up ------
const esc = s => String(s).replace(/[&<>]/g, c => ({ "&": "&amp;", "<": "&lt;", ">": "&gt;" }[c]));
document.addEventListener("click", e => {
  if (e.target.closest("[data-next]")) nextPhase();
  if (e.target.closest("[data-prev]")) prevPhase();
  const goto = e.target.closest("[data-goto]"); if (goto) buildStage(goto.dataset.goto);
  const step = e.target.closest("#build-detail .step"); if (step) buildStage(step.dataset.stage);
});
$("#btn-connect").onclick = doConnect;
$("#btn-scan").onclick = runScan;
$("#btn-create").onclick = doCreate;
$("#search").oninput = e => { state.search = e.target.value; renderAssets(); };
$("#rat-search").oninput = e => { state.ratSearch = e.target.value; renderRatTable(); };
$("#btn-estimate").onclick = showEstimate;
$("#btn-config").onclick = openConfig;
$("#btn-upload").onclick = openUpload;
$("#up-close").onclick = () => $("#upload-modal").classList.add("hidden");
$("#up-submit").onclick = submitUpload;
$("#cfg-close").onclick = () => $("#config-modal").classList.add("hidden");
$("#cfg-save").onclick = saveConfig;
$("#cfg-refresh-patterns").onclick = refreshPatterns;
$("#btn-refresh-models").onclick = refreshModels;
$("#model-search").oninput = renderModels;
$("#btn-save-map").onclick = saveMap;
$("#map-industry").onchange = e => { state.mapIndustry = e.target.value; state.mapTable = null; state.mapOverrides = {}; loadMap(); };
$("#map-table").onchange = e => { state.mapTable = e.target.value; state.mapOverrides = {}; loadMap(true); };

(async function init() {
  state.config = await api("/api/config");
  refreshPills();
  fillConfigureForm();
  renderRail();
})();
