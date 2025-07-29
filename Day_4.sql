/* Question 50. Top 5 cities for movie rentals 
• Write a query to return the names of the top 5 cities with the most rental revenues in 2020.
• Include each city's revenue in the second column.
• The order of your results doesn't matter.
• If there are ties, return any one of them.
• Yours results should have exactly 5 rows.*/


select c.city,sum(p.amount) from payment p
join customer cus on cus.customer_id = p.customer_id
join address a on a.address_id = cus.address_id
join city c on c.city_id = a.city_id
group by 1
order by 2 desc
limit 5


/* Question 51. Movie only actor
• Write a query to return the first name and last name of actors who only appeared in movies.
• Actor appeared in tv should not be included .
• The order of your results doesn't matter. */

select first_name, last_name from actor_movie
where actor_id not in (select actor_id from actor_tv);

/* Question 52. Movies cast by movie only actors
• Write a query to return the film_id with movie only casts (actors who never appeared in tv).
• The order of your results doesn't matter.
• You should exclude movies with one or more tv actors*/


select f.film_id from film f
where film_id not in (
select fa.film_id from actor_tv act
join film_actor fa on fa.actor_id = act.actor_id)
order by film_id;

/* Question 53. Movie groups by rental income
• Write a query to return the number of films in 3 separate groups: high, medium, low.
• The order of your results doesn't matter.
• high: revenue >= $100.
• medium: revenue >= $20, <$100 .
• low: revenue <$20.*/

with revenue_by_film as
(
select f.film_id, sum(p.amount) rev from film f
left join inventory i on i.film_id = f.film_id
left join rental r on r.inventory_id = i.inventory_id
left join payment p on p.rental_id = r.rental_id
group by 1
 )
 
 select 
 case
 when rev >=100 then 'high'
 when rev >=20 then 'medium'
 else 'low'
 end film_group,
 count(*) count
 from revenue_by_film
 group by 1;


/* Question 54. Customer groups by movie rental spend
• Write a query to return the number of customers in 3 separate groups: high, medium,low.
• The order of your results doesn't matter. 
• high: movie rental spend >= $150.
• medium: movie rental spend >= $100, <$150.
• low: movie rental spend <$100.

Hint
• If a customer spend 0 in movie rentals, he/she belongs to the low group.*/

with rev_by_customer as
(
select c.customer_id, sum(p.amount) rev from customer c
left join payment p on p.customer_id = c.customer_id
group by 1
)

select
case
when rev >=150 then 'high'
when rev >= 100 then 'medium'
else 'low'
end customer_group,
count(*) count
from rev_by_customer
group by 1;


/* Question 55. Busy days and slow days
• Write a query to return the number of busy days and slow days in May 2020 based on the number of movie rentals.
• The order of your results doesn't matter.
• If there are ties, return just one of them. 
• busy: rentals >= 100.
• slow: rentals < 100.*/ 

with rental_count as
(
select d.date, count(r.rental_id) cnt from dates d
left join rental r on date(r.rental_ts) = d.date
where d.date >= '2020-05-01' and d.date <= '2020-05-31'
group by 1
)

select
case
when cnt >= 100 then 'busy'
else 'slow'
end date_category,
count(*) count
from rental_count
group by 1;

/* Question 56. Total number of actors
• Write a query to return the total number of actors from actor_tv, actor_movie with FULL OUTER JOIN.
• Use COALESCE to return the first non-null value from a list.
• Actors who appear in both tv and movie share the same value of actor_id in both
actor_tv and actor_movie tables. */

SELECT
  COUNT(COALESCE(am.actor_id, at.actor_id)) AS count
FROM actor_movie AS am
FULL OUTER JOIN actor_tv AS at
  ON am.actor_id = at.actor_id;






/* Question 57. Total number of actors 
• Write a query to return the total number of actors using UNION.
• Actor who appeared in both tv and movie has the same value of actor_id in both
actor_tv and actor_movie tables.*/

with actors as
(
select actor_id from actor_movie
union
select actor_id from actor_tv
)

select count(distinct actor_id) as 'count' from  actors;


/* Question 58. Percentage of revenue per movie 
• Write a query to return the percentage of revenue for each of the following films: film_id <= 10.
• Formula: revenue (film_id x) * 100.0/ revenue of all movies.
• The order of your results doesn't matter. */

with revenue_by_film as
(
select f.film_id, sum(p.amount) revenue from film f
left join inventory i on f.film_id = i.film_id
left join rental r on r.inventory_id = i.inventory_id
left join payment p on p.rental_id = r.rental_id
group by 1
order by 1
)

select film_id,
round(revenue*100/(sum(revenue) over()),2) as revenue_perct 
from revenue_by_film
limit 10;


/* Question 59. Percentage of revenue per movie by category
• Write a query to return the percentage of revenue for each of the following films: film_id <= 10 by its category.
• Formula: revenue (film_id x) * 100.0/ revenue of all movies in the same category.
• The order of your results doesn't matter.
• Return 3 columns: film_id, category name, and percentage. */

with revenue_film as
(
select f.film_id,c.name as category_name, sum(p.amount) revenue from film f
left join inventory i on f.film_id = i.film_id
left join rental r on r.inventory_id = i.inventory_id
left join payment p on p.rental_id = r.rental_id
left join film_category fc on fc.film_id = f.film_id
left join category c on c.category_id = fc.category_id
group by 1,2
order by 1,2
)

select film_id, category_name,
revenue*100/sum(revenue) over(partition by category_name) as rev_prct
from revenue_film
order by film_id
limit 10;


/* Question 60. Movie rentals and average rentals in the same category
• Write a query to return the number of rentals per movie, and the average number of rentals in its same category.
• You only need to return results for film_id <= 10.
• Return 4 columns: film_id, category name, number of rentals, and the average number
of rentals from its category.*/

with rentals_category as
(
select f.film_id film_id,c.name as category_name, count(r.rental_id) rentals
from film f
join inventory i on f.film_id = i.film_id
join rental r on r.inventory_id = i.inventory_id
join film_category fc on fc.film_id = f.film_id
join category c on c.category_id = fc.category_id
group by 1

 )
 
 select *, avg(rentals) over(partition by category_name) as avg_rentals_category
 from rentals_category
 where film_id<=10;


/* Question 61. Customer spend vs average spend in the same store
• Write a query to return a customer's life time value for the following: customer_id IN (1, 100, 101, 200, 201, 300, 301, 400, 401, 500).
• Add a column to compute the average LTV of all customers from the same store.
• Return 4 columns: customer_id, store_id, customer total spend, average customer
• The order of your results doesn't matter.

Hint

• Assumptions: a customer can only be associated with one store.*/

with ltv_spend as
(
select c.customer_id customer_id, c.store_id store_id, 
 sum(p.amount) ltd_spend from customer c
left join payment p on c.customer_id = p.customer_id
where c.customer_id in (1, 100, 101, 200, 201, 300, 301, 400, 401, 500)
group by 1)

select *,
avg(ltd_spend) over(partition by store_id) as avg
from ltv_spend;

/* Question 62. Shortest film by category 
• Write a query to return the shortest movie from each category.
• The order of your results doesn't matter.
• If there are ties, return just one of them.
• Return the following columns: film_id, title, length, category, row_num*/

with films as
(
select f.film_id film_id, f.title title, f.length length, c.name category from film f
inner join film_category fc on f.film_id = fc.film_id
inner join category c on c.category_id = fc.category_id
),
shortest_film as
(
select *,
row_number() over(partition by category order by length) as row_num
from films)

select * from shortest_film
where row_num = 1;


/* Question 63. Top 5 customers by store
• Write a query to return the top 5 customer ids and their rankings based on their spend for each store.
• The order of your results doesn't matter.
• If there are ties, return just one of them.*/

with revenue as
(
select c.store_id store_id, c.customer_id customer_id, sum(p.amount) revenue from customer c
join payment p on p.customer_id = c.customer_id
group by 1,2),

ranks as(
select *,
dense_rank() over(partition by store_id order by revenue desc) rank_num
from revenue
)

select * from ranks
where rank_num in (1,2,3,4,5)


/* Question 64. Top 2 films by category
• Write a query to return top 2 films based on their rental revenues in their category.
• A film can only belong to one category.
• The order of your results doesn't matter.
• If there are ties, return just one of them.
• Return the following columns: category, film_id, revenue, row_num */


with film_revenue as
(
select f.film_id film_id, c.name category, sum(p.amount) revenue
from payment p
join rental r on p.rental_id = r.rental_id
join inventory i on i.inventory_id = r.inventory_id
join film f on f.film_id = i.film_id
join film_category fc on fc.film_id = f.film_id
join category c on c.category_id = fc.category_id
group by 1
)

select * from (
select category, film_id, revenue,
row_number() over(partition by category order by revenue desc) row_num
from film_revenue) x
where row_num <=2


/* Question 65. Movie revenue percentiles
• Write a query to return percentile distribution for the following movies by their total rental revenues in the entire movie catalog.
• film_id IN (1,10,11,20,21,30).
• A film can only belong to one category.
• The order of your results doesn't matter.
• Return the following columns: film_id, revenue, percentile*/


-- Solution 1

with film_percentile as
(
select f.film_id film_id, sum(p.amount) revenue
from payment p
join rental r on p.rental_id = r.rental_id
join inventory i on i.inventory_id = r.inventory_id
join film f on f.film_id = i.film_id
group by 1)

select * from (
select film_id, revenue,
ntile(100) over(order by revenue) as percentile
from film_percentile) x
where film_id in (1,10,11,20,21,30);


--Solution 2

with film_revenue as
(
select f.film_id film_id, sum(p.amount) revenue
from payment p
join rental r on p.rental_id = r.rental_id
join inventory i on i.inventory_id = r.inventory_id
join film f on f.film_id = i.film_id
group by 1),
percentile as (
select film_id, revenue,
ntile(100) over(order by revenue) as percentile
from film_revenue) 

select * from percentile
where film_id in (1,10,11,20,21,30);



/* Question 66. Movie percentiles by revenue by category
• Write a query to generate percentile distribution for the following movies by their total rental revenue in their category.
• film_id <= 20.
• Use NTILE(100) to create percentile.
• The order of your results doesn't matter.
• Return the following columns: category, film_id, revenue, percentile */

with film_revenue as
(
select c.name category, f.film_id film_id, sum(p.amount) revenue
from payment p
join rental r on p.rental_id = r.rental_id
join inventory i on i.inventory_id = r.inventory_id
join film f on f.film_id = i.film_id
join film_category fc on fc.film_id = f.film_id
join category c on c.category_id = fc.category_id
group by 2),

percentile as (
select category,film_id, revenue,
ntile(100) over(partition by category order by revenue) as percentile
from film_revenue) 

select * from percentile
where film_id <= 20;

/* Question 67. Quartile by number of rentals
• Write a query to return quartiles for the following movies by number of rentals among all movies.
• film_id IN (1,10,11,20,21,30).
• Use NTILE(4) to create quartile buckets.
• The order of your results doesn't matter.
• Return the following columns: film_id, number of rentals, quartile. */


with rental_cnt as
(
select f.film_id film_id, count(r.rental_id) num_rentals,
ntile(4) over(order by count(r.rental_id)) as quartile
from rental r
join inventory i on i.inventory_id = r.inventory_id
join film f on f.film_id = i.film_id
group by 1)

select * from rental_cnt
where film_id in (1,10,11,20,21,30);


/* Question 68. Spend difference between first and second rentals
• Write a query to return the difference of the spend amount between the following customers' first movie rental and their second rental.
• customer_id in (1, 2, 3, 4, 5, 6, 7, 8, 9, 10).
• Use first spend - second spend to compute the difference.
• Skip users who only rented once.
Hint:
• You can use ROW_NUMBER to identify the first and second transactions.
• You can use LAG or LEAD to find previous or following transaction amount. */

with ranks as (
select customer_id, amount,
row_number() over(partition by customer_id order by payment_ts) as rank_num
from payment
),
first_2_spends as(
select * from ranks
where rank_num <=2
),
check1 as (
select *,
 lead(amount) over(partition by customer_id) as second_spend
from first_2_spends)

select customer_id, amount-second_spend as delta
from check1
where rank_num = 1
limit 10

/* Question 70. Cumulative spend
• Write a query to return the cumulative daily spend for the following customers:
• customer_id in (1, 2, 3).
• Each day a user has a rental, return their total spent until that day.
• If there is no rental on that day, you can skip that day.*/

with daily_spend as
(
select date(payment_ts) as 'date',customer_id, sum(amount) daily_spends 
from payment
where customer_id in (1,2,3)
group by 1,2
order by 1)

select *, 
sum(daily_spends) over(partition by customer_id order by date) as cumulative_spend
from daily_spend;
































