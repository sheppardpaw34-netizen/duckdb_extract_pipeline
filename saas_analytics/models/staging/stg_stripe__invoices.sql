WITH source AS (SELECT * FROM {{source('stripe','raw_stripe_invoices')}}
)
SELECT 
    invoice_id,
    subscription_id,
    customer_id,
    cast(amount_due AS NUMERIC(12,2)) AS amount_due,
    CAST (amount_paid AS NUMERIC(12,2)) AS amount_paid,
    LOWER (payment_status) AS payment_status,
    invoice_created_at,
    paid_at
    FROM source