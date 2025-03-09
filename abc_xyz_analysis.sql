/*
 * 
 * ABC/XYZ-анализ
 * ABC - ценность товара с точки зрения выручки, исходя из принципа Парето
 * XYZ - стабильность спроса на товар, исходя из коэффициента вариации
 * 
 * СУБД - Postgres
 * 
 */
with df as (
	select 
		t1.order_id,
		t1.product_id,
		coalesce(t1.price, 0.0) as price, 
		coalesce(t1.quantity, 0.0) as quantity,
		t2.order_date
	from store.order_lines as t1
	left outer join store.orders as t2 using(order_id)
	where product_id is not null	
), abc as (
	select
		product_id,
		case
			when cumulative_perc_of_revenue <= 0.8 then 'A'
			when cumulative_perc_of_revenue <= 0.95 then 'B'
			when cumulative_perc_of_revenue > 0.95 then 'C'
			else 'U' -- unknown
		end as abc_group
	from(
		select 
			*,
			sum(perc_of_revenue) over (order by revenue desc) as cumulative_perc_of_revenue
		from(
			select 
				product_id, 
				sum(price*quantity) as revenue,
				sum(price*quantity) / sum(sum(price*quantity)) over () as perc_of_revenue
			from df 
			group by 1
		) as t
	) as t
), xyz as (
	/*
	select 
		to_char(order_date, 'IYYY-IW') as year_week,
		product_id,
		sum(quantity) as quantity,
		stddev(sum(quantity)) over (partition by product_id) as std_quantity,
		avg(sum(quantity)) over (partition by product_id) as avg_quantity,
		stddev(sum(quantity)) over (partition by product_id) / avg(sum(quantity)) over (partition by product_id)
	from df
	group by 1, 2
	*/		
	select 
		product_id,
		case 
			when stddev(quantity) / avg(quantity) <= 0.1 then 'X'
			when stddev(quantity) / avg(quantity) <= 0.25 then 'Y'
			when stddev(quantity) / avg(quantity) > 0.25 then 'Z'
			else 'U' -- unknown
		end as xyz_group
	from(
		select 
			to_char(order_date, 'IYYY-IW') as year_week,
			product_id,
			sum(quantity) as quantity
		from df
		group by 1, 2
	) as t
	group by 1
)
select 
	abc_group as group,
	count(distinct case when xyz_group = 'X' then coalesce(t1.product_id, t2.product_id) end) as "X",
	count(distinct case when xyz_group = 'Y' then coalesce(t1.product_id, t2.product_id) end) as "Y",
	count(distinct case when xyz_group = 'Z' then coalesce(t1.product_id, t2.product_id) end) as "Z",
	count(distinct case when xyz_group = 'U' then coalesce(t1.product_id, t2.product_id) end) as "U" -- unknown
from abc as t1
full outer join xyz as t2 using(product_id)
group by 1
