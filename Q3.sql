-- Q3: Overall progress for binge watching all films

select
    film_id,
    title,
    length,
    sum(length) over (
        order by
            film_id
    ) as running_total,
    sum(length) over () as overall,
    round(
        sum(length) over (
            order by
                film_id
        ) * 100 / sum(length) over (),
        2
    ) running_percent
from
    film;
