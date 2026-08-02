# SaaS Executive Dashboard 🚀

### Monthly Recurring Revenue (MRR) Breakdown

```sql mrr_by_plan
select 
    plan_name,
    sum(mrr) as total_mrr
from saas_analytics.fct_subscriptions
group by 1
order by total_mrr desc
```

<BarChart 
    data={mrr_by_plan} 
    x=plan_name 
    y=total_mrr 
    title="MRR Breakdown by Plan ($)"
    fmt="usd"
/>

<DataTable data={mrr_by_plan}>
    <Column id=plan_name title="Plan Name" />
    <Column id=total_mrr title="Total MRR" fmt="usd" />
</DataTable>