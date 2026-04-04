# Environment-Aware DFG2: Workaround Guide

## The Problem
DFG2 CI/CD (Preview) deployment rules don't support automatic parameter swapping yet.
When you deploy a DFG2 from Dev to QA, the parameters (e.g., `pLakehouseName = "Dev_Lakehouse"`)
stay unchanged. Someone has to manually fix them.

## Two Workarounds

### Option A: Environment-Aware M Code (Easier to Demo)

**File:** `environment_aware_dataflow.m`

Instead of relying on external rules, the M code itself detects which workspace it's running in
and resolves the correct Lakehouse name automatically.

**How it works:**
1. A lookup table maps workspace names to Lakehouse names
2. `Fabric.Workspaces()` detects the current workspace
3. The code matches the workspace and picks the right Lakehouse
4. Zero manual changes needed after deployment

**To demo:**
1. Open `df_keller_file_ingestion` in Power Query editor
2. Open the Advanced Editor (Home > Advanced Editor)
3. Replace the M code with `environment_aware_dataflow.m`
4. Show the `WorkspaceMap` table — this is the only config
5. Publish, deploy to QA, and show it auto-resolves to QA_Lakehouse

**Pros:** Self-contained, no external dependencies, works immediately
**Cons:** Logic lives inside the dataflow (not externally configurable)

---

### Option B: GitHub Actions + Fabric REST API (More Robust)

**File:** `.github/workflows/update-dfg2-params.yml`

After the deployment pipeline promotes the DFG2, a GitHub Actions workflow calls the Fabric
REST API to update the parameters for the target environment.

**How it works:**
1. Deployment pipeline promotes DFG2 from Dev → QA (parameters unchanged)
2. You trigger the GitHub Actions workflow, selecting "qa" as the target
3. The workflow authenticates via service principal
4. It finds the DFG2 in the QA workspace via REST API
5. It updates pLakehouseName to "QA_Lakehouse" and pFilterRegion to "EMEA"
6. It triggers a refresh so the DFG2 runs with the new parameters

**To demo:**
1. Show the workflow file in GitHub (explain each step)
2. Go to Actions tab > "Update DFG2 Parameters Post-Deployment"
3. Click "Run workflow" > select "qa" > check "dry_run" first
4. Show the dry run output (what would change)
5. Run again without dry_run to apply

**Prerequisites (one-time setup):**
- Service principal with Fabric API permissions
- GitHub secrets: AZURE_TENANT_ID, AZURE_CLIENT_ID, AZURE_CLIENT_SECRET

**Pros:** Externally configurable, auditable, integrates with CI/CD
**Cons:** Requires service principal setup

---

## Recommendation

For the **demo**, use Option A (M code) — it's self-contained and shows the concept clearly.
For **production**, use Option B (GitHub Actions) — it's more maintainable and auditable.

Both approaches make the same point: **the architecture supports full automation today,
even without native deployment rule support.**
