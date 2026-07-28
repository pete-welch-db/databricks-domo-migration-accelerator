"use strict";
const $ = (s, r = document) => r.querySelector(s);
const $$ = (s, r = document) => [...r.querySelectorAll(s)];
const api = async (path, opts) => (await fetch(path, opts)).json();

const state = { lineageId: null, draft: null, config: null, activeSql: "bronze" };

// ---------------------------------------------------------------- estate ----
async function loadEstate() {
  const data = await api("/api/estate");
  const c = data.summary.counts;
  $("#estate-counts").textContent =
    `${c.dataflows} flows · ${c.cards} cards · ${c.datasets} datasets`;
  const list = $("#estate-list");
  list.innerHTML = "";

  // group by governance so the 40/60 split is legible
  const governed = data.dataflows.filter(d => d.governance === "governed");
  const shadow = data.dataflows.filter(d => d.governance !== "governed");
  const groups = [["Governed IT", governed], ["Shadow IT / citizen-dev", shadow]];
  for (const [label, items] of groups) {
    if (!items.length) continue;
    const g = document.createElement("div");
    g.className = "est-group-label";
    g.textContent = label;
    list.appendChild(g);
    for (const df of items) list.appendChild(estItem(df));
  }
}

function estItem(df) {
  const el = document.createElement("div");
  el.className = "est-item";
  el.dataset.id = df.triplet_lineage_id || "";
  const dbt = df.database_type === "SQL" ? "sql" : "magic";
  const val = df.value.band, cx = df.complexity.band;
  el.innerHTML = `
    <div class="name">${df.name}</div>
    <div class="row">
      <span class="chip ${dbt}">${df.database_type}</span>
      <span class="chip ${df.governance === "governed" ? "gov" : "shadow"}">${df.governance}</span>
      <span class="chip">${df.data_domain}</span>
      <span class="chip v-${val}">${df.value.value_per_year} · ${val}</span>
      <span class="chip cx-${cx}">cx ${df.complexity.score}</span>
    </div>`;
  el.onclick = () => {
    if (!df.triplet_lineage_id) {
      alert("Discovery-only object: Magic ETL internals need the Domo export/" +
            "private API. Public API exposes DataSet + card metadata only.");
      return;
    }
    $$(".est-item").forEach(x => x.classList.remove("active"));
    el.classList.add("active");
    openDetail(df);
  };
  return el;
}

// ---------------------------------------------------------------- detail ----
async function openDetail(df) {
  state.lineageId = df.triplet_lineage_id;
  state.draft = null;
  $("#empty-state").classList.add("hidden");
  $("#detail").classList.remove("hidden");
  $("#detail-title").textContent = df.name;
  $("#detail-sub").textContent =
    `${df.data_domain} · ${df.source_systems.join(", ") || "—"} · owner-managed`;
  $("#detail-badges").innerHTML =
    `<span class="chip ${df.database_type === "SQL" ? "sql" : "magic"}">${df.database_type}</span>
     <span class="chip v-${df.value.band}">${df.value.driver} · ${df.value.value_per_year}</span>
     <span class="chip cx-${df.complexity.band}">complexity ${df.complexity.score}</span>`;
  gotoStage("analyze");
  loadAnalyze();
}

function gotoStage(stage) {
  $$(".stage").forEach(s => s.classList.add("hidden"));
  $(`#stage-${stage}`).classList.remove("hidden");
  $$(".step").forEach(s => {
    s.classList.toggle("active", s.dataset.stage === stage);
  });
  if (stage === "draft" && !state.draft) loadDraft();
  if (stage === "create") prefillCreate();
}

// ---------------------------------------------------------------- analyze ---
async function loadAnalyze() {
  const wrap = $("#graph-wrap");
  wrap.innerHTML = `<div class="loading">Analyzing data flow…</div>`;
  const g = await api(`/api/analyze/${state.lineageId}`);
  if (g.error) { wrap.innerHTML = `<div class="loading">${g.error}</div>`; return; }
  wrap.innerHTML = "";
  wrap.appendChild(renderGraph(g));
  $("#analyze-meta").innerHTML =
    `<div><b>${g.meta.inputs.length}</b> source datasets</div>
     <div><b>${g.nodes.length}</b> transform steps</div>
     <div><b>${g.meta.gold_columns.length}</b> gold columns</div>
     <div><b>${g.meta.beast_modes.length}</b> Beast Modes → semantic layer</div>`;
}

// SVG DAG in medallion lanes (bronze | silver | gold), left to right.
function renderGraph(g) {
  const lanes = ["bronze", "silver", "gold"];
  const laneColor = { bronze: "#b87333", silver: "#9aa7b4", gold: "#e3b23c" };
  const LANE_W = 250, NODE_W = 200, NODE_H = 52, GAP_Y = 20, TOP = 46, PAD = 20;

  // bucket nodes by lane, preserving order
  const byLane = { bronze: [], silver: [], gold: [] };
  g.nodes.forEach(n => (byLane[n.layer] || byLane.silver).push(n));
  const rows = Math.max(...lanes.map(l => byLane[l].length), 1);
  const width = PAD * 2 + LANE_W * lanes.length;
  const height = TOP + rows * (NODE_H + GAP_Y) + PAD;

  const pos = {}; // node id -> {x,y}
  lanes.forEach((lane, li) => {
    byLane[lane].forEach((n, ri) => {
      pos[n.id] = {
        x: PAD + li * LANE_W + (LANE_W - NODE_W) / 2,
        y: TOP + ri * (NODE_H + GAP_Y),
      };
    });
  });

  const svgNS = "http://www.w3.org/2000/svg";
  const svg = document.createElementNS(svgNS, "svg");
  svg.setAttribute("width", width);
  svg.setAttribute("height", height);
  const mk = (tag, attrs, txt) => {
    const e = document.createElementNS(svgNS, tag);
    for (const k in attrs) e.setAttribute(k, attrs[k]);
    if (txt != null) e.textContent = txt;
    return e;
  };

  // lane labels + separators
  lanes.forEach((lane, li) => {
    const x = PAD + li * LANE_W;
    svg.appendChild(mk("text", { x: x + LANE_W / 2, y: 26, "text-anchor": "middle",
      class: "lane-label", fill: laneColor[lane] }, lane.toUpperCase()));
    if (li > 0) svg.appendChild(mk("line",
      { x1: x, y1: 36, x2: x, y2: height - 8, stroke: "#1c2330", "stroke-width": 1 }));
  });

  // edges (draw first, behind nodes)
  g.edges.forEach(e => {
    const a = pos[e.from], b = pos[e.to];
    if (!a || !b) return;
    const x1 = a.x + NODE_W, y1 = a.y + NODE_H / 2;
    const x2 = b.x, y2 = b.y + NODE_H / 2;
    const mx = (x1 + x2) / 2;
    svg.appendChild(mk("path",
      { d: `M ${x1} ${y1} C ${mx} ${y1}, ${mx} ${y2}, ${x2} ${y2}`, class: "edge" }));
  });

  // nodes
  g.nodes.forEach(n => {
    const p = pos[n.id]; if (!p) return;
    const col = laneColor[n.layer] || "#9aa7b4";
    const grp = mk("g", {});
    grp.appendChild(mk("rect", { x: p.x, y: p.y, width: NODE_W, height: NODE_H,
      rx: 8, fill: "#141b24", stroke: n.review ? "#f85149" : col, "stroke-width": 1.6 }));
    grp.appendChild(mk("rect", { x: p.x, y: p.y, width: 4, height: NODE_H,
      rx: 2, fill: col }));
    grp.appendChild(mk("text", { x: p.x + 14, y: p.y + 21, class: "node-title" },
      `${n.label}${n.name && n.label !== n.name ? "" : ""}`));
    grp.appendChild(mk("text", { x: p.x + 14, y: p.y + 38, class: "node-detail" },
      truncate(n.detail || n.name || "", 30)));
    svg.appendChild(grp);
  });
  return svg;
}
const truncate = (s, n) => (s.length > n ? s.slice(0, n - 1) + "…" : s);

// ---------------------------------------------------------------- draft -----
async function loadDraft() {
  $("#draft-gate").innerHTML = `<div class="loading">Transpiling…</div>`;
  $("#sql-view").textContent = "";
  const d = await api(`/api/draft/${state.lineageId}`);
  state.draft = d;
  const gate = d.reconciliation.gate;
  const bm = d.counts;
  $("#draft-gate").className = `gate ${gate}`;
  $("#draft-gate").innerHTML =
    `Reconcile gate: ${gate}
     <ul>
       <li>${bm.gold_columns} gold columns — schema parity with the Domo DataSet</li>
       <li>${bm.beast_modes_translated}/${bm.beast_modes_total} Beast Modes folded into the semantic layer</li>
       <li>${bm.ir_nodes} transform steps from ${bm.input_datasets} sources</li>
     </ul>`;
  // sql tabs
  const tabs = $("#sql-tabs"); tabs.innerHTML = "";
  const order = ["bronze", "silver", "gold", "gold_semantic_metrics"];
  const labels = { bronze: "Bronze", silver: "Silver", gold: "Gold (contract)",
    gold_semantic_metrics: "Semantic (Beast Modes)" };
  state.activeSql = "gold";
  order.forEach(k => {
    if (!d.sql[k]) return;
    const t = document.createElement("div");
    t.className = "tab" + (k === state.activeSql ? " active" : "");
    t.textContent = labels[k];
    t.onclick = () => { state.activeSql = k; showSql(); };
    tabs.appendChild(t);
  });
  showSql();
}
function showSql() {
  $("#sql-view").textContent = state.draft.sql[state.activeSql] || "";
  $$("#sql-tabs .tab").forEach(t =>
    t.classList.toggle("active",
      t.textContent.toLowerCase().startsWith(state.activeSql.split("_")[0])));
}

// ---------------------------------------------------------------- create ----
function prefillCreate() {
  const c = state.config || {};
  $("#c-catalog").value = c.catalog || "";
  $("#c-schema").value = c.schema || "";
  $("#c-profile").value = c.databricks_profile || "";
  $("#create-hint").innerHTML = c.deploy_ready
    ? `Profile <b>${c.databricks_profile}</b> configured — Create will write the bundle <em>and</em> deploy the pipeline.`
    : `No Databricks profile set — Create will write a deployable bundle locally and show you the deploy command. Set a profile in ⚙ Config to deploy for real.`;
  $("#create-result").classList.add("hidden");
}

async function doCreate() {
  const btn = $("#btn-create");
  btn.disabled = true; btn.textContent = "Creating…";
  const body = { catalog: $("#c-catalog").value, schema: $("#c-schema").value,
    profile: $("#c-profile").value };
  const r = await api(`/api/create/${state.lineageId}`,
    { method: "POST", headers: { "Content-Type": "application/json" },
      body: JSON.stringify(body) });
  btn.disabled = false; btn.textContent = "⚡ Create pipeline";
  const box = $("#create-result");
  box.classList.remove("hidden");
  if (r.error) { box.className = "create-result"; box.innerHTML = `<b>${r.error}</b>`; return; }
  const b = r.bundle;
  box.className = "create-result ok";
  box.innerHTML = `
    <div style="font-weight:650;margin-bottom:6px">
      ${b.deployed ? "✅ Pipeline deployed" : "📦 Bundle written"}: <code>${b.pipeline_name}</code>
    </div>
    <div class="muted small">target: ${b.catalog}.${b.schema}</div>
    <div style="margin:8px 0">${b.sql_files.map(f => `<div class="muted small">• ${f}</div>`).join("")}</div>
    <div class="muted small">bundle dir:</div>
    <pre class="code" style="max-height:80px">${b.bundle_dir}</pre>
    <div class="muted small" style="margin-top:8px">deploy command:</div>
    <pre class="code" style="max-height:80px">${b.deploy_command}\n${b.run_command}</pre>
    ${b.deploy_log ? `<div class="muted small" style="margin-top:8px">${escapeHtml(b.deploy_log)}</div>` : ""}`;
}
const escapeHtml = s => s.replace(/[&<>]/g, c => ({ "&": "&amp;", "<": "&lt;", ">": "&gt;" }[c]));

// ---------------------------------------------------------------- config ----
async function loadConfig() {
  state.config = await api("/api/config");
  $("#provider-pill").textContent = `provider: ${state.config.domo_provider}`;
  $("#deploy-pill").textContent = state.config.deploy_ready
    ? `deploy: ${state.config.databricks_profile}` : "deploy: files only";
}
function openConfig() {
  const c = state.config;
  $("#cfg-catalog").value = c.catalog; $("#cfg-schema").value = c.schema;
  $("#cfg-profile").value = c.databricks_profile;
  $("#cfg-provider").value = c.domo_provider; $("#cfg-domo-id").value = c.domo_client_id;
  $("#cfg-secret").textContent = c.domo_secret_present
    ? "Secret detected in environment ✓" : "No DOMO_CLIENT_SECRET in environment.";
  $("#config-modal").classList.remove("hidden");
}
async function saveConfig() {
  const updates = {
    catalog: $("#cfg-catalog").value, schema: $("#cfg-schema").value,
    databricks_profile: $("#cfg-profile").value,
    domo_provider: $("#cfg-provider").value, domo_client_id: $("#cfg-domo-id").value };
  state.config = await api("/api/config",
    { method: "POST", headers: { "Content-Type": "application/json" },
      body: JSON.stringify(updates) });
  await loadConfig();
  $("#config-modal").classList.add("hidden");
}

// ---------------------------------------------------------------- drawers ---
async function showPlan() {
  const p = await api("/api/plan");
  let html = `<p class="muted">${p.value_thesis}</p>`;
  html += `<h4>Recommended pilot</h4><p><b>${p.recommended_pilot.name}</b> — ${p.recommended_pilot.why}</p>`;
  p.waves.forEach(w => {
    html += `<div class="wave-title">Wave ${w.wave}: ${w.theme}</div>`;
    html += `<table><tr><th>DataFlow</th><th>Domain</th><th>Value</th><th>Cx</th></tr>`;
    w.items.forEach(i => html +=
      `<tr><td>${i.name}</td><td>${i.data_domain}</td><td>${i.value.value_per_year}</td><td>${i.complexity_band}</td></tr>`);
    html += `</table>`;
  });
  openDrawer("Migration Plan", html);
}
async function showFeas() {
  const f = await api("/api/feasibility");
  let html = `<p class="muted">GREEN ${f.rollup.GREEN} · AMBER ${f.rollup.AMBER} · RED ${f.rollup.RED}. ${f.note}</p>`;
  html += `<table><tr><th>Source</th><th>Rating</th><th>Pattern</th></tr>`;
  f.feasibility.forEach(r => html +=
    `<tr><td>${r.source_system}</td><td class="rate ${r.rating}">${r.rating}</td><td>${r.pattern}</td></tr>`);
  html += `</table>`;
  openDrawer("Lakeflow Connect — Source Feasibility", html);
}
function openDrawer(title, html) {
  $("#drawer-title").textContent = title;
  $("#drawer-body").innerHTML = html;
  $("#drawer").classList.remove("hidden");
}

// ---------------------------------------------------------------- wire up ---
document.addEventListener("click", e => {
  const goto = e.target.closest("[data-goto]");
  if (goto) gotoStage(goto.dataset.goto);
  const step = e.target.closest(".step");
  if (step) gotoStage(step.dataset.stage);
});
$("#btn-config").onclick = openConfig;
$("#cfg-close").onclick = () => $("#config-modal").classList.add("hidden");
$("#cfg-save").onclick = saveConfig;
$("#btn-create").onclick = doCreate;
$("#btn-plan").onclick = showPlan;
$("#btn-feas").onclick = showFeas;
$("#drawer-close").onclick = () => $("#drawer").classList.add("hidden");

(async function init() {
  await loadConfig();
  await loadEstate();
})();
