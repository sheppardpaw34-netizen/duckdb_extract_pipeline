with staging_events as (
    select * from {{ ref('stg_subscription_events') }}
),

distinct_plans as (
    select distinct
        plan_id,
        -- Using business English to categorize tiers for executive reporting
        case 
            when plan_id like '%tier' then upper(replace(plan_id, '_tier', ''))
            else upper(plan_id)
        end as plan_name,
        -- Identifying baseline pricing categories based on absolute value impact
        max(abs(mrr_impact)) as standard_amount
    from staging_events
    group by 1
)

select 
    -- Generating a clean primary key for our dimension table alignment
    md5(plan_id) as plan_key,
    plan_id,
    plan_name,
    standard_amount
from distinct_plans