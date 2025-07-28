/* Question 32. Unpopular movies
• Write a query to return the number of films with no rentals in Feb 2020.
• Count the entire movie catalog from the film table.*/



with rented_film as 
(
  select distinct film_id from inventory
  where inventory_id in
  (select inventory_id from rental where 
  extract(year from rental_ts) = 2020 and extract(month from rental_ts)=2)
)
  
select count(*) as count from film
where film_id not in (select * from rented_film)


/* Question 33. Returning customers 
• Write a query to return the number of customers who rented at least one movie in both May 2020 and June 2020.*/

with may_customer as 
(
  select distinct customer_id from rental
  where extract(year from rental_ts)=2020 and extract(month from rental_ts)=5
)

select count(distinct customer_id) from rental
where extract(year from rental_ts)=2020 and extract(month from rental_ts)=6
and customer_id in (select customer_id from may_customer);


/* Question 34. Stocked up movies
• Write a query to return the titles of movies with more than >7 dvd copies in the inventory.*/

with film_inventory as
(
select film_id, count(inventory_id) count from inventory
group by 1
having count(inventory_id)>7
order by 2 desc
)

select title from film where film_id  in (select film_id from film_inventory )


/* Question 35. Film length report
• Write a query to return the number of films in the following categories: short, medium, and long.
• The order of your results doesn't matter.

Definition
• short: less <60 minutes.
• medium: >=60 minutes, but <100 minutes.
• long: >=100 minutes*/

select 
case
  when length < 60 then 'Short' 
  when length between 60 and 100 then 'Medium'
  when length >=100 then 'Long' 
  else null
end 'film_category',
count(*) 
from film
group by film_category;

/* Question 81. How many people searched on new year's day
Write a query to return the total number of users who have searched on new year's day: 2021-01-01 */

select count(distinct user_id) from search
where date = '2021-01-01';


/* Question 82. The top search query on new year's day
Write a query to return the top search term on new year's day: 2021-01-01 */

select query from (
select query as top_search_term, count(*) from search
WHERE date = '2021-01-01'
group by 1
order by 2 desc
limit 1)

/* Question 36. Actors from film 'AFRICAN EGG'
• Write a query to return the first name and last name of all actors in the film 'AFRICAN EGG'.
• The order of your results doesn't matter.*/

select a.first_name, a.last_name from film f
inner join film_actor fa on f.film_id=fa.film_id
inner join actor a on a.actor_id = fa.actor_id
where title = 'AFRICAN EGG'


/* Question 37. Most popular movie category
• Return the name of the category that has the most films.
• If there are ties, return just one of them.*/

select name from(
select name, c.category_id, count(film_id) from film_category fc
inner join category c on c.category_id = fc.category_id
group by 1
order by 2 desc
limit 1)x;

/* Question 38. Most popular movie category (name and id)
• Write a query to return the name of the most popular film category and its category id
• If there are ties, return just one of them. */


select name, category_id from(
select name, c.category_id as category_id, count(film_id) from film_category fc
inner join category c on c.category_id = fc.category_id
group by 1
order by 2 desc
limit 1)x


/* Question 39. Most productive actor with inner join
• Write a query to return the name of the actor who appears in the most films.
• You have to use INNER JOIN in your query.*/


with productive_actor as
(
select a.actor_id actor_id,first_name, last_name, count(film_id) from film_actor fa
inner join actor a on a.actor_id = fa.actor_id
group by 1,2,3
order by 4 desc
)

select actor_id,first_name, last_name from productive_actor;

/* Question 40. Top 5 most rented movie in June 2020
• Write a query to return the film_id and title of the top 5 movies that were rented the most times in June 2020
• Use the rental_ts column from the rental for the transaction time.
• The order of your results doesn't matter.
• If there are ties, return any 5 of them.*/


with most_rented as
(
select f.film_id film_id, f.title title, count(rental_id) from rental r
join inventory i on r.inventory_id = i.inventory_id
join film f on f.film_id = i.film_id
where extract(year from r.rental_ts)=2020 and extract(month from rental_ts)=6
group by 1,2
order by 3 desc
limit 5
)
  
select film_id, title from most_rented

/* Question 41. Productive actors vs less-productive actors
• Write a query to return the number of productive and less-productive actors.
• The order of your results doesn't matter.*/


with film_count as 
(
select actor_id, count(*) as cnt from film_actor
group by 1
order by 2 desc),

productive as (
select
case
when cnt >= 30 then 'productive'
else 'less-productive'
end as actor_category
from film_count
)
 
 select actor_category, count(*) count from productive
 group by 1
 order by 3 desc;


/* Question 42. Films that are in stock vs not in stock
• Write a query to return the number of films that we have inventory vs no inventory.
• A film can have multiple inventory ids
• Each film dvd copy has a unique inventory ids*/


with stock as
(
select f.film_id, count(i.inventory_id) cnt from film f
left join inventory i on f.film_id = i.film_id
group by 1
)

select case when cnt=0 then 'not in stock'
else 'in stock'
end as in_stock, count(*) as count 
from stock
group by 1

/* Question 43. Customers who rented vs. those who did not 
• Write a query to return the number of customers who rented at least one movie vs. those who didn't in May 2020.
• The order of your results doesn't matter.
• Use customer table as the base table for all customers (assuming all customers have signed up before May 2020)
• Rented: if a customer rented at least one movie.*/


with rented_in_may as (

select distinct customer_id from rental 
where extract(year from rental_ts)=2020 and extract(month from rental_ts) = 5
)

select 
case
when r.customer_id is not null then 'rented'
else 'not rented'
end as has_rented,
count(*) as count
from customer c
left join rented_in_may r on r.customer_id = c.customer_id
group by has_rented;


/* Question 44. In-demand vs not-in-demand movies
• Write a query to return the number of in demand and not in demand movies in May 2020.
• Assumptions (great to clarify in your interview): all films are available for rent before May.
• But if a film is not in stock, it is not in demand.
• The order of your results doesn't matter. */


with may_rentals as 
(
select
    i.film_id,
    count(*) as cnt
  from rental   r
  join inventory i on r.inventory_id = i.inventory_id
  where r.rental_ts >= '2020-05-01'
    and r.rental_ts <  '2020-06-01'
  group by i.film_id)


select 
case
when cnt>1 then 'in-demad'
else 'not-in-demand'
end demand_category,
count(*) count
from film f
left join may_rentals m on m.film_id = f.film_id
group by 1;


/* Question 45. Movie inventory optimization
• For movies that are not in demand (rentals = 0 in May 2020), we want to remove them from our inventory.
• Write a query to return the number of unique inventory_id from those movies with 0 demand.
• Hint: a movie can have multiple inventory_id.*/
  


select count(*)
from inventory inv
where inv.film_id not in 
(
select distinct i.film_id from inventory i
join rental r on i.inventory_id = r.inventory_id
where extract(year from rental_ts)=2020 and 
extract(month from rental_ts) = 5);


/* Question 46. Actors and customers whose last name starts with 'A'
• Write a query to return unique names (first_name, last_name) of
our customers and actors whose last name starts with letter 'A'.*/

with last_name_A as
(
select first_name, last_name from customer
union 
select first_name, last_name from actor)

select distinct first_name, last_name from last_name_A
where last_name like 'A%'





















