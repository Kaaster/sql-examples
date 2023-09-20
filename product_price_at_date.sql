# Task 1164. Product Price at a Given Date
/*
Table: Products
+---------------+---------+
| Column Name   | Type    |
+---------------+---------+
| product_id    | int     |
| new_price     | int     |
| change_date   | date    |
+---------------+---------+
(product_id, change_date) is the primary key of this table.
Each row of this table indicates that the price of some product was changed to a new price at some date.

Write an SQL query to find the prices of all products on 2019-08-16. 
Assume the price of all products before any change is 10.
Return the result table in any order.
*/

# MySQL solution
with data as (
    select
        product_id,
        if(first_change_date > '2019-08-16', first_change_date, last_change_date) as change_date
    from(
        select
            product_id,
            min(change_date) as first_change_date,
            max(if(change_date <= '2019-08-16', change_date, null)) as last_change_date
        from Products
        group by 1
    ) as t
)

select
    product_id,
    if(change_date > '2019-08-16', 10, new_price) as price
from Products inner join data using(product_id, change_date)