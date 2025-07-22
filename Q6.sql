-- Q6. Creat a ranking index by length

select
    film_id,
    title,
    length,
    rank() over (
        order by
            length desc
    ) as ranking
from
    film;
