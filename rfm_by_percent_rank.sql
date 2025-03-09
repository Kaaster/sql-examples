/*
 * rfm-анализ на основе перцентелей - percent_rank(), альтернатива - ntile()
 * 5-балльная шкала, где 1 - хорошо, а 5 - плохо
 * 5*5*5 = 125 сегментов
 * 111 - чемпионы ... 555 - спящие
 * 
 * Данные:
 * Таблица order_lines, колонки: order_id, price, quantity
 * Таблица orders, колонки: order_id, order_date, user_id
 * 
 * СУБД - Postgres
*/
with df as (
	with order_revenue as (
		select 
			order_id, 
			sum(coalesce(price, 0.0)*coalesce(quantity, 0)) as revenue
		from store.order_lines
		group by 1
	)
	select 
		user_id,
		(current_date - max(order_date)) as recency,
		count(distinct t1.order_id) as frequency,
		sum(revenue) as monetary
	from store.orders as t1
	left outer join order_revenue as t2
	using(order_id)
	group by 1
)
select 
	user_id,
	case 
		when recency_pr > 0.8 then 1
		when recency_pr > 0.6 then 2
		when recency_pr > 0.4 then 3
		when recency_pr > 0.2 then 4
		else 5
	end recency_score,
	case 
		when frequency_pr > 0.8 then 1
		when frequency_pr > 0.6 then 2
		when frequency_pr > 0.4 then 3
		when frequency_pr > 0.2 then 4
		else 5
	end frequency_score,
	case 
		when monetary_pr > 0.8 then 1
		when monetary_pr > 0.6 then 2
		when monetary_pr > 0.4 then 3
		when monetary_pr > 0.2 then 4
		else 5
	end monetary_score
from(
	select 
		user_id,
		/*
		 * возможна ситуация, когда одинаковым значениям присваивается разный перцентиль
		 * для улучшения контроля присвоения перцентелей, добавлю доп колонки для сортировки
		 * ранжирование с доп полями даёт приоритет более активным и ценным пользователям
		 */
		percent_rank() over (order by recency desc, frequency desc, monetary desc) as recency_pr,
		percent_rank() over (order by frequency asc, recency asc, monetary desc) as frequency_pr,
		percent_rank() over (order by monetary asc, recency asc, frequency desc) as monetary_pr
	from df
) as t
