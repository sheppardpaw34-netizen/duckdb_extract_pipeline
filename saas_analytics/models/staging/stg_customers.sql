SELECT 
    customer_id,
    email,
    CAST(created_at AS TIMESTAMP) AS created_at
FROM {{ ref('raw_customers')}}
