-- Есть таблица пользователей user (user_id — id пользователя, installed_at — дата установки) 
-- 	и таблица активности client_session (user_id, created_at — таймстемп активности).
-- Необходимо написать SQL-запрос который считает Retention 1, 3, 7 дня по пользователям 
-- 	с группировкой установок по месяцам (с января 2022-го года).

-- BigQuery Standart SQL
select
	install_month,
	max(if(day = 1, retention_rate, null)) as retention_day_1,
	max(if(day = 3, retention_rate, null)) as retention_day_3,
	max(if(day = 7, retention_rate, null)) as retention_day_7
from(
	select	
		install_month,
		day,
		safe_divide(returned, total)*100 as retention_rate
	from(
		select 
			extract(month from installed_at) as install_month,
			date_diff(event_date, installed_at, day) as day,
			count(*) as returned,
			max(count(*)) over (partition by installed_at) as total
		from(
			select distinct
				user_id,
				installed_at
			from user
			where installed_at >= '2022-01-01'
		) left outer join (
			select distinct
				user_id,
				date(created_at) as event_date
			from client_session
            		where installed_at >= '2022-01-01'
		) using(user_id)
		-- where event_date >= installed_at
		group by 1, 2
	)
)
