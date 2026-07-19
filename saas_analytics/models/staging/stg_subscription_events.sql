with source as (
    select * from {{source('main','fact_subscription_events')}}
)
select 
    event_id,
    customer_id,
    plan_id,
    case
        when event_type ='r' then 'renewal'
        else event_type
        end as event_type,
        cast(event_date as date) as event_date,
        cast(mrr_impact as decimal(10,2)) as mrr_impact
from source