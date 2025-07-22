-- Q13. Next day's revenue

with
    daily_revenue as (
        select
            date (payment_ts) as date,
            sum(amount) as revenue
        from
            payment
        where
            date (payment_ts) >= '2020-05-24'
            and date (payment_ts) <= '2020-05-31'
        group by
            date (payment_ts)
    )
select
    date,
    revenue,
    lead (revenue, 1) over (
        order by
            date
    ) as next_day_sale,
    round(
        lead (revenue, 1) over (
            order by
                date
        ) * 100 / revenue
    ) as dod_per
from
    daily_revenue;
