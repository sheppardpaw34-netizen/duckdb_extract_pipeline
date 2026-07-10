WITH base_mrr AS (
    SELECT
        subscription_id,
        customer_id,
        ends_at AS date_month,
        mrr AS current_month_mrr
    FROM {{ ref('stripe_subscriptions') }}
),

mrr_with_lag AS (
    SELECT
        subscription_id,
        customer_id,
        date_month,
        current_month_mrr,
        LAG(current_month_mrr, 1, 0.00) OVER (
            PARTITION BY customer_id 
            ORDER BY date_month
        ) AS previous_month_mrr
    FROM base_mrr
)

SELECT
    subscription_id,
    customer_id,
    date_month,
    current_month_mrr,
    previous_month_mrr,
    (current_month_mrr - previous_month_mrr) AS mrr_variance,
    CASE 
        WHEN previous_month_mrr = 0 AND current_month_mrr > 0 THEN 'New'
        WHEN previous_month_mrr > 0 AND current_month_mrr > previous_month_mrr THEN 'Expansion'
        WHEN previous_month_mrr > 0 AND current_month_mrr > 0 AND current_month_mrr < previous_month_mrr THEN 'Contraction'
        WHEN previous_month_mrr > 0 AND current_month_mrr = 0 THEN 'Churn'
        WHEN previous_month_mrr = 0 AND current_month_mrr > 0 THEN 'Reactivation'
        ELSE 'No Change'
    END AS mrr_change_category
FROM mrr_with_lag