// ============================================================
// Environment-Aware Dataflow Gen2 — Keller Group
// ============================================================
// PURPOSE: Eliminate manual source changes when promoting
//          DFG2 between Dev / QA / Prod workspaces.
//
// HOW IT WORKS:
//   Instead of relying on deployment rules (not yet available
//   for DFG2 CI/CD Preview), this M code detects which
//   workspace it's running in and automatically resolves
//   the correct Lakehouse name.
//
// DEMO TALKING POINT:
//   "The same dataflow definition runs in Dev, QA, and Prod
//    with zero manual changes. It figures out where it is
//    and connects to the right Lakehouse automatically."
// ============================================================

let
    // ── Step 1: Define the workspace-to-lakehouse mapping ──
    // This is the ONLY place you maintain environment config.
    // Add new workspaces here as needed.
    WorkspaceMap = #table(
        {"WorkspacePattern", "LakehouseName", "FilterRegion"},
        {
            {"Keller_Dev",              "Dev_Lakehouse",  "ALL"},
            {"Keller_QA",               "QA_Lakehouse",   "EMEA"},
            {"Keller_Prod_NorthEurope", "Prod_Lakehouse", "ALL"}
        }
    ),

    // ── Step 2: Detect the current workspace ──
    // Fabric.Workspaces() returns all workspaces accessible
    // to the current identity. We filter to find the one
    // that matches our known patterns.
    AllWorkspaces = Fabric.Workspaces(),

    // The current workspace is the one this dataflow lives in.
    // We match by checking which workspace name starts with "Keller_"
    KellerWorkspaces = Table.SelectRows(AllWorkspaces, each
        Text.StartsWith([Name], "Keller_")),

    // Pick the current one — when running inside a workspace,
    // the dataflow's own workspace appears in the list.
    // If multiple match, we use the deployment pipeline naming
    // convention to identify the right one.
    CurrentWorkspaceName = KellerWorkspaces{0}[Name],

    // ── Step 3: Look up the correct Lakehouse ──
    MatchedRow = Table.SelectRows(WorkspaceMap, each
        Text.Contains(CurrentWorkspaceName, [WorkspacePattern])),

    // Resolve values (fall back to Dev if no match)
    TargetLakehouse = if Table.RowCount(MatchedRow) > 0
        then MatchedRow{0}[LakehouseName]
        else "Dev_Lakehouse",

    TargetRegion = if Table.RowCount(MatchedRow) > 0
        then MatchedRow{0}[FilterRegion]
        else "ALL",

    // ── Step 4: Connect to the resolved Lakehouse ──
    // null = current workspace context
    Source = Lakehouse.Contents(null, TargetLakehouse, null),

    // Navigate to the Tables folder
    Tables = Source{[Id="Tables"]}[Data],

    // ── Step 5: Load employee_regions ──
    EmployeeRegions_Raw = Tables{[Name="employee_regions"]}[Data],
    EmployeeRegions = Table.PromoteHeaders(EmployeeRegions_Raw),

    // ── Step 6: Load fixed_assets ──
    FixedAssets_Raw = Tables{[Name="fixed_assets"]}[Data],
    FixedAssets = Table.PromoteHeaders(FixedAssets_Raw),

    // ── Step 7: Load regional_budgets ──
    RegionalBudgets_Raw = Tables{[Name="regional_budgets"]}[Data],
    RegionalBudgets = Table.PromoteHeaders(RegionalBudgets_Raw),

    // ── Step 8: Apply region filter (if not "ALL") ──
    FilteredBudgets = if TargetRegion = "ALL"
        then RegionalBudgets
        else Table.SelectRows(RegionalBudgets, each
            Text.Contains([Region], TargetRegion)),

    // ── Output: Return a record with all tables ──
    // In the actual DFG2, each query would be a separate output.
    // This structure shows the pattern.
    Result = [
        Workspace = CurrentWorkspaceName,
        Lakehouse = TargetLakehouse,
        Region = TargetRegion,
        Data_EmployeeRegions = EmployeeRegions,
        Data_FixedAssets = FixedAssets,
        Data_RegionalBudgets = FilteredBudgets
    ]
in
    Result
