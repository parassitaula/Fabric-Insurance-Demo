# Fabric Insurance Demo

A modern data platform demo for the insurance industry built on **Microsoft Fabric**, showcasing the full Medallion Architecture (Bronze → Silver → Gold) with 7 insurance domain tables and ~8,000 rows of realistic mock data.

## Highlights

- **Medallion Architecture** — Bronze (raw ingestion), Silver (cleansed & conformed), Gold (business aggregates)
- **7 Domain Tables** — Customers, Agents, Policies, Coverages, Premiums, Claims, Claim Payments
- **13 Spark Notebooks** — End-to-end PySpark pipeline with data quality, deduplication, and quarantine patterns
- **Data Quality** — ~2% intentional bad data seeded for demonstrating validation, null checks, and quarantine tables
- **Warehouse SQL** — 8 T-SQL analytical queries for the Fabric Warehouse
- **Self-Contained Architecture Doc** — Interactive HTML with ERD, architecture diagrams, and KPI definitions
- **One-Click Deployment** — Single prerequisite notebook deploys all artifacts to any Fabric workspace

## Project Structure

```
Fabric-Insurance-Demo/
├── notebooks/
│   ├── nb_prereq_deploy.ipynb        # Deployment notebook (run this first)
│   ├── nb_00_generate_mock_data.ipynb # Generates 7 CSVs → Bronze Lakehouse
│   ├── nb_01_bronze_ingest.ipynb      # CSV → Delta (Bronze layer)
│   ├── nb_02_silver_customers.ipynb   # Customers cleansing
│   ├── nb_03_silver_agents.ipynb      # Agents cleansing
│   ├── nb_04_silver_policies.ipynb    # Policies cleansing
│   ├── nb_05_silver_coverages.ipynb   # Coverages cleansing
│   ├── nb_06_silver_premiums.ipynb    # Premiums cleansing
│   ├── nb_07_silver_claims.ipynb      # Claims cleansing
│   ├── nb_08_silver_claim_payments.ipynb # Claim Payments cleansing
│   ├── nb_09_gold_claims_summary.ipynb   # Claims aggregation
│   ├── nb_10_gold_premium_revenue.ipynb  # Premium revenue analysis
│   ├── nb_11_gold_customer_360.ipynb     # Customer 360 view
│   └── nb_12_gold_kpi_metrics.ipynb      # Executive KPIs
├── warehouse/
│   └── sample_queries.sql             # 8 T-SQL analytical queries
├── docs/
│   └── architecture.html              # Self-contained architecture doc
└── .gitignore
```

## Quick Start

### Option A: One-Click Deployment (Recommended)

1. Create a **Fabric workspace** with capacity assigned
2. Import `notebooks/nb_prereq_deploy.ipynb` into the workspace
3. Update **Cell 2** with your `WORKSPACE_ID`
4. **Run All** — the notebook will:
   - Create 3 Lakehouses (Bronze, Silver, Gold)
   - Create 1 Warehouse
   - Upload all 13 pipeline notebooks
   - Optionally execute all notebooks in sequence (nb_00 generates mock data automatically)

### Option B: Git Integration

1. Connect your Fabric workspace to this Git repository
2. Fabric will automatically sync all notebooks
3. Manually create the 3 Lakehouses and 1 Warehouse (or run Steps 2-3 of the prereq notebook)
4. Set Default Lakehouse for each notebook (see mapping below)

### Option C: Manual Import

1. Create the workspace artifacts manually:
   - `lh_bronze_insurance`, `lh_silver_insurance`, `lh_gold_insurance` (Lakehouses)
   - `wh_insurance` (Warehouse)
2. Import all notebooks from `notebooks/`
3. Set Default Lakehouse for each notebook
4. Run `nb_00_generate_mock_data` first (generates CSVs to Bronze Lakehouse)

## Notebook Execution Order

Run notebooks in this exact sequence:

| Step | Notebook | Layer | Default Lakehouse |
|------|----------|-------|-------------------|
| 0 | `nb_00_generate_mock_data` | Bronze | `lh_bronze_insurance` |
| 1 | `nb_01_bronze_ingest` | Bronze | `lh_bronze_insurance` |
| 2 | `nb_02_silver_customers` | Silver | `lh_silver_insurance` |
| 3 | `nb_03_silver_agents` | Silver | `lh_silver_insurance` |
| 4 | `nb_04_silver_policies` | Silver | `lh_silver_insurance` |
| 5 | `nb_05_silver_coverages` | Silver | `lh_silver_insurance` |
| 6 | `nb_06_silver_premiums` | Silver | `lh_silver_insurance` |
| 7 | `nb_07_silver_claims` | Silver | `lh_silver_insurance` |
| 8 | `nb_08_silver_claim_payments` | Silver | `lh_silver_insurance` |
| 9 | `nb_09_gold_claims_summary` | Gold | `lh_gold_insurance` |
| 10 | `nb_10_gold_premium_revenue` | Gold | `lh_gold_insurance` |
| 11 | `nb_11_gold_customer_360` | Gold | `lh_gold_insurance` |
| 12 | `nb_12_gold_kpi_metrics` | Gold | `lh_gold_insurance` |

> **Note**: Silver notebooks (steps 2-8) can run in parallel. Gold notebooks (steps 9-12) can also run in parallel after all Silver notebooks complete.

## Data Model

| Table | Rows | Business Key | Layer |
|-------|------|--------------|-------|
| Customers | ~755 | `customer_id` | Bronze → Silver |
| Agents | 50 | `agent_id` | Bronze → Silver |
| Policies | 1,000 | `policy_id` | Bronze → Silver |
| Coverages | 2,000 | `coverage_id` | Bronze → Silver |
| Premiums | 3,000 | `premium_id` | Bronze → Silver |
| Claims | ~805 | `claim_id` | Bronze → Silver |
| Claim Payments | 500 | `payment_id` | Bronze → Silver |

**Gold Layer Outputs**:
- `gold_claims_summary` — Claims aggregated by year, type, and status
- `gold_premium_revenue` — Revenue breakdown by policy type and billing period
- `gold_customer_360` — Full customer view with policy count, premium totals, risk score
- `gold_kpi_metrics` — Executive KPIs: loss ratio, collection rate, approval rate

## Data Quality Patterns

Each Silver notebook demonstrates:
- **String trimming** — Leading/trailing whitespace removal
- **Type casting** — Enforced schemas with proper date, decimal, integer types
- **Required field validation** — Null/empty checks on business-critical fields
- **Deduplication** — Window function-based dedup on business keys (keeps latest)
- **Quarantine** — Rejected rows written to `*_quarantine` tables with rejection reason
- **Audit columns** — `_processed_at` timestamp on every record

## Naming Conventions

| Artifact | Pattern | Example |
|----------|---------|---------|
| Lakehouse | `lh_<layer>_<domain>` | `lh_bronze_insurance` |
| Notebook | `nb_<##>_<layer>_<name>` | `nb_02_silver_customers` |
| Warehouse | `wh_<domain>` | `wh_insurance` |
| Semantic Model | `sm_<domain>` | `sm_insurance` |
| Report | `rpt_<domain>_<purpose>` | `rpt_insurance_dashboard` |

## Architecture

**[View Interactive Architecture Document](https://parassitaula.github.io/Fabric-Insurance-Demo/docs/architecture.html)**

The architecture doc includes:
- Solution architecture flow diagram
- Entity Relationship Diagram (ERD)
- Technology stack details
- Complete notebook inventory
- Data quality rules per table
- KPI definitions and formulas

## What You Can Do After Deployment

Once the pipeline has run end-to-end, your Fabric workspace is fully loaded with Bronze, Silver, and Gold layers. Here are things you can explore:

### Query the Warehouse
Open `wh_insurance` in the Fabric SQL editor and run the sample queries from [warehouse/sample_queries.sql](warehouse/sample_queries.sql):
- **Loss ratio by policy type** — compare claims paid vs. premiums collected
- **Top 10 highest-value claims** — identify outliers
- **Monthly premium revenue trend** — spot seasonal patterns
- **Agent performance leaderboard** — rank agents by book size and loss ratio
- **Customer 360 lookup** — full profile with policies, claims, and risk score

### Build a Power BI Report
1. Create a **Semantic Model** (`sm_insurance`) using DirectLake mode against `lh_gold_insurance`
2. Add the 4 Gold tables: `gold_claims_summary`, `gold_premium_revenue`, `gold_customer_360`, `gold_kpi_metrics`
3. Build an executive dashboard (`rpt_insurance_dashboard`) with:
   - **KPI cards** — Loss Ratio, Collection Rate, Approval Rate, Average Claim Value
   - **Claims heatmap** — by type and status over time
   - **Premium revenue waterfall** — by policy type and billing period
   - **Customer risk distribution** — histogram of risk scores from Customer 360
   - **Agent performance scatter** — policies sold vs. loss ratio per agent

### Explore Data Quality
- Open any Silver notebook and inspect the `*_quarantine` tables to see rejected rows and reasons
- Run `SELECT * FROM lh_silver_insurance.customers_quarantine` in the Warehouse to browse bad data
- Modify `nb_00_generate_mock_data` to increase the bad-data percentage and re-run the pipeline

### Extend the Platform
- **Add a new table** — create a new `nb_XX_silver_*.ipynb` following the existing pattern (copy `nb_02` as a template)
- **Add a Data Activator alert** — trigger an alert when Loss Ratio exceeds a threshold
- **Schedule the pipeline** — create a Fabric Data Pipeline that orchestrates notebooks in sequence
- **Add incremental loads** — convert Bronze ingestion from `overwrite` to `append` mode with watermark tracking
- **Connect to real data** — replace `nb_00` with a notebook that reads from an external source (Azure SQL, API, ADLS)
- **Create a Lakehouse shortcut** — point `lh_bronze_insurance` at an external ADLS Gen2 container

### Review the Architecture
Open the [interactive architecture document](https://parassitaula.github.io/Fabric-Insurance-Demo/docs/architecture.html) for ERD, data flow diagrams, and KPI definitions.

## Prerequisites

- Microsoft Fabric workspace with capacity assigned
- **Contributor** or **Admin** role on the workspace
- No additional libraries required — all notebooks use PySpark built-ins

## License

This is a demonstration project for educational purposes.
