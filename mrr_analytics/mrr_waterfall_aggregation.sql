CREATE TABLE IF NOT EXISTS raw_stripe_subscription_events(
    event_id VARCHAR,
    customer_id VARCHAR,
    event_type VARCHAR,
    mrr_amount_cents INT,
    event_timestamp VARCHAR

);
TRUNCATE TABLE raw_stripe_subscription_events;
INSERT INTO raw_stripe_subscription_events VALUES
('evt_01', 'cust_enterprise_01', 'customer.subscription.created', 100000, '2026-01-02 04:12:00 UTC'),
('evt_02', 'cust_enterprise_01', 'customer.subscription.updated', 100000, '2026-01-02 04:15:00 UTC'),
('evt_03', 'cust_enterprise_02', 'customer.subscription.created', 50000, '2026-01-15 18:22:11 GMT'),
('evt_04', 'cust_enterprise_01', 'customer.subscription.updated', 150000, '2026-02-01 09:00:00 Z'),
('evt_05', 'cust_enterprise_02', 'customer.subscription.updated', 0, '2026-02-14 23:59:59 Z'),
('evt_06', 'cust_enterprise_01', 'customer.subscription.updated', 80000, '2026-03-05 10:00:00 UTC');

DROP TABLE IF EXISTS analytics_cleaned_mrr_events;
CREATE TABLE analytics_cleaned_mrr_events AS
SELECT 
    customer_id,
    CAST (strptime(LEFT(event_timestamp,10),'%Y-%m-%d')AS DATE) AS sub_month,
    CAST (mrr_amount_cents/100.0 AS NUMERIC(18,2))AS mrr_amount
    FROM raw_stripe_subscription_events;
    SELECT * FROM analytics_cleaned_mrr_events;