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











































