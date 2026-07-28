"use strict";
const $ = (s, r = document) => r.querySelector(s);
const $$ = (s, r = document) => [...r.querySelectorAll(s)];
const api = async (path, opts) => (await fetch(path, opts)).json();

const PHASES = ["configure", "connect", "discover", "assess", "model", "plan", "build"];
const PHASE_LABEL = { configure: "Configure", connect: "Connect", discover: "Discover",
  assess: "Assess", model: "Model", plan: "Plan", build: "Build & Deploy" };

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
  if (p === "assess") loadAssess();
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
  // fixture mode: a discovery summary call IS the connection test.
  try {
    const sum = await api("/api/estate");
    state.connected = true;
    const prov = state.config.domo_provider;
    s.className = "connect-status ok";
    s.innerHTML = `Connected (<b>${prov}</b>). Tenant reachable — `
      + `${sum.summary.counts.dataflows} flows, ${sum.summary.counts.datasets} datasets, `
      + `${sum.summary.counts.cards} cards ready to scan.`;
    $("#btn-connect").classList.add("hidden");
    $("#btn-to-discover").classList.remove("hidden");
  } catch (e) {
    s.className = "connect-status err";
    s.textContent = "Connection failed: " + e;
  }
}

// ------------------------------------------------------------ discover -----
function onEnterDiscover() {
  if (!state.inventory) return; // wait for scan
}
async function runScan() {
  const btn = $("#btn-scan");
  btn.disabled = true; btn.textContent = "Scanning…";
  const inv = await api("/api/inventory");
  state.inventory = inv;
  state.assets = inv.assets;
  btn.disabled = false; btn.textContent = "↻ Re-scan";

  // summary tiles
  const sum = $("#scan-summary");
  sum.classList.remove("hidden");
  sum.innerHTML = inv.asset_types.map(t => {
    const n = inv.counts_by_type[t.key] || 0;
    return `<button class="tile" data-type="${t.key}" title="${t.hint}">
      <div class="tile-n">${n}</div><div class="tile-l">${t.label}</div>
      ${t.migratable ? '<div class="tile-tag">migratable</div>' : ''}</button>`;
  }).join("");
  $$("#scan-summary .tile").forEach(b => b.onclick = () => setFilter(b.dataset.type));

  // type filter chips
  const tf = $("#type-filters");
  tf.innerHTML = `<button class="tfilter active" data-type="">All</button>` +
    inv.asset_types.map(t => `<button class="tfilter" data-type="${t.key}">${t.label}</button>`).join("");
  $$("#type-filters .tfilter").forEach(b => b.onclick = () => setFilter(b.dataset.type));

  $("#discover-body").classList.remove("hidden");
  $("#btn-to-assess").disabled = false;
  renderAssets();
}
function setFilter(type) {
  state.filterType = type;
  $$("#type-filters .tfilter").forEach(b => b.classList.toggle("active", b.dataset.type === type));
  renderAssets();
}
function renderAssets() {
  const list = $("#asset-list");
  const s = state.search.toLowerCase();
  let items = state.assets;
  if (state.filterType) items = items.filter(a => a.asset_type === state.filterType);
  if (s) items = items.filter(a => (a.name || "").toLowerCase().includes(s));
  list.innerHTML = items.map(assetCard).join("") || `<div class="loading">No matching assets.</div>`;
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
  const sig = (a.governance_signals || []).length
    ? `<details class="why"><summary>why ${a.governance}?</summary><ul>${a.governance_signals.map(x => `<li>${esc(x)}</li>`).join("")}</ul></details>` : "";
  const path = a.migration_path_label
    ? `<div class="mpath ${a.build ? "buildable" : ""}">↳ ${esc(a.migration_path_label)}</div>` : "";
  return `<div class="asset-card">
    <div class="ac-head"><span class="atype at-${a.asset_type}" ${tip(a.asset_type)}>${typeLabel(a.asset_type)}</span>
      <span class="ac-name">${esc(a.name || a.id)}</span>${gov}</div>
    ${extra}${path}${sig}</div>`;
}
const TYPE_LABEL = { connector: "Connector", magic_etl: "Magic ETL", sql_dataflow: "SQL DataFlow",
  dataset: "DataSet", card: "Card", beast_mode: "Beast Mode", page: "Page" };
const typeLabel = t => TYPE_LABEL[t] || t;

// ------------------------------------------------------------ assess -------
async function loadAssess() {
  const body = $("#assess-body");
  body.innerHTML = `<div class="loading">Assessing…</div>`;
  const data = await api("/api/estate");
  const rows = data.dataflows.map(a => {
    const sig = (a.governance_signals || []).map(x => `<li>${esc(x)}</li>`).join("");
    return `<tr>
      <td>${esc(a.name)}</td>
      <td><span class="chip ${a.database_type === "SQL" ? "sql" : "magic"}" ${tip(a.database_type === "SQL" ? "sql_dataflow" : "magic_etl")}>${a.database_type}</span></td>
      <td>${a.data_domain}</td>
      <td><span class="chip gov-${a.governance}">${a.governance} ${Math.round(a.governance_confidence * 100)}%</span></td>
      <td><span class="chip v-${a.value.band}">${a.value.value_per_year}</span></td>
      <td><span class="chip cx-${a.complexity.band}" ${tip("complexity", "tip-left")}>${a.complexity.score}</span></td>
    </tr>
    <tr class="sigrow"><td colspan="6"><details><summary>why this governance call?</summary>
      ${a.governance_rationale ? `<p class="ai-note">✨ ${esc(a.governance_rationale)}</p>` : ""}
      <ul>${sig}</ul></details></td></tr>`;
  }).join("");
  body.innerHTML = `<table class="assess-table">
    <tr><th>Asset</th><th ${tip("type")}>Type</th><th ${tip("domain")}>Domain</th>
      <th ${tip("governance")}>Governance (inferred)</th><th ${tip("value")}>Value</th>
      <th ${tip("complexity", "tip-left")}>Complexity</th></tr>
    ${rows}</table>
    <p class="muted small">Governance is inferred — expand a row to see the signals. Confirm or override before you rely on it.</p>`;
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
function loadBuild() {
  const list = $("#build-list");
  const migratable = (state.assets || []).filter(a => a.build);
  if (!migratable.length) { list.innerHTML = `<div class="loading">Run a Discovery Scan first.</div>`; return; }
  list.innerHTML = migratable.map(a =>
    `<div class="asset-card mini ${a.has_triplet ? "" : "disabled"}" data-lid="${a.triplet_lineage_id || ""}">
      <div class="ac-head"><span class="atype at-${a.asset_type}">${typeLabel(a.asset_type)}</span>
        <span class="ac-name">${esc(a.name)}</span></div>
      <div class="muted small">${a.has_triplet ? "full lineage available" : "metadata only — needs export"}</div>
    </div>`).join("");
  $$("#build-list .asset-card").forEach(el => el.onclick = () => {
    const lid = el.dataset.lid;
    if (!lid) { alert("Metadata-only object: full Magic ETL export (private API) needed to build."); return; }
    $$("#build-list .asset-card").forEach(x => x.classList.remove("active"));
    el.classList.add("active");
    openBuild(migratable.find(m => m.triplet_lineage_id === lid));
  });
}
function openBuild(a) {
  state.buildAsset = a; state.draft = null;
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

async function loadDraft() {
  $("#draft-gate").innerHTML = `<div class="loading">Transpiling…</div>`; $("#sql-view").textContent = "";
  state.draftLang = state.draftLang || (state.config && state.config.pipeline_language) || "sql";
  const d = await api(`/api/draft/${state.buildAsset.triplet_lineage_id}?language=${state.draftLang}`);
  state.draft = d; const g = d.reconciliation.gate, bm = d.counts;
  $("#draft-gate").className = `gate ${g}`;
  const gateLabel = g === "PASS" ? "PASS" : (g === "NEEDS_REVIEW" ? "NEEDS REVIEW (SQL DataFlow)" : g);
  $("#draft-gate").innerHTML = `<span ${tip("gate")}>Reconcile gate: ${gateLabel}</span><ul>
    <li>${bm.gold_columns} gold columns — schema parity with the Domo DataSet</li>
    <li>${bm.beast_modes_translated}/${bm.beast_modes_total} Beast Modes → <b>metric view</b> (governed semantic layer)</li>
    <li>${bm.ir_nodes} transform steps from ${bm.input_datasets} sources</li></ul>`;
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
$("#btn-config").onclick = openConfig;
$("#cfg-close").onclick = () => $("#config-modal").classList.add("hidden");
$("#cfg-save").onclick = saveConfig;
$("#cfg-refresh-patterns").onclick = refreshPatterns;
$("#btn-refresh-models").onclick = refreshModels;
$("#model-search").oninput = renderModels;

(async function init() {
  state.config = await api("/api/config");
  refreshPills();
  fillConfigureForm();
  renderRail();
})();
