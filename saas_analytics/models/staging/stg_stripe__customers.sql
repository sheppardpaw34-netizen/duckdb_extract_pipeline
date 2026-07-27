WITH source as ( 
    SELECT * FROM {{source('stripe','raw_stripe_customers')}}
)
SELECT 
    customer_id,
    LOWER(TRIM(email)) as customer_email,
    UPPER(currency) as currency_code,
    created_at as customer_created_at
FROM source