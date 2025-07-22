/* Question 1. Top store for movie sale
Write a query to return the name of the store and its manager, that generated the most sales.*/

select store, manager 
from sales_by_store
order by total_sales desc
limit 1;


/* Question 2. Top 3 movie categories by sales
Write a query to find the top 3 film categories that generated the most sales. The order of your results doesn't matter.*/

select category 
from sales_by_film_category
order by total_sales desc
limit 3;


/*Question 3. Top 5 shortest movies
Write a query to return the titles of the 5 shortest movies by duration. The order of your results doesn't matter.*/

select title 
from film
order by length
limit 5;


/* Question 4. Staff without a profile image

• Write a SQL query to return this staff's first name and last name.
• Picture field contains the link that points to a staff's profile image.
• There is only one staff who doesn't have a profile picture.
• Use colname IS NULL to identify data that are missing.*/

select first_name, last_name 
from staff
where picture is null;


/* Question 5. Monthly revenue

• Write a query to return the total movie rental revenue for each month.
• You can use EXTRACT(MONTH FROM colname) and EXTRACT(YEAR FROM colname) to extract month and year from a timestamp column.*/

select 
  extract(year from payment_ts), 
  extract(month from payment_ts), sum(amount) as revnue
from payment
group by 1,2
order by 1,2;


/* Question 5. Daily revenue in June, 2020

• Write a query to return daily revenue in June, 2020.
• Use DATE(colname) to extract the date from a timestamp column.
• payment_ts's data type is timestamp, convert it to date before grouping.
• No dates need to be included if there was no revenue on that day.*/

select 
  date(payment_ts) payment_date,
  sum(amount) as daily_revenue
from payment 
where 
extract(year from payment_ts)= 2020 
and extract(month from payment_ts)= 6
group by 1
order by 1;


/* Question 7. Unique customers count by month

• Write a query to return the total number of unique customers for each month
• Use EXTRACT(YEAR from ts_field) and EXTRACT(MONTH from ts_field) to get year and month from a timestamp column.
• The order of your results doesn't matter.*/

select 
  extract(year from rental_ts) as year,
  extract(month from rental_ts ) as month, 
  count(distinct customer_id) as unique_customer
from rental
group by 1,2;


/* Question 8. Average customer spend by month

• Write a query to return the average customer spend by month.
• Definition: average customer spend: total customer spend divided by the unique number of customers for that month.
• Use EXTRACT(YEAR from ts_field) and EXTRACT(MONTH from ts_field) to get year and month from a timestamp column.
• The order of your results doesn't matter. */

select 
  extract(year from payment_ts) year,
  extract(month from payment_ts) month,
  sum(amount)/count(distinct customer_id) avg_spend
from payment
group by 1,2
order by 1,2;


/* Question 9. Number of high spend customers by month

• Write a query to count the number of customers who spend more than (>) $20 by month
• Use EXTRACT(YEAR from ts_field) and EXTRACT(MONTH from ts_field) to get year and month from a timestamp column.
• The order of your results doesn't matter.
• Hint: a customer's spend varies every month*/

with customer_spend as
(
  select customer_id,
  extract(year from payment_ts) year, 
  extract(month from payment_ts) month,
  sum(amount) as spend_amount
from payment
group by 1,2,3
having sum(amount)>20) 
  
select year, month,count(*) from customer_spend
group by 1,2;


/* Question 10. Min and max spend 

• Write a query to return the minimum and maximum customer total spend in June 2020.
• For each customer, first calculate their total spend in June 2020.
• Then use MIN, and MAX function to return the min and max customer spend. */


with customer_spend as
(
select customer_id, sum(amount) spend from payment
where extract(year from payment_ts) =2020
and extract(month from payment_ts) = 6
group by 1)

select 
  min(spend) as min_spend,
  max(spend) as max_spend 
from customer_spend;


/* Question 11. Actors' last name

Find the number of actors whose last name is one of the following: 'DAVIS', 'BRODY','ALLEN', 'BERRY'*/

select 
  last_name, count(*) 
from actor
where last_name in ('DAVIS', 'BRODY','ALLEN', 'BERRY')
group by 1;


/* Question 12. Actors' last name ending in 'EN' or 'RY'

• Identify all actors whose last name ends in 'EN' or 'RY'.
• Group and count them by their last name.*/

select 
  last_name, 
  count(last_name) count 
from actor
where last_name like '%EN' or last_name like '%RY'
group by 1
order by count desc;


/* Question 13. Actors' first name

• Write a query to return the number of actors whose first name starts with 'A', 'B', 'C', or others.
• The order of your results doesn't matter.
• You need to return 2 columns:
• The first column is the group of actors based on the first letter of their first_name, use the following: 'a_actors', 'b_actors', 'c_actors', 'other_actors' to represent their groups.
• Second column is the number of actors whose first name matches the pattern.*/

with actors as
(
select 
case 
    when first_name like 'A%' then 'a_actors'
    when first_name like 'B%' then 'b_actors'
    when first_name like 'C%' then 'c_actors'
  else 'other_actors'
end actor_category
from actor) 

select actor_category, count(*) count
from actors
group by 1
order by actor_category;


/* Question 14. Good days and bad days

• Write a query to return the number of good days and bad days in May 2020 based on number of daily rentals.
• Return the results in one row with 2 columns from left to right: good_days, bad_days.
• good day: > 100 rentals.
• bad day: <= 100 rentals.
• Hint (For users already know OUTER JOIN), you can use dates table
• Hint: be super careful about datetime columns.
• Hint: this problem could be tricky, feel free to explore the rental table and take a look at some data.*/

with rental_counts as
(
select 
  date(rental_ts) day,
  count(rental_ts) as rental_count
from rental
    where extract(year from rental_ts)= 2020 and 
          extract(month from rental_ts) = 5
group by 1)

select 
  sum(case when rental_count > 100 then  1 else 0 end) as good_days,
  sum(case when rental_count <= 100 then  1 else 0 end) as good_days
from rental_counts;

/* Question 15. Fast movie watchers vs slow watchers

• Write a query to return the number of fast movie watchers vs slow movie watchers.
• fast movie watcher: by average return their rentals within 5 days.
• slow movie watcher: takes an average of >5 days to return their rentals.
• Most customers have multiple rentals over time, you need to first compute the number of days for each rental transaction, then compute the average on the rounded up days.
  e.g., if the rental period is 1 day and 10 hours, count it as 2 days.
• Skip the rentals that have not been returned yet, e.g., rental_ts IS NULL.
• The orders of your results doesn't matter.
• A customer can only rent one movie per transaction.*/ 

-- Solution 1
 
with rental_days as
(
  select customer_id,
  /* Since TIMESTAMPDIFF rounds down (i.e., doesn’t include partial days), we add +1 to round up and follow the problem's requirement.
    If someone rented at 10 AM and returned the next day at 9 AM: TIMESTAMPDIFF = 0 days → +1 = 1 day
    If rented at 10 AM and returned the next day at 11 AM: TIMESTAMPDIFF = 1 day → +1 = 2 days */
        TIMESTAMPDIFF(day,rental_ts,return_ts)+1 as rental_duration_days  
  from rental
  where return_ts is not null and rental_ts is not null),

  customer_avg as (

  select customer_id, avg(rental_duration_days) as avg_days
  from rental_days
  group by customer_id

)

select 
  sum(case when avg_days <= 5 then 1 else 0 end) as fast_watchers,
  sum(case when avg_days > 5 then 1 else 0 end) as slow_watchers
from customer_avg;

-- Solution 2

with rental_days as
(

  select customer_id,
    avg(TIMESTAMPDIFF(day,rental_ts,return_ts)+1) as avg_rental_days
  from rental
  where return_ts is not null and rental_ts is not null
  group by customer_id
)

select 
  sum(case when avg_rental_days <= 5 then 1 else 0 end) as fast_watchers,
  sum(case when avg_rental_days > 5 then 1 else 0 end) as slow_watchers
from rental_days ;
















