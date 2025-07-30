

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












