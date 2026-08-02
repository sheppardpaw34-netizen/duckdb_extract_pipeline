with events as (
    select * from {{ ref('stg_subscription_events') }}
),

plans as (
    select * from {{ ref('dim_plans') }}
)

select
    events.event_id,
    events.customer_id,
    -- Join to our dimension table using the business plan_id
    plans.plan_key,
    events.event_type,
    events.event_date,
    events.mrr_impact,
    -- Business logic: classify this as either an ARR gain or loss
    case 
        when events.mrr_impact > 0 then 'expansion_or_renewal'
        else 'churn_or_contraction'
    end as event_category
from events
left join plans on events.plan_id = plans.plan_id