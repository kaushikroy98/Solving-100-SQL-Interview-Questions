-- Q11. Percentile, decile, quartile by MPAA rating

select title, replacement_cost as cost,rating,

ntile(100) over(partition by rating order by replacement_cost) as percentile,
ntile(10) over(partition by rating order by replacement_cost) as decile,
ntile(4) over(partition by rating order by replacement_cost) as quartile

from film ;
