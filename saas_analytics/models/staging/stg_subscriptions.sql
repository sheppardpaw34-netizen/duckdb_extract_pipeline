SELECT 
    subscription_id,
    customer_id,
    status,
    CAST (mrr_amount AS NUMERIC) AS mrr_amount,
    CAST (created_at AS TIMESTAMP) AS created_at,
    CAST (canceled_at AS TIMESTAMP) AS calceled_at
FROM {{ref('raw_subscriptions')}}
