DROP TABLE IF EXISTS raw_stripe_customers;
DROP TABLE IF EXISTS raw_stripe_subscriptions;
DROP TABLE IF EXISTS raw_stripe_invoices;

CREATE TABLE IF NOT EXISTS raw_stripe_customers (
    customer_id VARCHAR(255) PRIMARY KEY,
    email VARCHAR(320) NOT NULL,
    currency VARCHAR(3) DEFAULT 'USD',
    is_deleted BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP NOT NULL,
    updated_at TIMESTAMP NOT NULL
);

INSERT INTO raw_stripe_customers VALUES
('cus_001', 'alex@acme.com', 'USD', false, '2026-01-10 08:00:00', '2026-01-10 08:00:00'),
('cus_002', 'sarah@techcorp.com', 'USD', false, '2026-02-15 10:30:00', '2026-02-15 10:30:00'),
('cus_003', 'mike@startup.io', 'USD', false, '2026-03-01 12:00:00', '2026-03-01 12:00:00');

CREATE TABLE IF NOT EXISTS raw_stripe_subscriptions (
    subscription_id VARCHAR(255) PRIMARY KEY,
    customer_id VARCHAR(255) NOT NULL,
    status VARCHAR(50) NOT NULL,
    plan_id VARCHAR(255) NOT NULL,
    mrr_amount NUMERIC(12,2) NOT NULL,
    quantity INT DEFAULT 1,
    start_date TIMESTAMP NOT NULL,
    current_period_start TIMESTAMP NOT NULL,
    current_period_end TIMESTAMP NOT NULL,
    canceled_at TIMESTAMP,
    ended_at TIMESTAMP,
    updated_at TIMESTAMP NOT NULL

);
INSERT INTO raw_stripe_subscriptions VALUES
('sub_101', 'cus_001', 'active', 'plan_pro_monthly', 100.00, 1, '2026-01-10 08:00:00', '2026-07-10 08:00:00', '2026-08-10 08:00:00', NULL, NULL, '2026-07-10 08:00:00'),
('sub_102', 'cus_002', 'canceled', 'plan_enterprise', 500.00, 1, '2026-02-15 10:30:00', '2026-05-15 10:30:00', '2026-06-15 10:30:00', '2026-05-20 14:00:00', '2026-06-15 10:30:00', '2026-05-20 14:00:00'),
('sub_103', 'cus_003', 'active', 'plan_starter', 50.00, 1, '2026-03-01 12:00:00', '2026-07-01 12:00:00', '2026-08-01 12:00:00', NULL, NULL, '2026-07-01 12:00:00');

CREATE TABLE IF NOT EXISTS raw_stripe_invoices(
    invoice_id VARCHAR (255) PRIMARY KEY,
    subscription_id VARCHAR(255),
    customer_id VARCHAR(255) NOT NULL,
    amount_due NUMERIC(12,2) NOT NULL,
    amount_paid NUMERIC(12,2) NOT NULL,
    payment_status VARCHAR(50) NOT NULL,
    invoice_created_at TIMESTAMP NOT NULL,
    paid_at TIMESTAMP
);

INSERT INTO raw_stripe_invoices VALUES 
('inv_501', 'sub_101', 'cus_001', 100.00, 100.00, 'paid', '2026-06-10 08:00:00', '2026-06-10 08:05:00'),
('inv_502', 'sub_101', 'cus_001', 100.00, 100.00, 'paid', '2026-07-10 08:00:00', '2026-07-10 08:02:00'),
('inv_503', 'sub_102', 'cus_002', 500.00, 500.00, 'paid', '2026-04-15 10:30:00', '2026-04-15 10:31:00'),
('inv_504', 'sub_102', 'cus_002', 500.00, 0.00, 'uncollectible', '2026-05-15 10:30:00', NULL),
('inv_505', 'sub_103', 'cus_003', 50.00, 50.00, 'paid', '2026-07-01 12:00:00', '2026-07-01 12:01:00');