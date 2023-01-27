/* 
Version Jan 18, 2023 

The course materials are only for the use of students enrolled in the course CSIS 3300 at Douglas College. 
Sharing this material to a third-party website can lead to a violation of Copyright law.
*/

use university;

-- 1. Find the ID and name of each student who has not taken any courses before year 2018.
-- The first approach using NOT IN
select ID, name
from student
where ID not in (select	ID
				 from	takes
				 where	year < 2018);

/*	We may also use EXCEPT. But we need to guarantee that the two relations have
	the same structure (https://www.w3schools.com/sql/sql_union.asp). 
	So we need to join student and takes tables. */
(select	ID, name
 from student)
except
(select	student.ID, name
 from student join takes
		on student.ID = takes.ID
 where year < 2018);

-- How about the following query? What's the difference?
(select	student.ID, name
 from student join takes
		on student.ID = takes.ID)
except
(select	student.ID, name
 from student join takes
		on student.ID = takes.ID
 where year < 2018);


-- 2. Find the ID of each student who was taught by an instructor named Katz; 
--    make sure that there are no duplicates in the result.
select distinct ta.ID
from takes as ta join teaches as te
		on ta.course_id = te.course_id
		and	ta.sec_id = te.sec_id
		and	ta.semester = te.semester
		and	ta.year = te.year
	join instructor as i
		on te.ID = i.ID
where i.name = 'Katz';

-- How to further get the student's name?


-- 3. Find the total number of (distinct) students who took at least one course 
--    with the instructor with ID 10101. 
select count(distinct ta.ID)
from takes as ta join teaches as te
		on ta.course_id = te.course_id
		and	ta.sec_id = te.sec_id
		and	ta.semester = te.semester
		and	ta.year = te.year
where te.ID = 10101;


-- 4. Find the departments with the budget higher the average budget of all departments.
select dept_name
from department
where budget > (select avg(budget) 
				from department);


-- 5. Find the departments whose payroll (the total of all instructors� salaries in the department)
--    is greater than the average payroll of all departments.

-- First check the payroll of each department
select dept_name, sum(salary) as payroll
from instructor
group by dept_name;

-- Next we may use the above query to create a temporary relation in the FROM clause.
select dept_name
from (select dept_name, sum(salary) as payroll
	  from instructor
	  group by dept_name) as dept_payroll
where payroll > (select avg(payroll) 
				 from dept_payroll);

/* The above one looks good and clean, but not working :(
Reason: dept_payroll is just an inline view, which cannot be used in the subquery
in the WHERE clause. This is the scope issue with the inline view. */

-- So we may try to expand the inline view in the WHERE clause
select dept_name
from (select dept_name, sum(salary) as payroll
	  from instructor
	  group by dept_name) as dept_payroll
where payroll > (select avg(payroll) 
		         from (select dept_name, sum(salary) as payroll
					   from instructor
					   group by dept_name) as dept_payroll);

-- Now it works, but too complex!!
-- Do we have a way to define a temporary relation once that can be used in the whole query?
-- YES! We can use the WITH clause. This is called a common table expression (CTE). The scope of a CTE is the whole query
-- https://docs.microsoft.com/en-us/sql/t-sql/queries/with-common-table-expression-transact-sql?view=sql-server-ver15

with dept_payroll (dept_name, payroll) as
(
	select dept_name, sum(salary)
	from instructor
	group by dept_name
)
select dept_name
from dept_payroll
where payroll > (select avg(payroll) 
				 from dept_payroll);

-- Using CTE can significantly improve the readability.
-- We can also have multiple CTEs in a single WITH clause, separated by commas, as follows
with dept_payroll (dept_name, payroll) as
(
	select dept_name, sum(salary)
	from instructor
	group by dept_name
),
dept_payroll_avg(avg_payroll) as
(
	select avg(payroll)
	from dept_payroll
)
select dept_name
from dept_payroll, dept_payroll_avg
where payroll > avg_payroll;


-- 6. Find the department which has the lowest maximum salary. The result should display
--    the department name and the maximum salary within the department. 

--	Similarly, we can use a CTE to get the maximum salary of each department and then find
--	the department with the minimum maximum salary
with dept_max_salary as
(
	select dept_name, max(salary) as max_salary
	from instructor
	group by dept_name
)
select dept_name
from dept_max_salary
where max_salary = (select min(max_salary) 
				    from dept_max_salary);

-- You may also use TOP 1 WITH TIES
select top 1 with ties dept_name
from instructor
group by dept_name
order by max(salary);


-- 7. Find the course sections (course_id and sec_id) with the maximum enrollment (number of enrolled students) in Fall 2017.
-- We use a CTE to get the enrollment of each course section in Fall 2017
with enrollment_fall_2017 as
(
	select course_id, sec_id, count(ID) as enrollment
	from takes
	where semester = 'Fall'
	and	year = 2017
	group by course_id, sec_id
)
select course_id, sec_id
from enrollment_fall_2017
where enrollment = (select max(enrollment) 
                    from enrollment_fall_2017);

-- Use TOP
select top 1 with ties course_id, sec_id
from takes
where semester = 'Fall'
and	year = 2017
group by course_id, sec_id
order by count(ID) desc;


-- 8. Find the names of the students that did not take any courses.
-- When using join for tables, the innner join is used by default. 
select *
from student inner join takes			-- or just join
		on student.ID = takes.ID;

-- We can use left outer join to get the names of the students that did not take any courses.
select name
from student left outer join takes		-- or you can just use left join
		on student.ID = takes.ID
where takes.ID is null;

-- Or use NOT IN
select name
from student
where ID not in (select ID 
                 from takes);
			
-- 9. Find the titles of the courses that were not taught by any instructors.
select title
from teaches right join course
		on teaches.course_id = course.course_id
where ID is null;

-- We can also use NOT IN
select title
from course
where course_id not in (select course_id 
                        from teaches);

-- Full JOIN example
-- https://www.w3schools.com/sql/sql_join_full.asp

-- The following returns the Cartesian product of two tables
--  Also called CARTESIAN JOIN or the CROSS JOIN 
-- (https://www.tutorialspoint.com/sql/sql-cartesian-joins.htm)

select *
from instructor, teaches;

-- Which is equivalent to the following
select *
from instructor cross join teaches;


-- 10. Find the ID and name of each instructor who earns more than the average salary of her or his department.
-- We can use a correlated subquery
select ID, name
from instructor as s
where salary > (select avg(salary)
				from instructor as t
				where t.dept_name = s.dept_name);

-- You may check https://en.wikipedia.org/wiki/Correlated_subquery
-- The performance of correlated subqueries may not be good since the database engine may need to
-- execute the inner query for each row in the outer table. In pactice, the database engine may 
-- do some optimizations.

-- Or use the WITH clause

with dept_avg_salary (dept_name, avg_salary) as
(
	select dept_name, avg(salary)
	from instructor
	group by dept_name
)
select ID, name
from instructor as i join dept_avg_salary as d
		on i.dept_name = d.dept_name
where i.salary > d.avg_salary;

-- We can also use NON-EQUI JOIN
with dept_avg_salary (dept_name, avg_salary) as
(
	select dept_name, avg(salary)
	from instructor
	group by dept_name
)
select ID, name
from instructor as i join dept_avg_salary as d
		on i.dept_name = d.dept_name
		and	i.salary > d.avg_salary;		-- Use NON-EQUI JOIN


-- 11. Create a view of the enrollment of each section that was offered in Fall 2017.
go	-- go is used to separate batches in SQL Server 
	-- (https://docs.microsoft.com/en-us/sql/t-sql/language-elements/sql-server-utilities-statements-go?view=sql-server-ver15)

create view enrollment_fall_2017 as
select course_id, sec_id, count(ID) as enrollment
from takes
where semester = 'Fall'
and	year = 2017
group by course_id, sec_id;
go

-- You may use the view as a table
select *
from enrollment_fall_2017;

-- Drop the view
drop view enrollment_fall_2017;

-- You can create a view from a viewwith
-- First create a view of instructors out salary info

go 
create view faculty as
select ID, name, dept_name
from instructor;
go

-- Next create a view of Finance faculty only
create view faculty_finance as 
select *
from faculty
where dept_name = 'Finance';
go

select *
from faculty_finance;

-- Drop the views
drop view faculty_finance;
drop view faculty;


-- 12.	Give the average number of sections taught by each instructor who taught at 
--      least one course.
select cast((select count(*) from teaches) * 1.0 / (select count(distinct ID) from teaches) as numeric (4, 2)) as avg_workload; 

-- The ROUND function will not drop the trailing zeros
select round((select count(*) from teaches) * 1.0 / (select count(distinct ID) from teaches), 2) as avg_workload; 


-- 13. Create a new course "CS-001", titled "Weekly Seminar", with 0 credits.

-- The following will not run since credits must be greater than 0 
-- according to the check constraint in DDL
insert into course
	values ('CS-001', 'Weekly Seminar', 'Comp. Sci.', 0);
	
-- Modify the credits to 2
-- Use BEGIN TRAN and ROLLBACK for insert/delete/update
-- Check https://www.sqlshack.com/how-to-rollback-using-explicit-sql-server-transactions/
begin tran;
insert into course
	values ('CS-001', 'Weekly Seminar', 'Comp. Sci.', 2);
rollback;		-- Or use COMMIT instead of ROLLBACK the finalize the change


-- 14. Increase the salary of each instructor in the Comp. Sci. department by 10%.
begin tran;
update instructor
set	salary = salary * 1.1
where dept_name = 'Comp. Sci.';
rollback;


-- 15. Insert every student whose tot_cred attribute is greater than 100 as an instructor in the same department, with a salary of 30,000.
-- Here is an example of inserting a table to another table
begin tran;
insert into instructor
select ID, name, dept_name, 30000
from student
where tot_cred > 100;
rollback;


-- 16. Delete all rows in the instructor table for those instructors associated with a department located in the Watson building.
begin tran;
delete from instructor 
where dept_name in (select dept_name
                    from department                                      
	                where building = 'Watson');
rollback;


-- 17. Increase salaries of instructors whose salary is over $90,000 by 3%, and all others by 5%.
begin tran;
update instructor           
set	salary = salary * 1.03
where salary > 90000;
update instructor
set	salary = salary * 1.05
where salary <= 90000;
rollback;

-- If we change the order of the two updates, some instructors' salaries increase twice
begin tran;
update instructor              
set	salary = salary * 1.05             
where salary <= 90000;
update instructor
set salary = salary * 1.03
where salary > 90000;
rollback;

-- A better way is to use the CASE expression
begin tran;
update instructor
set	salary = case
	when salary <= 90000 then salary * 1.05                                  
	else salary * 1.03                                
end;
rollback;

-- More CASE examples at https://www.w3schools.com/sql/sql_case.asp

-- Mock test
-- Find the names of instructors in which the first character is not 
-- letter e, and the second character is not letter i or l. 
-- Display the names in alphabetical order.

select name
from instructor
where name like '[^e][^il]%'
order by name;

-- The above is equivalent to 
select name
from instructor
where name not like 'e%'
and	name not like '_[il]%'
order by name;

-- The following is not correct. What does it mean?
select name
from instructor
where name not like '[e][il]%'
order by name;

-- It is equivalent to 
select name
from instructor
where name not like 'e%'
or name not like '_[il]%'
order by name;

-- De Morgan's laws
-- https://en.wikipedia.org/wiki/De_Morgan%27s_laws

-- As mentioned in the class, we introduced [] and ^ to avoid/minimize 
-- the use of compound Boolean expressions, which consists of multiple
-- logical operators and/or/not for complex pattern matching.
-- You may check https://ramkedem.com/en/sql-server-and-or/ for logical
-- operator precedence, which explains why () is necessary and preferred.