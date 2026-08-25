"""generators — build-target artifact writers.

Each module turns the transpile result / estate signals into a real, valid-shaped
Databricks artifact for one build target. They're pure (return strings / dicts);
`core.bundle.write_bundle` decides which to write based on the selected targets.
Artifacts are honest starting points grounded in the recovered Domo shapes — not
production-tuned — matching the accelerator's "draft-grade, human-reviewable" stance.
"""

from __future__ import annotations

# The selectable build targets (label + which asset types they apply to).
BUILD_TARGETS = [
    {"key": "etl_pipeline", "label": "ETL Pipeline (SDP)", "applies": ["magic_etl", "sql_dataflow"]},
    {"key": "metric_views", "label": "Metric Views", "applies": ["magic_etl", "sql_dataflow", "beast_mode"]},
    {"key": "ai_bi_dashboard", "label": "AI/BI Dashboard", "applies": ["magic_etl", "sql_dataflow", "card", "page"]},
    {"key": "genie_space", "label": "Genie Space", "applies": ["magic_etl", "sql_dataflow", "card", "page"]},
    {"key": "databricks_workflow", "label": "Databricks Workflow", "applies": ["magic_etl", "sql_dataflow"]},
    {"key": "uc_ingestion", "label": "UC Ingestion", "applies": ["connector"]},
]

DEFAULT_TARGETS = ["etl_pipeline"]
