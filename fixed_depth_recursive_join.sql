/*

Рекурсивное соединение для иерархических данных с фиксированной глубиной.
Алгоритм "подъем по дереву" (tree climbing).
Альтернатива для RECURSIVE CTE, которые есть не во всех СУБД.


*/

with classes as (
  select
    class_id,
    class_name,
    created_at,
    parent_id
  from schema.table
  where deleted_at is null
)
select 
  t1.class_id,
  t1.class_name,
  t1.created_at,
  case
    when t1.parent_id is null then 1
    when t2.parent_id is null then 2
    when t3.parent_id is null then 3
    when t4.parent_id is null then 4
    when t5.parent_id is null then 5
    when t6.parent_id is null then 6
    when t7.parent_id is null then 7
    when t8.parent_id is null then 8
    when t9.parent_id is null then 9
  end as level,
  (
    ifnull(t9.class_name || '>>>', '') || -- first level
    ifnull(t8.class_name || '>>>', '') ||
    ifnull(t7.class_name || '>>>', '') ||
    ifnull(t6.class_name || '>>>', '') ||
    ifnull(t5.class_name || '>>>', '') ||
    ifnull(t4.class_name || '>>>', '') ||
    ifnull(t3.class_name || '>>>', '') ||
    ifnull(t2.class_name || '>>>', '') ||
    ifnull(t1.class_name || '>>>', '')    -- last level
  ) as class_names
from classes t1
left join classes t2 on t1.parent_id = t2.class_id
left join classes t3 on t2.parent_id = t3.class_id
left join classes t4 on t3.parent_id = t4.class_id
left join classes t5 on t4.parent_id = t5.class_id
left join classes t6 on t5.parent_id = t6.class_id
left join classes t7 on t6.parent_id = t7.class_id
left join classes t8 on t7.parent_id = t8.class_id
left join classes t9 on t8.parent_id = t9.class_id