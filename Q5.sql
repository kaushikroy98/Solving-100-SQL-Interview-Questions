-- Q5 Create a row_number by length in category

select
    f.film_id,
    title,
    name as category,
    length,
    row_number() over (
        partition by
            name
        order by
            length desc
    ) as row_num
from
    film f
    inner join film_category fc on f.film_id = fc.film_id
    inner join category c on fc.category_id = c.category_id;
