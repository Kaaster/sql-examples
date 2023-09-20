/*
Task: выгрузить список user_id тех пользователей, кто купил за период 1-15 августа 
 2 любых корма для животных, кроме "Корм Kitekat для кошек, с кроликом в соусе, 85 г".

Таблицы с данными содержат основную информацию о заказах за период 2017-08-01 по 2017-08-30. 

Table: products
+----------------+----------+
| Column Name    | Type     |
+----------------+----------+
| product_id     | int      |
| product        | varchar  |
| category       | varchar  |
+----------------+----------+
product_id - primary key, уникальный идентификатор продукта
product - полное название продукта
category - категория товара

Table: order_lines
+----------------+----------+
| Column Name    | Type     |
+----------------+----------+
| order_id       | int      |
| product_id     | int      |
| price          | float    |
| quantity       | int      |
+----------------+----------+
order_id - идентификатор заказа
product_id - идентификатор продукта
price - цена единицы продукта
quantity - количество продукта

Table: orders
+----------------+----------+
| Column Name    | Type     |
+----------------+----------+
| order_date     | date     |
| order_id       | int      |
| user_id        | int      |
+----------------+----------+
order_date - дата заказа
order_id - primary key, уникальный идентификатор заказа
user_id - пользовательский идентификатор
*/

with order_data as (
	with product_data as (
		select
			product_id
		from products
		where category = 'Продукция для животных'
			and product != 'Корм Kitekat для кошек, с кроликом в соусе, 85 г'
	)
    
	select
		order_id,
        sum(quantity) as amount
	from order_lines
	where product_id in (select product_id from product_data)
    group by 1
    
)

select distinct
    user_id
from orders
where order_date between '2017-08-01' and '2017-08-15'
	and order_id in (
		select 
			order_id 
        from order_data
        where amount = 2
    )