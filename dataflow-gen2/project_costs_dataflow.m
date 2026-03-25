// ============================================================
// Dataflow Gen2: project_costs_dataflow
// ============================================================
// This is the Power Query M code inside the Dataflow Gen2.
// Notice how it uses PARAMETERS instead of hard-coded values.
// This is what makes deployment rules work.
// ============================================================

// ──────────────────────────────────────────────────────────────
// PARAMETERS (defined in Manage Parameters, enabled as Public)
// ──────────────────────────────────────────────────────────────
//   pLakehouseName  = "Dev_Lakehouse"   (Text, Required, Public)
//   pSourceTable    = "raw_project_costs" (Text, Required, Public)
//   pFilterRegion   = "ALL"              (Text, Optional, Public)


// ──────────────────────────────────────────────────────────────
// THE QUERY
// ──────────────────────────────────────────────────────────────

let
    // Step 1: Connect to the Lakehouse using the PARAMETER
    //         (NOT a hard-coded name like "Dev_Lakehouse")
    Source = Lakehouse.Contents(null, pLakehouseName, null),

    // Step 2: Navigate to the source table using another PARAMETER
    RawTable = Source{[Name = pSourceTable]}[Data],

    // Step 3: Clean the data
    RemovedDuplicates = Table.Distinct(RawTable),
    RenamedColumns = Table.RenameColumns(RemovedDuplicates, {
        {"proj_id", "ProjectID"},
        {"proj_name", "ProjectName"},
        {"cost_gbp", "CostGBP"},
        {"region", "Region"},
        {"report_date", "ReportDate"}
    }),
    SetTypes = Table.TransformColumnTypes(RenamedColumns, {
        {"ProjectID", type text},
        {"ProjectName", type text},
        {"CostGBP", type number},
        {"Region", type text},
        {"ReportDate", type date}
    }),

    // Step 4: Apply region filter using PARAMETER
    //         If pFilterRegion = "ALL", show everything
    //         Otherwise, filter to that specific region
    Filtered = if pFilterRegion = "ALL"
        then SetTypes
        else Table.SelectRows(SetTypes, each [Region] = pFilterRegion)

in
    Filtered


// ──────────────────────────────────────────────────────────────
// DESTINATION (configured in the Dataflow Gen2 UI)
// ──────────────────────────────────────────────────────────────
// Output table: "project_costs" in the target Lakehouse
// Update method: Replace (full refresh)
//
// NOTE: The Lakehouse DESTINATION is set in the UI and swapped
//       via a DATA SOURCE RULE in the deployment pipeline.
//       The parameters above handle the SOURCE and LOGIC.
// ──────────────────────────────────────────────────────────────


// ──────────────────────────────────────────────────────────────
// WHY THIS MATTERS
// ──────────────────────────────────────────────────────────────
//
// WITHOUT parameters:
//   Source = Lakehouse.Contents(null, "Dev_Lakehouse", null)
//   → Deploy to Prod → STILL reads from Dev_Lakehouse! ❌
//
// WITH parameters + deployment rules:
//   Source = Lakehouse.Contents(null, pLakehouseName, null)
//   → Deploy to Prod → Rule changes pLakehouseName to
//     "Prod_Lakehouse" → Reads from Prod! ✅
// ──────────────────────────────────────────────────────────────
