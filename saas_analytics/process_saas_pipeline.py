import duckdb
import os

print("Initializing fresh DuckDB analytical engine...")
con = duckdb.connect(database=':memory:')

# Explicitly cast the column to text before applying string operations
cleansing_query = """
WITH raw_data AS (
    SELECT 
        event_id,
        customer_id,
        subscription_id,
        mrr_impact,
        CASE 
            WHEN CAST(event_timestamp AS VARCHAR) LIKE '%/%' THEN strptime(CAST(event_timestamp AS VARCHAR), '%d/%m/%Y %H:%M:%S')
            WHEN CAST(event_timestamp AS VARCHAR) LIKE '%T%' THEN strptime(substring(CAST(event_timestamp AS VARCHAR) from 1 for 19), '%Y-%m-%dT%H:%M:%S')
            ELSE CAST(event_timestamp AS TIMESTAMP)
        END AS standardized_timestamp
    FROM 'raw_stripe_events.csv'
),
deduplicated_data AS (
    SELECT 
        *,
        ROW_NUMBER() OVER (PARTITION BY event_id ORDER BY standardized_timestamp) as row_num
    FROM raw_data
    WHERE customer_id IS NOT NULL
)
SELECT 
    event_id,
    customer_id,
    subscription_id,
    mrr_impact,
    standardized_timestamp
FROM deduplicated_data
WHERE row_num = 1;
"""

print("Executing SQL data quality rules on raw strings...")
cleaned_df = con.execute(cleansing_query).df()

os.makedirs('data_staged', exist_ok=True)
output_path = 'data_staged/clean_stripe_events.csv'
cleaned_df.to_csv(output_path, index=False)

print(f"\nSUCCESS: Cleansed dataset exported to local staging zone at: {output_path}")
print("\n--- Cleaned Data Preview ---")
print(cleaned_df)