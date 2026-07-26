import json
import urllib.request
import urllib.error
import pandas as pd
import duckdb
def extract_user(api_url:str) -> list[dict]:
    """ Fetches raw jsonpayload form an api endpoint safely."""
    try:
        print("Connecting to API:{api_url}...")
        with urllib.request.urlopen(api_url, timeout=10) as response:
            if response.status == 200:
                raw_data = response.read().decode("utf-8")
                return json.loads(raw_data)
            else:
                print(f"API returned status code: {response.status}")
                return []
    except urllib.error.URLError as e:
        print(f"Network error: {e}")
        return[]
    except json.JSONDecodeError as e:
        print("json parsing error: {e}")
        return[]
def transfrom_users(raw_users : list[dict]) -> pd.DataFrame :
    """Flatten raw json user record into a structural pandas dataframe."""
    clean_records = []
    for user in raw_users :
        record ={
            "user_id": user.get("id"),
            "full_name" : user.get ("name"),
            "email_address": user.get("email"),
            "company_name" : user.get("company",{}).get("name","N/A")

        }
        clean_records.append(record)
        return pd.DataFrame(clean_records)
def run_pipeline() :
    url = "http://jsonplaceholder.typicode.com/users"
    parquet_path = "stg_uses.parquet"
    raw_users = extract_user(url)
    if not raw_users:
        print("Pipeline aborted: No data retrived.")
        return
    df = transfrom_users(raw_users)
    print (f"Succesfully transfrom {len(df)}user records.")
    df.to_parquet(parquet_path,index = False)
    print(f"Persisted staging file to '{parquet_path}'.")
    query = f"""
        SELECT 
            company_name,
            COUNT(user_id) AS total_users
        FROM '{parquet_path}'
        GROUP BY company_name
        ORDER BY total_users DESC
    """
    print("\n--- DUCKDB AGGREGATION METRICS ---")
    metrics_df = duckdb.sql(query).df()
    print(metrics_df)

if __name__ == "__main__":
    run_pipeline()