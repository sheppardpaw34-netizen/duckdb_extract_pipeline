WITH customers AS (SELECT * FROM {{ref('stg_stripe__customers')}}
),
subscriptions AS (SELECT * FROM {{ref('stg_stripe__subscriptions')}}
),
invoices AS (SELECT * FROM {{ref('stg_stripe__invoices')}}
),
invoices_aggregates AS (
    SELECT
        customer_id,
        COUNT(invoice_id) AS total_invoices_issued,
        SUM (CASE WHEN payment_status ='paid'THEN amount_paid ELSE 0 END) AS total_revenue_paid,
        MAX (paid_at) AS last_payment_date
    FROM invoices
    GROUP BY customer_id
    
) 
SELECT 
    c.customer_id,
    c.customer_email,
    c.currency_code,
    c.customer_created_at,
    s.subscription_id,
    s.subscription_status,
    s.plan_id,
    s.mrr_amount,
    COALESCE(i.total_invoices_issued,0) AS total_invoices_issued,
    COALESCE(i.total_revenue_paid,0.00) AS total_revenue_paid,
    i.last_payment_date
FROM customers c
LEFT JOIN subscriptions s
    ON c.customer_id=s.customer_id
LEFT JOIN invoices_aggregates i
    ON c.customer_id=i.customer_id