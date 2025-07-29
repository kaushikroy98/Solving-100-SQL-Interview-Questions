

-- Q1 : Compare each films dvd's replacement cost to the average cost in the same MPAA rating

select title, rating, replacement_cost ,
round(avg(replacement_cost) over(partition by rating),2) as avg_cost
from film;

-- Q2: Compare each films length to the longest film in it's category

select
    title,
    name as category,
    length,
    max(length) over (
        partition by
            name
    ) as max_length
from
    film f
    inner join film_category fc on f.film_id = fc.film_id
    inner join category c on fc.category_id = c.category_id;

-- Q3: Overall progress for binge watching all films

select
    film_id,
    title,
    length,
    sum(length) over (
        order by
            film_id
    ) as running_total,
    sum(length) over () as overall,
    round(
        sum(length) over (
            order by
                film_id
        ) * 100 / sum(length) over (),
        2
    ) running_percent
from
    film;


-- Q4: Create a row number by length

select
    film_id,
    title,
    length,
    row_number() over (
        order by
            length desc
    ) row_num
from
    film;


-- Q5 Create a row_number by length in category

select
    f.film_id,
    title,
    name as category,
    length,
    row_number() over (
        partition by
            name
        order by
            length desc
    ) as row_num
from
    film f
    inner join film_category fc on f.film_id = fc.film_id
    inner join category c on fc.category_id = c.category_id;


-- Q6. Creat a ranking index by length

select
    film_id,
    title,
    length,
    rank() over (
        order by
            length desc
    ) as ranking
from
    film;


--Q7 Creat a ranking index by length in a category

select
    f.film_id,
    title,
    name as category,
    length,
    rank() over (
        partition by
            name
        order by
            length desc
    ) as rank_num
from
    film f
    inner join film_category fc on f.film_id = fc.film_id
    inner join category c on fc.category_id = c.category_id;


-- Q8. Creat a dense ranking index by length in category

select
    f.film_id,
    title,
    name as category,
    length,
    dense_rank() over (
        partition by
            name
        order by
            length desc
    ) as denserank_num
from
    film f
    inner join film_category fc on f.film_id = fc.film_id
    inner join category c on fc.category_id = c.category_id;


-- Q10. Percentile by length

select
    film_id,
    title,
    length,
    ntile (100) over (
        order by
            length desc
    ) as percentile
from
    film;


-- Q11. Percentile, decile, quartile by MPAA rating

select title, replacement_cost as cost,rating,

ntile(100) over(partition by rating order by replacement_cost) as percentile,
ntile(10) over(partition by rating order by replacement_cost) as decile,
ntile(4) over(partition by rating order by replacement_cost) as quartile

from film ;


-- Q12. Previous day's revenue

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
    lag (revenue, 1) over (
        order by
            date
    ) as previou_day_sale,
    round(
        revenue * 100 / lag (revenue, 1) over (
            order by
                date
        )
    ) as dod_per
from
    daily_revenue;



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
