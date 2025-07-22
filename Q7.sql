--Q7 Creat a ranking index by length in a category

select
    f.film_id,
    title,
    name as category,
    length,
    rank() over (
        partition by
            name
        order by
            length desc
    ) as rank_num
from
    film f
    inner join film_category fc on f.film_id = fc.film_id
    inner join category c on fc.category_id = c.category_id;
