/*
	Подготовка данных для визуализации N-month retention и кумулятивного ретеншена
	Условия: 0-й день пользователя - дата первой покупки, дата возврата - дата повторной покупки, если сумма больше нуля
	MySQL
*/


with data as (
	select 
		client_id,
		date_format(order_date, '%Y-%m-01') as order_date,
		min(date_format(order_date, '%Y-%m-01')) over (partition by client_id) as min_order_date
	from orders
	where order_total_price > 0
    
), n_month_retention as (
	select
		min_order_date,
		order_date, 
		timestampdiff(month, min_order_date, order_date) as month_action,
		count(distinct client_id) as customers,
		max(count(distinct client_id)) over (partition by min_order_date) as total
	from data
	group by 1, 2, 3

), cumulative_total_data as (
	select 
		min_order_date, 
        sum(total) over (order by min_order_date asc rows between unbounded preceding and current row) as cumulative_total
    from n_month_retention
    where month_action = 0

)


select
	min_order_date,
	order_date,
	month_action,
	customers,
	total,
	cumulative_total
from n_month_retention
left outer join cumulative_total_data using(min_order_date)