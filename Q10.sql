-- Q10. Percentile by length

select
    film_id,
    title,
    length,
    ntile (100) over (
        order by
            length desc
    ) as percentile
from
    film;
