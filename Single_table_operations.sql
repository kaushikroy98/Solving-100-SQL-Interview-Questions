/* Question 1. Top store for movie sale
Write a query to return the name of the store and its manager, that generated the most sales.*/

select store, manager from sales_by_store
order by total_sales desc
limit 1;


/* Question 2. Top 3 movie categories by sales
Write a query to find the top 3 film categories that generated the most sales. The order of your results doesn't matter.*/

select category from sales_by_film_category
order by total_sales desc
limit 3;


/*Question 3. Top 5 shortest movies
Write a query to return the titles of the 5 shortest movies by duration. The order of your results doesn't matter.*/

select title from film
order by length
limit 5;


/* Question 4. Staff without a profile image

• Write a SQL query to return this staff's first name and last name.
• Picture field contains the link that points to a staff's profile image.
• There is only one staff who doesn't have a profile picture.
• Use colname IS NULL to identify data that are missing.*/

select first_name, last_name from staff
where picture is null;


/* Question 5. Monthly revenue

• Write a query to return the total movie rental revenue for each month.
• You can use EXTRACT(MONTH FROM colname) and EXTRACT(YEAR FROM colname) to extract month and year from a timestamp column.*/

select extract(year from payment_ts), extract(month from payment_ts), sum(amount) as revnue
from payment
group by 1,2
order by 1,2;


/* Question 5. Daily revenue in June, 2020

• Write a query to return daily revenue in June, 2020.
• Use DATE(colname) to extract the date from a timestamp column.
• payment_ts's data type is timestamp, convert it to date before grouping.
• No dates need to be included if there was no revenue on that day.*/

select date(payment_ts), sum(amount) as daily_revenue
from payment 
where 
extract(year from payment_ts)=2020 
and  extract(month from payment_ts)=6
group by 1
order by 1;


/* Question 7. Unique customers count by month

• Write a query to return the total number of unique customers for each month
• Use EXTRACT(YEAR from ts_field) and EXTRACT(MONTH from ts_field) to get year and month from a timestamp column.
• The order of your results doesn't matter.*/

select extract(year from rental_ts) as year,
extract(month from rental_ts ) as month, 
count(distinct customer_id) as unique_customer
from rental
group by 1,2;


/* Question 8. Average customer spend by month

• Write a query to return the average customer spend by month.
• Definition: average customer spend: total customer spend divided by the unique number of customers for that month.
• Use EXTRACT(YEAR from ts_field) and EXTRACT(MONTH from ts_field) to get year and month from a timestamp column.
• The order of your results doesn't matter. */

select extract(year from payment_ts) year, extract(month from payment_ts) month,
sum(amount)-count(distinct customer_id) avg_spend
from payment
group by 1,2
order by 1,2;


/* Question 9. Number of high spend customers by month

• Write a query to count the number of customers who spend more than (>) $20 by month
• Use EXTRACT(YEAR from ts_field) and EXTRACT(MONTH from ts_field) to get year and month from a timestamp column.
• The order of your results doesn't matter.
• Hint: a customer's spend varies every month*/

with customer_spend as
(select customer_id, extract(year from payment_ts) year, 
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


select min(spend), max(spend) from
(
select customer_id, sum(amount) spend from payment
where extract(year from payment_ts) =2020
and extract(month from payment_ts) = 6
group by 1) a































