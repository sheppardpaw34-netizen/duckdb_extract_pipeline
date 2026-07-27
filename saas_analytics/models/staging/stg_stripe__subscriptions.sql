with source AS (SELECT * FROM {{source('stripe','raw_stripe_subscriptions')}}
),
deduplicated AS (
    SELECT
        *,
        ROW_NUMBER() OVER (
            PARTITION BY subscription_id 
            ORDER BY updated_at DESC
        ) AS row_num
    FROM source
)
SELECT
    subscription_id,
    customer_id,
    LOWER(status) AS subscription_status,
    plan_id,
    CAST(mrr_amount AS NUMERIC(12, 2)) AS mrr_amount,
    quantity,
    start_date AS subscription_started_at,
    current_period_start,
    current_period_end,
    canceled_at,
    ended_at,
    updated_at
FROM deduplicated
WHERE row_num = 1