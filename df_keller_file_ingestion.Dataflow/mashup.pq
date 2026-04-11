[DefaultOutputDestinationSettings = [DestinationDefinition = [Kind = "Reference", QueryName = "DefaultDestination", IsNewTarget = true], UpdateMethod = [Kind = "Replace"], DestinationTypeSettings = [Kind = "Table"]], StagingDefinition = [Kind = "FastCopy"]]
section Section1;
[DataDestinations = {[Definition = [Kind = "Reference", QueryName = "employee_regions csv_DataDestination", IsNewTarget = true], Settings = [Kind = "Automatic", TypeSettings = [Kind = "Table"]]]}]
shared employee_regions = let
  Source = Lakehouse.Contents(null),
  Navigation = Source{[workspaceId = "6cfe7d37-f6e1-4461-8c01-6c70d981e257"]}[Data],
  #"Navigation 1" = Navigation{[lakehouseId = "03f9285a-2b8f-4daa-9873-549325797fb3"]}[Data],
  #"Navigation 2" = #"Navigation 1"{[Id = "Files", ItemKind = "Folder"]}[Data],
  #"Navigation 3" = #"Navigation 2"{[Name = "employee_regions.csv"]}[Content],
  #"Imported CSV" = Csv.Document(#"Navigation 3", [Delimiter = ",", Columns = 8, QuoteStyle = QuoteStyle.None]),
  #"Promoted headers" = Table.PromoteHeaders(#"Imported CSV", [PromoteAllScalars = true]),
  #"Changed column type" = Table.TransformColumnTypes(#"Promoted headers", {{"employee_id", type text}, {"email", type text}, {"display_name", type text}, {"region", type text}, {"country", type text}, {"role", type text}, {"department", type text}, {"is_manager", type logical}})
in
  #"Changed column type";
[BindToDefaultDestination = true]
shared fixed_assets = let
  Source = Lakehouse.Contents(null),
  Navigation = Source{[workspaceId = "6cfe7d37-f6e1-4461-8c01-6c70d981e257"]}[Data],
  #"Navigation 1" = Navigation{[lakehouseId = "03f9285a-2b8f-4daa-9873-549325797fb3"]}[Data],
  #"Navigation 2" = #"Navigation 1"{[Id = "Files", ItemKind = "Folder"]}[Data],
  #"Navigation 3" = #"Navigation 2"{[Name = "fixed_assets.csv"]}[Content],
  #"Imported CSV" = Csv.Document(#"Navigation 3", [Delimiter = ",", Columns = 11, QuoteStyle = QuoteStyle.None]),
  #"Promoted headers" = Table.PromoteHeaders(#"Imported CSV", [PromoteAllScalars = true]),
  #"Changed column type" = Table.TransformColumnTypes(#"Promoted headers", {{"asset_id", type text}, {"asset_name", type text}, {"category", type text}, {"region", type text}, {"country", type text}, {"acquisition_date", type date}, {"acquisition_cost", Int64.Type}, {"current_value", Int64.Type}, {"depreciation_method", type text}, {"useful_life_years", Int64.Type}, {"status", type text}})
in
  #"Changed column type";
[BindToDefaultDestination = true]
shared regional_budgets = let
  Source = Lakehouse.Contents(null),
  Navigation = Source{[workspaceId = "6cfe7d37-f6e1-4461-8c01-6c70d981e257"]}[Data],
  #"Navigation 1" = Navigation{[lakehouseId = "03f9285a-2b8f-4daa-9873-549325797fb3"]}[Data],
  #"Navigation 2" = #"Navigation 1"{[Id = "Files", ItemKind = "Folder"]}[Data],
  #"Navigation 3" = #"Navigation 2"{[Name = "regional_budgets.csv"]}[Content],
  #"Imported CSV" = Csv.Document(#"Navigation 3", [Delimiter = ",", Columns = 9, QuoteStyle = QuoteStyle.None]),
  #"Promoted headers" = Table.PromoteHeaders(#"Imported CSV", [PromoteAllScalars = true]),
  #"Changed column type" = Table.TransformColumnTypes(#"Promoted headers", {{"budget_id", type text}, {"region", type text}, {"department", type text}, {"fiscal_year", Int64.Type}, {"quarter", type text}, {"budget_amount", Int64.Type}, {"actual_amount", Int64.Type}, {"forecast_amount", Int64.Type}, {"currency", type text}})
in
  #"Changed column type";
shared pLakehouseName = "Dev_Lakehouse" meta [IsParameterQuery = true, IsParameterQueryRequired = true, Type = type text];
shared pFilterRegion = "ALL" meta [IsParameterQuery = true, IsParameterQueryRequired = false, Type = type text];
shared pSourceTable = "raw_project_costs" meta [IsParameterQuery = true, IsParameterQueryRequired = true, Type = type text];
shared #"employee_regions csv_DataDestination" = let
  Pattern = Lakehouse.Contents([CreateNavigationProperties = false, EnableFolding = false]),
  Navigation_1 = Pattern{[workspaceId = "6cfe7d37-f6e1-4461-8c01-6c70d981e257"]}[Data],
  Navigation_2 = Navigation_1{[lakehouseId = "03f9285a-2b8f-4daa-9873-549325797fb3"]}[Data],
  TableNavigation = Navigation_2{[Id = "employee_regions", ItemKind = "Table"]}?[Data]?
in
  TableNavigation;
shared DefaultDestination = Lakehouse.Contents([EnableFolding = false]){[workspaceId = "6cfe7d37-f6e1-4461-8c01-6c70d981e257"]}[Data]{[lakehouseId = "03f9285a-2b8f-4daa-9873-549325797fb3"]}[Data];
