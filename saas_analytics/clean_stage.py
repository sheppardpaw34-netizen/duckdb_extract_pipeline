import duckdb
import os

print("Initializing local DuckDB analytical engine...")

# Connect to an in-memory database instance
con = duckdb.connect(database=':memory:')

# Define the analytical SQL cleansing query
# We use a Common Table Expression (CTE) to clean timestamps and deduplicate records
cleansing_query = """
WITH raw_data AS (
    SELECT 
        event_id,
        customer_id,
        subscription_id,
        mrr_impact,
        -- Standardize various date string patterns into a uniform TIMESTAMP type
        CASE 
            WHEN event_timestamp LIKE '%/%' THEN strptime(event_timestamp, '%d/%m/%Y %H:%M:%S')
            WHEN event_timestamp LIKE '%T%' THEN strptime(substring(event_timestamp from 1 for 19), '%Y-%m-%dT%H:%M:%S')
            ELSE CAST(event_timestamp AS TIMESTAMP)
        END AS standardized_timestamp
    FROM 'raw_stripe_events.csv'
),
deduplicated_data AS (
    SELECT 
        *,
        -- Assign a unique index to identical events to detect duplication
        ROW_NUMBER() OVER (PARTITION BY event_id ORDER BY standardized_timestamp) as row_num
    FROM raw_data
    -- Enforce data integrity rule: Eliminate transactions missing critical customer keys
    WHERE customer_id IS NOT NULL
)
SELECT 
    event_id,
    customer_id,
    subscription_id,
    mrr_impact,
    standardized_timestamp
FROM deduplicated_data
WHERE row_num = 1; -- Filter out the duplicate records
"""

print("Executing SQL data quality rules and transformations...")
# Run the query and store the results in a local DuckDB relation object
cleaned_df = con.execute(cleansing_query).df()

# Ensure the export directory exists
os.makedirs('data_staged', exist_ok=True)

# Export the clean analytical dataset to a local staging file
output_path = 'data_staged/clean_stripe_events.csv'
cleaned_df.to_csv(output_path, index=False)

print(f"\nSUCCESS: Cleansed dataset exported to local staging zone at: {output_path}")
print("\n--- Cleaned Data Preview ---")
print(cleaned_df)