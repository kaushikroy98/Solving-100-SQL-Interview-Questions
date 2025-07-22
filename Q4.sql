-- Create a ro number by length

select
    film_id,
    title,
    length,
    row_number() over (
        order by
            length desc
    ) row_num
from
    film;
