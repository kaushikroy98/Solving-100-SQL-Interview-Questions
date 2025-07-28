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
















