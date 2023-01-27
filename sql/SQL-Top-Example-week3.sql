/* 
Version Jan 25, 2023

The course materials are only for the use of students enrolled in the course CSIS 3300 at Douglas College. 
Sharing this material to a third-party website can lead to a violation of Copyright law.
*/

use TestDB;
-- Top 1 order by salary, which shows one row only. The standard syntax is using ()
-- https://docs.microsoft.com/en-us/sql/t-sql/queries/top-transact-sql?view=sql-server-ver15

-- Find the employees with the highest salary (order by salary desc)
select top (1) name, salary			-- The () is often omitted 
from employee
order by salary desc;

-- You may use TOP without an ORDER BY to retrieve rows, but the order is not guaranteed
-- https://www.brentozar.com/archive/2019/05/why-order-isnt-guaranteed-without-an-order-by/

-- Top 1 with ties shows all the employees with the highest salary (order by salary desc)
select top 1 with ties name, salary
from employee
order by salary desc;

-- The following is equivalent to top 1 with ties
select name, salary
from employee
where salary = (select max(salary) 
				from employee);

-- Top 5 highest salary
select top 5 name, salary
from employee
order by salary desc;			

-- Top 5 highest salary with ties
select top 5 with ties name, salary
from employee
order by salary desc;  
-- If you compare the results of the above two queries, the order of records with the salary of 80000 may not be the same.

-- Top 30% highest salary
select top 30 percent name, salary
from employee
order by salary desc;

-- Top 30% highest salary with ties
select top 30 percent with ties name, salary
from employee
order by salary desc;


-- What is the second highest salary?
select max(salary)
from employee
where salary < (select max(salary) 
				from employee);

-- How to get the employees with the second highest salary? So here to find the employees with 80000 salary.
select top 1 with ties name, salary 
from employee 
where salary < (select max(salary) from employee)
order by salary desc;


-- To find the N-th highest (the third highest in the following example) using different approaches.

-- 1. Use the WITH clause
with top_salaries as 
(
	select distinct top 3 salary
	from employee
	order by salary desc
)
select name, salary
from employee
where salary = (select min(salary) 
				from top_salaries);		-- CTE is used in the subquery; not needed in the outer query


-- 2. Use the OFFSET FETCH command, which is similar to the LIMIT command in MySQL.
-- You may check https://www.sqlservertutorial.net/sql-server-basics/sql-server-offset-fetch/
-- https://www.sqlservertutorial.net/sql-server-basics/sql-server-offset-fetch/

select name, salary
from employee
where salary = (select distinct salary		-- Get the third highest salary in the subquery
				from employee
				order by salary desc
				offset 2 rows				-- Offset N-1 rows
				fetch next 1 rows only);	

-- 3. Use the DENSE_RANK() window function
-- Note: you cannot use reference the window function in the WHERE clause; 
-- you may use a CTE, namely the WITH clause
with salary_ranking (name, salary, salary_rank) as
(
	select name, salary, DENSE_RANK() over (order by salary desc)
	from employee
)
select name, salary
from salary_ranking
where salary_rank = 3;

-- You may check the DENSE_RANK function
-- https://docs.microsoft.com/en-us/sql/t-sql/functions/dense-rank-transact-sql?view=sql-server-ver16
-- https://www.sqlservertutorial.net/sql-server-window-functions/sql-server-dense_rank-function/

-- Difference between RANK(), DENSE_RANK(), and ROW_NUMBER()
select name, salary, 
	   DENSE_RANK() over (order by salary desc) as salary_dense_rank,
	   RANK() over (order by salary desc) as salary_rank,
	   ROW_NUMBER() over (order by salary desc) as salary_rnum
from employee;

-- Salary rank within each department
select name, department, salary,
	   DENSE_RANK() over (partition by department order by salary desc) as salary_dense_rank_dept,
	   RANK() over (partition by department order by salary desc) as salary_rank_dept,
	   ROW_NUMBER() over (partition by department order by salary desc) as salary_rnum_dept
from employee;

-- Aggregate window functions 
select name, department, salary,
       cast(avg(salary) over (partition by department) as numeric(8, 2)) as dept_avg,
	   max(salary) over (partition by department) as dept_max
from employee;

-- More window function examples https://www.sqlshack.com/use-window-functions-sql-server/

-- 4. Use a correlated subquery to find the employees with the third highest salary
select name, salary
from employee as e1
where 3 = (select count(distinct salary) + 1	
		   from employee as e2
		   where e1.salary < e2.salary);
			  			   
-- Or the following
select name, salary
from employee as e1
where 3 = (select count(distinct salary) 
		   from	employee as e2
		   where e1.salary <= e2.salary);

-- 5. Another approach using Self Join
select e1.name, e1.salary
from employee as e1 join employee as e2
		on e1.salary < e2.salary
group by e1.name, e1.salary			-- Must include e1.salary since it is in the SELECT clause
having count (distinct e2.salary) + 1 = 3;

-- Or the following
select e1.name, e1.salary
from employee as e1 join employee as e2
			on e1.salary <= e2.salary
group by e1.name, e1.salary
having count (distinct e2.salary) = 3;