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



 
























