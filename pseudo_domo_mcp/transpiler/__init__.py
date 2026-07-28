"""Vendored 6-agent Domo->Databricks transpiler.

The agent modules (ingest/parse/emit/beastmode/repoint/reconcile) use flat,
sibling imports (`from ingest import ...`) because they were written to run as
a standalone script. Rather than rewrite them, `pipeline.py` puts this package
directory on sys.path so those imports resolve, and exposes a single importable
`run()` entry point that returns the result dict (instead of sys.exit-ing).
"""
