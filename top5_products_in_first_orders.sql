/*
Task: запрос должен вернуть топ 5 самых часто встречающихся товаров 
 в первых заказах пользователей в СПб за период 15-30 августа.

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

Table: warehouses
+----------------+----------+
| Column Name    | Type     |
+----------------+----------+
| city           | varchar  |
| warehouse_id   | int      |
| address        | varchar  |
+----------------+----------+
warehouse_id - primary key, уникальный идентификатор город + адреса
city, address - город и адрес

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
| warehouse_id   | int      |
+----------------+----------+
order_date - дата заказа
order_id - primary key, уникальный идентификатор заказа
user_id - пользовательский идентификатор
warehouse_id - адрес доставки
*/

with order_data as (
	with warehouses_data as (
		select
			warehouse_id
		from warehouses
		where city = 'Санкт-Петербург'
	)

	select
		user_id,
		order_id
	from(
		select 
			order_date,
			user_id,
			order_id,
			min(order_id) over (partition by user_id) as first_order_id,
			min(order_date) over (partition by user_id) as first_order_date
		from orders
		where order_date between '2017-08-15' and '2017-08-30'
			and warehouse_id in (select warehouse_id from warehouses_data)
	) as t
	where order_id = first_order_id and order_date = first_order_date

)

select 
	if(product is null, 'Неизвестно', product) as product
from(
	select distinct
		product_id,
        dense_rank() over (partition by product_id order by count(*) desc) as pos
	from order_lines inner join order_data using(order_id)
) as t
left outer join products using(product_id)
where pos <= 5