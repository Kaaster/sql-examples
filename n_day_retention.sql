/*
	Необходимо написать SQL-запрос для визуализации динамики ретеншена 1, 3, 7 дня относительно для установки
	Условия: есть таблица users_data (user_id — id пользователя, install_date — дата установки) и 
		user_actions_data (user_id, event_date — дата активности)
	BigQuery Standart SQL
*/


select
	install_date,
	max(if(day = 1, retention_rate, null)) as retention_day_1,
	max(if(day = 3, retention_rate, null)) as retention_day_3,
	max(if(day = 7, retention_rate, null)) as retention_day_7
from(
	select	
		install_date,
		retention_day,
		safe_divide(returned, total)*100 as retention_rate
	from(
		select 
			install_date,
			date_diff(event_date, install_date, day) as retention_day,
			count(distinct user_id) as returned,
			max(count(distinct user_id)) over (partition by install_date) as total
		from users_data 
		left outer join user_actions_data using(user_id)
		where event_date >= installed_at
		group by 1, 2
	)
)
where retention_day in (1, 3, 7)
group by 1