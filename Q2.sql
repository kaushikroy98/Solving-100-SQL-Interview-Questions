-- Q2: Compare each films length to the longest film in it's category

select
    title,
    name as category,
    length,
    max(length) over (
        partition by
            name
    ) as max_length
from
    film f
    inner join film_category fc on f.film_id = fc.film_id
    inner join category c on fc.category_id = c.category_id;
