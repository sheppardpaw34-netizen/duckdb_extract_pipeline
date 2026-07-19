import requests
from bs4 import BeautifulSoup
import duckdb
url = "http://scrapeme.live/shop/"
response = requests.get(url)
soup = BeautifulSoup(response.text,'html.parser')
all_product = soup.find_all('li', class_='product')
print(f"beginning igestion: Found {len(all_product)} Records__\n")
conn = duckdb.connect('saas_warehouse.duckdb')
conn.execute("""
             CREATE TABLE IF NOT EXISTS subscription_plans(
             plan_id VARCHAR,
             plan_name VARCHAR,
             monthly_amount FLOAT
             )
""")
conn.execute ("TRUNCATE TABLE subscription_plans")

for product in all_product:
    name = product.find('h2').text.strip()
    raw_price = product.find('span', class_='amount').text.strip()
    clean_price = float(raw_price.replace('£', ''))
    plan_id = name.lower().replace(' ','_')+'_tier'
    conn.execute("""
                 INSERT INTO subscription_plans(plan_id,plan_name,monthly_amount)
                 VALUES(?,?,?)
    """,(plan_id,name,clean_price))
print("__Duckdb ingestion complete: 16 Record successfully loaded in engine__")
print("\n---verifying database state(SELECT * FROM subscription_plans)---")
view_data = conn.execute("SELECT * FROM subscription_plans LIMIT 5").fetchall()
for row in view_data:
    print (row)
conn.close()