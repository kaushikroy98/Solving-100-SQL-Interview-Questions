
/* Question 69. Number of happy customers
• Write a query to return the number of happy customers from May 24 (inclusive) to May 31 (inclusive).
Definition
• Happy customer: customers who made at least 1 rental in each day of any 2
Hint
• For customer 1, you can create the following temporary table:
• customer 1, first rental date, second rental date
• customer 1, second rental date, third rental date
• customer 1, second last rental date, last rental date
• customer 1, last rental date, NULL
• As long as there is at least one row, where the delta of the last 2 columns are not null,
and less or equal than 1 day, this customer must be a happy customer.*/


WITH customer_rental_date AS (
SELECT
customer_id,
DATE(rental_ts) AS rental_date
FROM rental
WHERE DATE(rental_ts) >= '2020-05-24'
AND DATE(rental_ts) <= '2020-05-31'
GROUP BY
customer_id,
DATE(rental_ts)
),
customer_rental_date_diff AS (
SELECT
customer_id,
rental_date AS current_rental_date,
LAG( rental_date, 1) OVER(PARTITION BY customer_id ORDER BY
rental_date) AS prev_rental_date
FROM customer_rental_date
)
SELECT COUNT(*) FROM (
SELECT
customer_id,
MIN(current_rental_date - prev_rental_date)
FROM customer_rental_date_diff
GROUP BY customer_id
HAVING MIN(current_rental_date - prev_rental_date) = 1
) X
;





/* Question 71. Cumulative rentals
• Write a query to return the cumulative daily rentals for the following customers:
• customer_id in (3, 4, 5).
• Each day a user had a rental, return their total spent until that day.
• If there is no rental on that day, ignore that day.*/

with rentals as
(
select date(rental_ts) as 'date',
customer_id, count(rental_id) daily_rental
from rental
group by 1,2),

cumulative_rental as (
select date,customer_id,daily_rental,
sum(daily_rental) over(partition by customer_id order by date) as cumulative_rentals
from rentals)

select * from cumulative_rental
where customer_id in (3,4,5);

/* Question 72. Days when they became happy customers
• Any customers who made at least 10 movie rentals are happy customers, write a query to return the dates when the following customers became happy customers:
• customer_id in (1,2,3,4,5,6,7,8,9,10).
• You can skip a customer if he/she never became a ‘happy customer'.*/


with happy_customer as
(
select customer_id,date(rental_ts) as 'date',
row_number() over(partition by customer_id order by rental_ts) row_num
from rental
where customer_id in (1,2,3,4,5,6,7,8,9,10))

select customer_id, date
from happy_customer
where row_num = 10;


/* Question 73. Number of days to become a happy customer
• Any customers who made 10 movie rentals are happy customers
• Write a query to return the average number of days for a customer to make his/her 10th rental.
• If a customer has never become a ‘happy’ customer, you should skip this customer when computing the average.
• You can use EXTRACT(DAYS FROM tenth_rental_ts - first_rental_ts) to get the number of days in between the 1st rental and 10th rental
• Use ROUND(average_days) to return an integer */


with row_nums as
(
select customer_id,date(rental_ts) as 'date',
row_number() over(partition by customer_id order by rental_ts) row_num
from rental),
happy_days as
(
select *,
lead(date,1) over(partition by customer_id) as happy_day
from row_nums
where row_num in (1,10)
),
date_difference as (
select customer_id, datediff(happy_day,date) as date_diff
from happy_days
where happy_day is not null)

select round(avg(date_diff)) 'avg' from date_difference;


/* Question 74. The most productive actors by category
• An actor’s productivity is defined as the number of movies he/she has played.
• Write a query to return the category_id, actor_id and number of moviesby the most productive actor in that category.
• For example: John Doe filmed the most action movies, your query will return John as the result for action movie category.
• Do this for every movie category. */

with cte1 as
(
select fc.category_id category_id,fa.actor_id actor_id, fa.film_id film_id
from film_actor fa
join film f on f.film_id = fa.film_id
join film_category fc on fc.film_id = f.film_id
),
num_movies as
(
select category_id, actor_id,
count(film_id) number_of_movies
from cte1
group by actor_id, category_id
),
rank_num as
(
select *,
row_number() over(partition by category_id order by number_of_movies desc) num_rank
from num_movies)

select category_id, actor_id, number_of_movies
from rank_num
where num_rank =1

/* Question 75. Top customer by movie category
• For each movie category: return the customer id who spend the most in rentals.
• If there are ties, return any customer id.*/

with cust_revenue_by_cat as (
select
p.customer_id customer_id,
fc.category_id category_id,
SUM(p.amount) as revenue
from payment p
join rental r
on r.rental_id = p.rental_id
join inventory I
on I.inventory_id = r.inventory_id
join film f
on f.film_id = I.film_id
join film_category fc
on fc.film_id = f.film_id
group by p.customer_id, fc.category_id
),
rank_num as
(
select *,
row_number() over(partition by category_id order by revenue desc) row_num
from cust_revenue_by_cat)

select  category_id,customer_id
from rank_num
where row_num=1;

/* Question 76. Districts with the most and least customers
• Return the district where the most and least number of customers are.
• Append a column to indicate whether this district has the most customers or least customers with 'most' or 'least' category.
• HINT: it is possible an address is not associated with any customer.*/


with cus_count as
(
select a.district, 
count(distinct c.customer_id) cus_cnt,
row_number() over(order by count(distinct c.customer_id) asc) as cus_asc_id,
row_number() over(order by count(distinct c.customer_id) desc) as cus_desc_id
from address a
left join customer c on a.address_id = c.address_id
group by 1
)

select district, 'most' as city_cat
from cus_count
where cus_desc_id = 1
union
select district, 'lease' as city_cat
from cus_count
where cus_asc_id = 1


/* Question 77. Movie revenue percentiles by category 
 Write a query to return revenue percentiles (ordered ascendingly) of the following movies within their category:
• film_id IN (1,2,3,4,5)*/

with movie_rev_by_cat as (
select
f.film_id,
max(fc.category_id) as category_id,
sum(p.amount) as revenue
from film f
join inventory i on i.film_id = f.film_id
join rental r on r.inventory_id = i.inventory_id
join payment p on p.rental_id = r.rental_id
join  film_category fc on fc.film_id = f.film_id
group by f.film_id
),
percentile as
(
select film_id,
ntile(100) over(partition by category_id order by revenue asc) prct_by_cat
from movie_rev_by_cat
)

select * from percentile
where film_id in (1,2,3,4,5)


/* Question 78. Quartiles buckets by number of rentals
• Write a query to return the quartile by the number of rentals for the following customers:
• customer_id IN (1,2,3,4,5,6,7,8,9,10)*/


with cust_rentals as (
select c.customer_id customer_id,
max(c.store_id) as store_id, 
count(*) as num_rentals from
rental r
join customer c
on c.customer_id = r.customer_id
group by c.customer_id
),
quartile as
(
select customer_id, store_id, 
ntile(4) over(partition by store_id order by num_rentals) as quartile
from cust_rentals
)

select customer_id, store_id,quartile
from quartile
where customer_id in (1,2,3,4,5,6,7,8,9,10)


/* Question 79. Spend difference between the last and the second last rentals
• Write a query to return the spend amount difference between the last and the second
• customer_id IN (1,2,3,4,5,6,7,8,9,10).
last movie rentals for the following customers:
• Skip customers if they made less than 2 rentals.*/

with cte1 as
(
select customer_id,payment_ts , amount,
row_number() over(partition by customer_id order by payment_ts desc) num
from payment
),
cte2 as 
(
select customer_id, payment_ts, amount,num
from cte1
),
cte3 as 
(  
select *,
amount- lead(amount) over(partition by customer_id order by payment_ts desc) delta
from cte2
where num <=2)
  
select * from(
select customer_id, delta
from cte3
where delta is not null) x
where customer_id in (1,2,3,4,5,6,7,8,9,10)


/* Question 80. DoD revenue growth for each store 
• Write a query to return DoD(day over day) growth for each store from May 24 (inclusive) to May 31 (inclusive).
• DoD: (current_day/ prev_day -1) * 100.0
• Multiply dod growth to 100.0 to get percentage of growth.
• Use ROUND to convert dod growth to the nearest integer.*/

with store_daily_rev as (
select
i.store_id,
date(p.payment_ts) date,
sum(amount) as daily_rev
from
payment p join rental r on r.rental_id = p.rental_id
join inventory i on i.inventory_id = r.inventory_id
where date(p.payment_ts) >= '2020-05-01'
and date(p.payment_ts) <= '2020-05-31'
group by i.store_id, date(p.payment_ts)
)

select *,
ifnull(round(daily_rev*100/lag(daily_rev,1) over(partition by store_id order by date)),'') dod_growth
from store_daily_rev;



/* Question 83. Top search_query in US and UK on new year's day
 Write a query to return the top searched term in the US and UK on new year's day
(2021-01-01), separately
• The order of your results doesn't matter.
• Rank them based on search volume. */

select country, query
from (
select
query,
country,
count(distinct user_id),
roq_number() over(partition by country order by count(distinct user_id) desc) as row_num
from search
where country in ('US', 'UK')
and date = '2021-01-01'
group by 1,2
) X
where row_num = 1;


/* Question 88. Top song report
• Write a query to return the top song id for every country
• Return a unique row for each country
• For simplicity, let's assume there is no tie.
• The order of your results doesn't matter.*/

with song_rankings as (
select
p.song_id,
p.country,
row_number() over(partition by country order by num_plays desc) as
ranking
from daily_plays P
where p.date = current_date - 1
)
select
song_id,
country
from song_rankings
where ranking = 1;


/* Question 90. Top artist report
• Write a query to return the top artist id for every country
• Return a unique row for each country
• For simplicity, let's assume there is no tie.
• The order of your results doesn't matter. */

with artist_plays as (
select
S.artist_id,
P.country,
SUM(num_plays) num_plays
from daily_plays P
join song S
on S.song_id = P.song_id
where P.date = current_date - 1
group by 1,2
),
artist_ranking as (
select
artist_id,
country,
row_number() over(partition by country order by num_plays desc) ranking
from artist_plays
)
select country, artist_id
from artist_ranking
where ranking = 1;

/* Question 84. Click through rate on new year's day
• Write a query to compute the click through rate for the search results on new year's day (2021-01-01).
• Click through rate: number of searches end up with at least one click.
• Convert your result into a percentage (* 100.0).*/


SELECT
COUNT(DISTINCT CASE WHEN action = 'click' THEN search_id ELSE NULL END) *
100.0/COUNT(DISTINCT search_id)
FROM search_result
WHERE date = '2021-01-01';

/* Question 85. Top 5 queries based on click through rate on new year's day
• Write a query to return the top 5 search terms with the highest click through rate on new year's day (2021-01-01)
• The search term has to be searched by more than 2 (>2) distinct users.
• Click through rate: number of searches end up with at least one click.*/

WITH click_through_rate AS (
SELECT
S.query,COUNT(DISTINCT CASE WHEN action='click' THEN S.search_id ELSE NULL
END) * 100/COUNT(DISTINCT S.search_id) ctr
FROM
search S
INNER JOIN search_result R
ON S.search_id = R.search_id
WHERE S.date = '2021-01-01'
GROUP BY S.query
HAVING COUNT(DISTINCT S.user_id) > 2
)
SELECT query
FROM click_through_rate
ORDER BY ctr DESC
LIMIT 5;


/* Question 86. Top song in the US
Write a query to return the name of the top song in the US yesterday.*/

SELECT title FROM SONG
WHERE song_id IN (
SELECT d.song_id, s.name, d.plays
FROM daily_plays d
WHERE d.country = 'US'
AND d.date = CURRENT_DATE - 1
ORDER BY plays DESC
LIMIT 1
);


/* Question 89. Top 5 artists in the US
• Write a query to return the top 5 artists id for US yesterday.
• Return a unique row for each country
• For simplicity, let's assume there is no tie.
• The order of your results doesn't matter.*/

WITH artist_plays AS (
SELECT
S.artist_id,
P.country,
SUM(num_plays) num_plays
FROM song_plays P
INNER JOIN song S
ON S.song_id = P.song_id
WHERE P.date = CURRENT_DATE - 1
GROUP BY 1,2
)
SELECT artist_id
FROM artist_plays
ORDER BY num_plays DESC
LIMIT 5;
















