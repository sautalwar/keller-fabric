# Keller Group — Microsoft Fabric Demo Repository

> **Built entirely with GitHub Copilot Agent Mode** — Every file in this repository was generated using agentic AI to demonstrate the power of GitHub Copilot for Microsoft Fabric automation.

## What's Inside

| Folder | Contents | Demo Questions |
|--------|----------|----------------|
| `.github/workflows/` | GitHub Actions for Fabric CI/CD automation | Q1, Q3, Q4 |
| `notebooks/` | PySpark notebooks for lakehouse data engineering | Q7, Q8 |
| `sample-data/` | CSV datasets for demo scenarios | Q8, Q10, Q12 |
| `scripts/` | PowerShell automation scripts for Fabric REST APIs | Q1-Q5, Q10, Q11 |
| `semantic-model/` | TMDL semantic model definition | Q1, Q8, Q11 |
| `security/` | RLS/OLS DAX rules and OneLake RBAC configuration | Q8 |
| `docs/` | Architecture documentation | All |

## Quick Start

### 1. Upload sample data to your lakehouse
Upload the CSVs from `sample-data/` to your Fabric lakehouse's Files section, then run the notebooks in order.

### 2. Run the notebooks
```
01_data_ingestion.py      → Loads CSVs into Delta tables
02_data_transformation.py → Creates Silver-layer transformed tables
03_data_quality_checks.py → Validates data quality with automated checks
```

### 3. Configure GitHub Actions
1. Add repository secrets: `FABRIC_CLIENT_ID`, `FABRIC_CLIENT_SECRET`, `FABRIC_TENANT_ID`
2. Update workspace IDs in the workflow files
3. Push to `main` to trigger the sync workflow

### 4. Apply security
- Import `security/rls-rules.dax` into your semantic model
- Apply `security/onelake-roles.json` via the OneLake RBAC API

## Workspace Naming Convention

```
KLR-{BU}-{Region}-{Env}-PowerBI-{Layer}-WS

Examples:
  KLR-RO-NorthEurope-Dev-PowerBI-SM-WS    (Semantic Models - Dev)
  KLR-RO-NorthEurope-QA-PowerBI-Reports-WS (Reports - QA)
  KLR-RO-NorthEurope-Prod-PowerBI-SM-WS   (Semantic Models - Prod)
```

## How This Was Built

Every file in this repository was generated using **GitHub Copilot Agent Mode**:

1. **Notebooks**: "Create a PySpark notebook that ingests CSV files into a Fabric lakehouse as Delta tables"
2. **GitHub Actions**: "Create a GitHub Actions workflow that deploys to multiple Fabric workspaces using matrix strategy"
3. **PowerShell scripts**: "Write a script that checks Git sync status across all Fabric workspaces"
4. **Security configs**: "Generate DAX RLS rules that filter by region using USERPRINCIPALNAME()"
5. **Sample data**: "Create sample CSV datasets for a construction company's fixed assets and regional budgets"

This demonstrates that a BI team can bootstrap their entire Fabric CI/CD infrastructure in hours, not weeks.
