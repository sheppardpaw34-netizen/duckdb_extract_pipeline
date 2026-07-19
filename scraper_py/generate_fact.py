import duckdb
import random
from datetime import datetime, timedelta

conn = duckdb.connect('saas_warehouse.duckdb')
print("__Intializing star schema fact ddl table__")

conn.execute("""
            CREATE TABLE IF NOT EXISTS fact_subscription_events(
             event_id VARCHAR PRIMARY KEY,
             customer_id VARCHAR,
             plan_id VARCHAR,
             event_type VARCHAR,
             event_date DATE,
             mrr_impact FLOAT
            )
""")

conn.execute("TRUNCATE TABLE fact_subscription_events")
available_plans = [row[0] for row in conn.execute ("SELECT plan_id FROM subscription_plans").fetchall() ]

if not available_plans :
    print("Error: 'subcriber_plan' table is empty.Please run the scraper.py first!") 
    conn.close()
    exit()
print(f"successfully maped{len(available_plans)} dimension keys for relational mapping")

event_type = ['activation','upgrade','churn']
start_date = datetime(2026,1,1)
print("Steaming transactional fact in to warehouse")

for i in range (1,50) :
    event_id = f"evt_{100+i}"
    customer_id = f"cus_{random.randint(100,120)}"
    plan_id = random.choice (available_plans)
    event_type = random.choice (event_type)
    event_date = (start_date+timedelta (days = random.randint(0,180))).date()
    mrr_impact = random.choice([48.3,87.9,53.6,109.4]) if event_type != 'churn' else -64.3

    conn.execute("""
                 INSERT INTO fact_subscription_events(event_id,customer_id,plan_id,event_type,event_date,mrr_impact)
                 VALUES (?,?,?,?,?,?)
    """, (event_id,customer_id,plan_id,event_type,event_date,mrr_impact))
print("fact table populate successfully")
print("\n__Structural sample: SELECT * FROM fact_subscription_events LIMIT 5__")
sample_facts = conn.execute("SELECT * FROM fact_subscription_events LIMIT 5").fetchall()
for row in sample_facts:
    print(row)
conn.close()