

/* Question 71. Cumulative rentals
• Write a query to return the cumulative daily rentals for the following customers:
• customer_id in (3, 4, 5).
• Each day a user had a rental, return their total spent until that day.
• If there is no rental on that day, ignore that day.*/

with rentals as
(
select date(rental_ts) as 'date',
customer_id, count(rental_id) daily_rental
from rental
group by 1,2),

cumulative_rental as (
select date,customer_id,daily_rental,
sum(daily_rental) over(partition by customer_id order by date) as cumulative_rentals
from rentals)

select * from cumulative_rental
where customer_id in (3,4,5);

/* Question 72. Days when they became happy customers
• Any customers who made at least 10 movie rentals are happy customers, write a query to return the dates when the following customers became happy customers:
• customer_id in (1,2,3,4,5,6,7,8,9,10).
• You can skip a customer if he/she never became a ‘happy customer'.*/


with happy_customer as
(
select customer_id,date(rental_ts) as 'date',
row_number() over(partition by customer_id order by rental_ts) row_num
from rental
where customer_id in (1,2,3,4,5,6,7,8,9,10))

select customer_id, date
from happy_customer
where row_num = 10;


/* Question 73. Number of days to become a happy customer
• Any customers who made 10 movie rentals are happy customers
• Write a query to return the average number of days for a customer to make his/her 10th rental.
• If a customer has never become a ‘happy’ customer, you should skip this customer when computing the average.
• You can use EXTRACT(DAYS FROM tenth_rental_ts - first_rental_ts) to get the number of days in between the 1st rental and 10th rental
• Use ROUND(average_days) to return an integer */


with row_nums as
(
select customer_id,date(rental_ts) as 'date',
row_number() over(partition by customer_id order by rental_ts) row_num
from rental),
happy_days as
(
select *,
lead(date,1) over(partition by customer_id) as happy_day
from row_nums
where row_num in (1,10)
),
date_difference as (
select customer_id, datediff(happy_day,date) as date_diff
from happy_days
where happy_day is not null)

select round(avg(date_diff)) 'avg' from date_difference;














