# Fabric notebook source

# METADATA ********************

# META {
# META   "kernel_info": {
# META     "name": "synapse_pyspark"
# META   },
# META   "dependencies": {
# META     "lakehouse": {
# META       "default_lakehouse": "03f9285a-2b8f-4daa-9873-549325797fb3",
# META       "default_lakehouse_name": "Dev_Lakehouse",
# META       "default_lakehouse_workspace_id": "6cfe7d37-f6e1-4461-8c01-6c70d981e257",
# META       "known_lakehouses": [
# META         {
# META           "id": "03f9285a-2b8f-4daa-9873-549325797fb3"
# META         }
# META       ]
# META     }
# META   }
# META }

# CELL ********************

from pyspark.sql.types import *
from pyspark.sql.functions import current_timestamp, lit

LAKEHOUSE_PATH = "Files"
DATASETS = {
    "fixed_assets": {
        "file": "fixed_assets.csv",
        "schema": StructType([
            StructField("asset_id", StringType(), False),
            StructField("asset_name", StringType(), False),
            StructField("category", StringType(), True),
            StructField("region", StringType(), True),
            StructField("country", StringType(), True),
            StructField("acquisition_date", StringType(), True),
            StructField("acquisition_cost", DoubleType(), True),
            StructField("current_value", DoubleType(), True),
            StructField("depreciation_method", StringType(), True),
            StructField("useful_life_years", IntegerType(), True),
            StructField("status", StringType(), True),
        ]),
    },
    "regional_budgets": {
        "file": "regional_budgets.csv",
        "schema": StructType([
            StructField("budget_id", StringType(), False),
            StructField("region", StringType(), False),
            StructField("department", StringType(), True),
            StructField("fiscal_year", IntegerType(), True),
            StructField("quarter", StringType(), True),
            StructField("budget_amount", DoubleType(), True),
            StructField("actual_amount", DoubleType(), True),
            StructField("forecast_amount", DoubleType(), True),
            StructField("currency", StringType(), True),
        ]),
    },
    "employee_regions": {
        "file": "employee_regions.csv",
        "schema": StructType([
            StructField("employee_id", StringType(), False),
            StructField("email", StringType(), False),
            StructField("display_name", StringType(), True),
            StructField("region", StringType(), True),
            StructField("country", StringType(), True),
            StructField("department", StringType(), True),
            StructField("role", StringType(), True),
        ]),
    },
}

# METADATA ********************

# META {
# META   "language": "python",
# META   "language_group": "synapse_pyspark"
# META }

# CELL ********************

for table_name, config in DATASETS.items():
    print(f"Ingesting {table_name}...")
    df = (spark.read.option("header", "true")
        .schema(config["schema"])
        .csv(f"{LAKEHOUSE_PATH}/{config['file']}"))
    df = (df.withColumn("_ingested_at", current_timestamp())
        .withColumn("_source_file", lit(config["file"])))
    (df.write.format("delta").mode("overwrite")
        .option("overwriteSchema", "true")
        .saveAsTable(f"bronze_{table_name}"))
    row_count = spark.table(f"bronze_{table_name}").count()
    print(f"  bronze_{table_name}: {row_count} rows loaded")

# METADATA ********************

# META {
# META   "language": "python",
# META   "language_group": "synapse_pyspark"
# META }

# CELL ********************

print("Ingestion complete! Verifying tables...")
for table_name in DATASETS:
    df = spark.table(f"bronze_{table_name}")
    print(f"bronze_{table_name} ({df.count()} rows):")
    df.show(3, truncate=False)

# METADATA ********************

# META {
# META   "language": "python",
# META   "language_group": "synapse_pyspark"
# META }
