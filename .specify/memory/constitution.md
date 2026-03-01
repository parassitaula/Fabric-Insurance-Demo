# Fabric Insurance Demo Constitution

## Core Principles

### I. Medallion Architecture
All data flows through a Bronze → Silver → Gold layered Lakehouse pattern. Bronze holds raw ingested data (as-is from source), Silver holds cleansed/conformed data with schema enforcement, and Gold holds business-ready aggregates and dimensional models optimized for reporting. No layer may be skipped.

### II. Fabric-Native First
Use Microsoft Fabric built-in capabilities before introducing external tools. Prefer Fabric Data Pipelines for orchestration, Spark Notebooks (PySpark) for transformation, Lakehouses for storage, Warehouses for SQL serving, Dataflows Gen2 for lightweight ingestion, and Power BI for semantic models and reports. Delta Lake (Parquet) is the mandatory storage format for all Lakehouse tables.

### III. Naming Conventions
All Fabric items follow a consistent naming scheme:
- Lakehouses: `lh_<layer>_<domain>` (e.g., `lh_bronze_claims`, `lh_gold_insurance`)
- Notebooks: `nb_<layer>_<domain>_<action>` (e.g., `nb_silver_policies_cleanse`)
- Pipelines: `pl_<layer>_<domain>` (e.g., `pl_bronze_ingest`)
- Warehouse: `wh_<domain>` (e.g., `wh_insurance`)
- Semantic Models: `sm_<domain>` (e.g., `sm_insurance_analytics`)
- Reports: `rpt_<domain>_<purpose>` (e.g., `rpt_claims_dashboard`)

### IV. Data Quality
Every Silver-layer transformation must validate: schema correctness (expected columns and types), null handling for required fields, deduplication on business keys, and referential integrity across related tables. Failed records are routed to a quarantine table (`_quarantine` suffix) rather than silently dropped.

### V. Idempotent & Incremental Processing
All pipelines and notebooks must be idempotent — safe to re-run without producing duplicates. Use merge (upsert) patterns with Delta Lake for incremental loads. Full refreshes are acceptable only for small reference/dimension tables.

## Technology Stack

- **Platform**: Microsoft Fabric (F64 or higher capacity recommended for demo)
- **Compute**: Spark Notebooks (PySpark), Fabric Data Pipelines, Dataflows Gen2
- **Storage**: Fabric Lakehouse (Delta Lake format), Fabric Warehouse for SQL analytics
- **Languages**: PySpark/Python for transformations, T-SQL for warehouse queries, DAX for semantic models
- **Reporting**: Power BI (DirectLake mode preferred for Lakehouse-backed semantic models)
- **Source Control**: Git integration via Fabric workspace settings; all item definitions stored in this repository
- **Insurance Domain Tables**: Policies, Claims, Customers, Agents, Premiums, Coverages (minimum viable schema)

## Development Workflow

1. **Branch per feature**: Create a feature branch for each change; never commit directly to `main`
2. **Local notebook development**: Author and test Spark notebooks locally or in a development Fabric workspace before promoting
3. **Workspace separation**: Maintain at minimum a Dev and Prod workspace; use Fabric deployment pipelines or CI/CD to promote between them
4. **Validate before merge**: Ensure notebooks execute end-to-end without errors, pipelines complete successfully, and Gold-layer data is queryable before merging to `main`
5. **Documentation**: Each notebook must include a markdown cell at the top describing its purpose, inputs, outputs, and any assumptions

## Governance

- This constitution is the authoritative guide for all project decisions; deviations require documented justification
- All changes to Fabric items must be tracked via Git commits with meaningful messages
- Sensitive data (PII such as customer SSN, contact info) must be masked or excluded in Bronze and handled with column-level access controls in Gold
- Capacity consumption should be monitored; avoid leaving long-running Spark sessions idle

**Version**: 1.0.0 | **Ratified**: 2026-03-01 | **Last Amended**: 2026-03-01
