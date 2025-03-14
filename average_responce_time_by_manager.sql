/*
 * 
 * Написать SQL-запрос, который будет рассчитывать среднее время ответа для каждого менеджера/пары менеджеров
 * Расчёт должен учитывать следующее:
 * *	если в диалоге идут несколько сообщений подряд от клиента или менеджера, 
 * * *		то при расчёте времени ответа надо учитывать только первое сообщение из каждого блока;
 * *	менеджеры работают с 09:30 до 00:00, поэтому нерабочее время не должно учитываться в расчёте среднего времени ответа, 
 * * *		т.е. если клиент написал в 23:59, а менеджер ответил в 09:30 – время ответа равно одной минуте;
 * *	ответы на сообщения, пришедшие ночью также нужно учитывать
 * 
 * СУБД - Postgres
 * 
*/
with df as (
	with pre_df as (
		select 
			entity_id,
			created_by,
			created_at as responce,
			lag(created_at) over (partition by entity_id order by created_at asc) as request,
			(lag(created_at) over (partition by entity_id order by created_at asc))::date = created_at::date as same_day_response
		from(
			/* определяем "блоки" сообщений от одного пользователя, затем оставляем только первое сообщение из "блока" */
			select 
				t1.entity_id,
				created_by,
				to_timestamp(created_at) as created_at,
				created_by = lag(created_by) over (partition by entity_id order by created_at asc) as same__created_by
			from chat_crm.chat_messages as t1
		) as t
		where same__created_by is not true
	)
	select 
		*,
		case 
			/* если менеджер отвечает в рабочее время */
			when responce::time between '09:30:00'::time and '23:59:59'::time
				then 
					case 
						when not same_day_response
							then extract(epoch from (responce - request)) - (34200*(responce::date - request::date))
						when same_day_response and request::time < '09:30:00'::time 
							then extract(epoch from (responce - (request + ('09:30:00'::time - request::time))))
						else extract(epoch from (responce - request))
					end
			/* если менеджер отвечает в НЕ рабочее время */
			when responce::time between '00:00:00'::time and '09:29:59'::time
				then 
					case 
						when not same_day_response
							then extract(epoch from (date_trunc('day', request) + interval '1 day - 1 second') - request)
						else 0
					end
		end as responce_time_sec
	from pre_df
	where created_by != 0 /* оставляем данные относительно менеджеров */
)
select 
	t2.name_mop,
	t1.*
from(
	select
		created_by,
		round(avg(responce_time_sec)/60, 2) as avg__responce_time_minuts,
		round(stddev(responce_time_sec)/60, 2) as stddev__responce_time_minuts,
		round((stddev(responce_time_sec)/60)/(avg(responce_time_sec)/60), 4) as cv,
		count(distinct entity_id) as chats,
		count(*) as responces,
		count(*) filter (where request is null) as not_responced_messages
	from df
	group by 1
) as t1
left outer join chat_crm.managers as t2
on t1.created_by = t2.mop_id
