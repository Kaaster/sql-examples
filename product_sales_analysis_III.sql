# Task 1070. Product Sales Analysis III
/*
Table: Sales
+-------------+-------+
| Column Name | Type  |
+-------------+-------+
| sale_id     | int   |
| product_id  | int   |
| year        | int   |
| quantity    | int   |
| price       | int   |
+-------------+-------+
(sale_id, year) is the primary key of this table.
product_id is a foreign key to Product table.
Each row of this table shows a sale on the product product_id in a certain year.
Note that the price is per unit.

Table: Product
+--------------+---------+
| Column Name  | Type    |
+--------------+---------+
| product_id   | int     |
| product_name | varchar |
+--------------+---------+
product_id is the primary key of this table.
Each row of this table indicates the product name of each product.

Write an SQL query that selects the product id, year, quantity, 
and price for the first year of every product sold.
Return the resulting table in any order.
*/

# MySQL solution
with data as (
    select
        product_id,
        min(year) as year
    from Sales
    group by 1
)

select
    product_id, 
    year as first_year, 
    quantity,
    price
from Sales
where (product_id, year) in (
    select 
        product_id,
        year
    from data
)