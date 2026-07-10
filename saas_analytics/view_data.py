import duckdb

# Connect to your local analytical warehouse file
con = duckdb.connect("../saas_warehouse.duckdb")

print("\n--- STRIPE SUBSCRIPTIONS ACTIVE ROWS ---")

# Fetch and display records cleanly using standard SQL formatting
con.execute("SELECT * FROM main.stripe_subcriptions").show()

con.close()