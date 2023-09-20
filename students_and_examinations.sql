# Task 1280. Students and Examinations
/*
Table: Students
+---------------+---------+
| Column Name   | Type    |
+---------------+---------+
| student_id    | int     |
| student_name  | varchar |
+---------------+---------+
student_id is the primary key for this table.
Each row of this table contains the ID and the name of one student in the school.

Table: Subjects
+--------------+---------+
| Column Name  | Type    |
+--------------+---------+
| subject_name | varchar |
+--------------+---------+
subject_name is the primary key for this table.
Each row of this table contains the name of one subject in the school.

Table: Examinations
+--------------+---------+
| Column Name  | Type    |
+--------------+---------+
| student_id   | int     |
| subject_name | varchar |
+--------------+---------+
There is no primary key for this table. It may contain duplicates.
Each student from the Students table takes every course from the Subjects table.
Each row of this table indicates that a student with ID student_id attended the exam of subject_name.
 
Write an SQL query to find the number of times each student attended each exam.
Return the result table ordered by student_id and subject_name.
*/

# MySQL solution
with data as (
    select
        student_id, 
        student_name, 
        subject_name
    from Students
    cross join Subjects
)

select
    student_id, 
    student_name, 
    subject_name,
    ifnull(attended_exams, 0) as attended_exams
from data 
left outer join (
    select 
        student_id, 
        subject_name,
        count(*) as attended_exams
    from Examinations
    group by 1, 2
) as t using(student_id, subject_name)
order by student_id, subject_name