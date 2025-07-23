/* Question 16. Staff who live in Woodridge
• Write a query to return the names of the staff who live in the city of 'Woodridge'*/

select 
  name
from staff_list
where city = 'Woodridge';

/* Question 17. GROUCHO WILLIAMS’ actor_id
• Write a query to return GROUCHO WILLIAMS' actor_id.
• Actor's first_name and last_name are all stored as UPPER case in our database, and the database is case sensitive.*/

select 
  actor_id
from actor
where concat(first_name,' ',last_name)='GROUCHO WILLIAMS';

/* Question 18. Top film category
• Write a query to return the film category id with the most films, as well as the number
films in that category.*/

select 
  category_id, count(film_id) 
from film_category
group by 1
order by 2 desc;

/* Question 19. Most productive actor
• Write a query to return the first name and the last name of the actor who appeared in the most films.*/

select 
  first_name, last_name 
from
  (
  select 
    first_name, last_name,count(film_id) film_count 
  from film_actor fa
  join actor a on fa.actor_id=a.actor_id
  group by 1,2
  order by 3 desc
  limit 1) a;

/* Question 20. Customer who spent the most
• Write a query to return the first and last name of the customer who spent the most on movie rentals in Feb 2020.*/

select first_name,last_name
from 
  (
  select 
    c.customer_id,first_name, last_name, sum(amount) amount
  from payment p
  join customer c on p.customer_id = c.customer_id
  where 
    extract(year from payment_ts) = 2020 and 
    extract(month from payment_ts) = 2
  group by 1,2,3
  order by 4 desc
  limit 1) a;

/* Question 21. Customer who rented the most
• Write a query to return the first and last name of the customer who made the most rental transactions in May 2020.*/

select 
  first_name, last_name 
from
(
  select 
    first_name, last_name, count(rental_id) 
  from rental r
  inner join customer c on c.customer_id = r.customer_id
  where extract(year from rental_ts) = 2020 and
        extract(month from rental_ts) = 5
  group by 1,2
  order by 3 desc
  limit 1) a;

/* Question 22. Average cost per rental transaction
• Write a query to return the average cost on movie rentals in May 2020 per transaction.*/


select 
  avg(amount) 
from payment
where extract(year from payment_ts) = 2020 and
      extract(month from payment_ts) = 5;

/* Question 23. Average spend per customer in Feb 2020
• Write a query to return the average movie rental spend per customer in Feb 2020.*/

with customer_avg_spend as
(
  select customer_id,avg(amount) avg_spend 
  from payment
  where extract(year from payment_ts) = 2020 and
        extract(month from payment_ts) = 2
  group by 1
  order by 2 desc
 )
 
 select avg_spend 
 from customer_avg_spend;

/* Question 24. Films with more than 10 actors 
• Write a query to return the titles of the films with >= 10 actors.*/

with actors_count_per_film as
 (
  select 
    title, count(actor_id) count
  from film_actor fa
  join film f on f.film_id = fa.film_id
  group by 1
  having count(actor_id)>=10
  order by 2 desc
)

select title
from actors_count_per_film ;

/* Question 25. Shortest film
• Write a query to return the title of the film with the minimum duration.
• A movie's duration can be found using the length column.
• If there are ties, e.g., two movies have the same length, return either one of them.*/

select 
  title 
from film
order by length desc
limit 1;

/* Question 26. Second shortest film
• Write a query to return the title of the film with the minimum duration.
• A movie's duration can be found using the length column.
• If there are ties, e.g., two movies have the same length, return either one of them.*/

with second_shortest as
(
  select 
    title, length,
    rank() over(order by length) as rank_num
  from film
  order by length 
)

select 
  title 
from second_shortest
where rank_num = 2;

/* Question 27. Film with the largest cast
• Write a query to return the title of the film with the largest cast (most actors).
• If there are ties, return just one of them. */

with largest_cast as 
(
  select 
    title, 
    count(actor_id) 
  from film_actor fc
  inner join film f on f.film_id = fc.film_id
  group by 1
  order by 2 desc
  limit 1
)

select 
  title 
from largest_cast;

/* Question 28. Film with the second largest cast 
• Write a query to return the title of the film with the second largest cast.
• If there are ties, e.g., two movies have the same number of actors, return either one of the movie.*/




















































