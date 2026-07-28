# Vendored Industry Data Models

These `.sql` files are **MVM (Minimum Viable Model)** domain-schema slices of the
open-source **Databricks Industry Data Models**:

- Repo: https://github.com/databricks-industry-solutions/lakehouse-industry-data-models
- Blog: https://www.databricks.com/blog/jumpstart-your-data-modeling-databricks-industry-data-models
- License: see that repo's `LICENSE.md`.

We vendor a **subset of domains** (a representative manufacturing / aftermarket /
logistics slice) so the mapping tool runs offline against the *real* canonical
schemas — not a hand-rolled approximation. The full models (ECM tier, all
domains, `model.json`, metric views, DBML, RDF) live in the upstream repo and can
be installed into Unity Catalog via its `model-installer/` notebook.

| Industry | Vendored domains |
|---|---|
| `automotive` | customer, aftersales, quality, vehicle, sales, manufacturing, supply |
| `transport_shipping` | shipment, route, fleet, freight, customer, warehouse |

To refresh or add domains, pull the corresponding
`data-models/<industry>/v1/mvm/schemas/*.sql` from the upstream repo into
`models/<industry>/<domain>.sql`.
