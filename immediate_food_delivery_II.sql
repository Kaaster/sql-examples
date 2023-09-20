# Task 1174. Immediate Food Delivery II
/*
Table: Delivery
+-----------------------------+---------+
| Column Name                 | Type    |
+-----------------------------+---------+
| delivery_id                 | int     |
| customer_id                 | int     |
| order_date                  | date    |
| customer_pref_delivery_date | date    |
+-----------------------------+---------+
delivery_id is the primary key of this table.
The table holds information about food delivery to customers that make orders at some date 
and specify a preferred delivery date (on the same order date or after it). 

If the customer's preferred delivery date is the same as the order date, then the order is called immediate; 
otherwise, it is called scheduled.
The first order of a customer is the order with the earliest order date that the customer made. 
It is guaranteed that a customer has precisely one first order.
Write an SQL query to find the percentage of immediate orders in the first orders of all customers, 
rounded to 2 decimal places.
*/

# MySQL solution
with only_first_orders as (
    select 
        customer_id,
        min(order_date) as order_date
    from Delivery
    group by 1
)

select
    round(
		100*count(if(order_date = customer_pref_delivery_date, order_date, null))/count(*), 
	2) as immediate_percentage
from Delivery 
where (customer_id, order_date) in (
	select 
		customer_id, 
        order_date 
    from only_first_orders
)