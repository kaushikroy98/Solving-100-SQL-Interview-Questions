-- Q1 : Compare each films dvd's replacement cost to the average cost in the same MPAA rating

select title, rating, replacement_cost ,
round(avg(replacement_cost) over(partition by rating),2) as avg_cost
from film;
