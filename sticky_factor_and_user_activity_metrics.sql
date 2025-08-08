-- Расчет динамики метрик DAU, WAU, MAU и Sticky Factor (Stickiness) относительно выбранного диапазона

-- DAU - Daily Active Users: число активных пользователей за последний день
-- WAU - Weekly Active Users: число активных пользователей за последние 7 дней
-- MAU - Monthly Active Users: число активных пользователей за последние 30 дней
-- Sticky Factor (Stickiness): вовлеченность, отношение DAU к WAU или MAU, WAU к MAU


with df as (
  select distinct
    event_date,
    user_pseudo_id,
  from database.table
  where event_name = 'page_view'
), dau as (
  select 
    event_date,
    count(distinct user_pseudo_id) as dau,
  from df 
  group by event_date
), wau as (
  select 
    t1.event_date,
    count(distinct t2.user_pseudo_id) as wau,
  from dau as t1
  left join df as t2 on t2.event_date between date_add(t1.event_date, interval -6 day) and t1.event_date
  group by event_date
), mau as (
  select 
    t1.event_date,
    count(distinct t2.user_pseudo_id) as mau,
  from dau as t1
  left join df as t2 on t2.event_date between date_add(t1.event_date, interval -29 day) and t1.event_date
  group by event_date  
)
select 
  t1.event_date,  
  t1.dau,
  t2.wau,
  t3.mau,
  ifnull(safe_divide(t1.dau, t2.wau), 0.0) as dau_wau,
  ifnull(safe_divide(t1.dau, t3.mau), 0.0) as dau_mau,
  ifnull(safe_divide(t2.wau, t3.mau), 0.0) as wau_mau,
from dau as t1
left join wau as t2 using(event_date)
left join mau as t3 using(event_date)
;


-- вариант реализации с фильтрами: город или источник трафика или ...

with df as (
  with base as (
    select distinct
      event_date,
      user_pseudo_id,
      geo_country,
    from database.table
    where event_name = 'page_view'
  )
  select event_date, user_pseudo_id, geo_country,
  from base

  union all

  select event_date, user_pseudo_id, 'ALL' as geo_country,
  from base

), dau as (
  select 
    event_date,
    geo_country,
    count(distinct user_pseudo_id) as dau,
  from df 
  group by event_date, geo_country

), wau as (
  select 
    t1.event_date,
    t1.geo_country,
    count(distinct t2.user_pseudo_id) as wau,
  from dau as t1
  left join df as t2 
  on t1.geo_country = t1.geo_country and 
     t2.event_date between date_add(t1.event_date, interval -6 day) and t1.event_date
  group by t1.event_date, t1.geo_country

), mau as (
  select 
    t1.event_date,
    t1.geo_country,
    count(distinct t2.user_pseudo_id) as mau,
  from dau as t1
  left join df as t2
  on t1.geo_country = t1.geo_country and 
     t2.event_date between date_add(t1.event_date, interval -29 day) and t1.event_date
  group by t1.event_date, t1.geo_country

)
select 
  t1.event_date,  
  t1.geo_country,
  t1.dau,
  t2.wau,
  t3.mau,
  ifnull(safe_divide(t1.dau, t2.wau), 0.0) as dau_wau,
  ifnull(safe_divide(t1.dau, t3.mau), 0.0) as dau_mau,
  ifnull(safe_divide(t2.wau, t3.mau), 0.0) as wau_mau,
from dau as t1
left join wau as t2 using(event_date, geo_country)
left join mau as t3 using(event_date, geo_country)
;
