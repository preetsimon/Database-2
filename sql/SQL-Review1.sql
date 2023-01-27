/* 
Version Jan 12, 2023

The course materials are only for the use of students enrolled in the course CSIS 3300 at Douglas College. 
Sharing this material to a third-party website can lead to a violation of Copyright law.
*/

use university;

/* 1. Find each instructor who has taught at least one course. Display each instructor’s name
	  and the course titles taught by each instructor.
	  Remove duplicate rows from the result.*/
select	distinct name, title
from	instructor as i join teaches as t
			on i.ID = t.ID
		join course as c
			on t.course_id = c.course_id;


-- 2. Find the name of each instructor whose name starts with letter b or e.
select	name
from	instructor
where	name like '[be]%';


-- 3. Find the name of each instructor whose name starts with letter b, c, d, or e.
select	name
from	instructor
where	name like '[b-e]%';

-- 4. Find the name of each instructor whose name does not start with letter b or e.
select	name
from	instructor
where	name not like '[be]%';

-- Or the following, which is more flexible
select	name
from	instructor
where	name like '[^be]%';


-- 5. Find the name of each instructor whose name has a as the second character.
select	name
from	instructor
where	name like '_a%';


-- 6. Find the name of each instructor whose name starts with 
--    letter b, c, d, e, or s and has i as the second character.
select	name
from	instructor
where	name like '[b-es]i%';


-- 7. Find the name of each instructor whose name has 4 characters.
select	name
from	instructor
where	name like '____';

-- Using the LEN function is recommended in many cases. 
-- But the LEN function does not count the trailing spaces at the end of the string
-- You may check https://www.techonthenet.com/sql_server/functions/len.php for more examples
select	name
from	instructor
where	len(name) = 4;


-- 8. Display the first 3 characters of each instructor’s name in upper case.
select	upper(substring(name, 1, 3))		-- Start from index 1, with the length of 3 letters.
from	instructor;							

-- 1. What if the name has fewer than 3 letters? No padding is used
-- 2. Substring include the space if there is, including the trailing space, 
--    as shown in the following. 
-- Pay attention to WU! and El !
select	substring(name, 1, 3) + '!'
from	instructor

-- Space in the middle will be counted
select	substring(name, 1, 3) + '!', len(substring(name, 1, 3) + '!')
from	instructor

-- You may check how the LEN function deals with the trailing space (El )
select	substring(name, 1, 3), len(substring(name, 1, 3))
from	instructor

-- Leading space is counted in LEN
select	' ' + substring(name, 1, 3), len(' ' + substring(name, 1, 3))
from	instructor

-- You may also check the LEFT and RIGHT functions in SQL Server
-- https://www.w3schools.com/sql/func_sqlserver_left.asp
-- https://www.w3schools.com/sql/func_sqlserver_right.asp

select	upper(left(name, 3))
from	instructor;


-- 9. Display the name and department of each instructor in the format name@dept_name.
select	concat(name, '@', dept_name)
from	instructor;

-- You may also use the plus (+) operator 
select	name + '@' + dept_name
from	instructor;

-- But concat has better readability and handles NULL values better. 
select	concat(null, '@', dept_name), null + '@' + dept_name
from	instructor;

-- You may check https://www.mssqltips.com/sqlservertip/2985/concatenate-sql-server-columns-into-a-string-with-concat/


/* 10. Find the name and department of each instructor; order the results first by the 
       department in the descending order and then by the name in the ascending order. */
select	name, dept_name
from	instructor
order by dept_name desc, name asc;


-- 11. Find the name and salary of each instructor whose salary >=90000 and <=100000.
select	name, salary
from	instructor
where	salary >= 90000
and		salary <= 100000;

-- Or use BETWEEN
select	name, salary
from	instructor
where	salary between 90000 and 100000;
-- Note: BETWEEN includes both numbers


-- 12. Find the average of instructors’ salary of the Comp. Sci. department.
select	cast(avg(salary) as numeric(8, 2)) as cs_avg_salary
from	instructor
where	dept_name = 'Comp. Sci.';

-- Use a literal string in the SELECT clause
select	'Comp. Sci.' as dept_name, cast(avg(salary) as numeric(8, 2)) as avg_salary
from	instructor
where	dept_name = 'Comp. Sci.'

-- If you want to use dept_name attribute in the SELECT clause, GROUP BY is required
select	dept_name, cast(avg(salary) as numeric(8, 2)) as avg_salary
from	instructor
where	dept_name = 'Comp. Sci.' 
group by dept_name;


/* 13. Find the department name and average salary of each department with the 
       average salary greater than 80000. */
select	dept_name, cast(avg(salary) as numeric(8, 2)) as avg_salary
from	instructor
group by dept_name
having	avg(salary) > 80000;

-- The following will not work
select	dept_name, cast(avg(salary) as numeric(8, 2)) as avg_salary
from	instructor
group by dept_name
having	avg_salary > 80000;	 -- SQL Server does not allow the HAVING clause to use the column alias specified in select cause. 
							 -- Similarly, you may also check if where clause can use the column alias specified in select cause.


-- 14. Find all the instructors who have the highest salary.

-- The following does not work in SQL server
select  name
from	instructor
where	salary = max(salary);

-- Use a subquery in the WHERE clause
select	name
from	instructor
where	salary = (select max(salary) from instructor);

-- Or use TOP
select top 1 name
from	instructor
order by salary desc;

-- If there are ties, need to use WITH TIES to display all of them
select top 1 with ties name
from	instructor
order by salary desc;


/* 15. Find the name of each instructor whose salary is greater than the salary of 
       every instructor in the Finance department. */
select	name
from	instructor
where	salary > (select max(salary)
				  from	instructor
				  where	dept_name = 'Finance');

-- The second approach is to use ALL
select	name
from	instructor
where	salary > all (select salary
					  from	instructor
					  where	dept_name = 'Finance');


/* 16. Find the name of each instructor who has a higher salary than 
       at least one instructor in the Finance department. */
select	name
from	instructor
where	salary > (select	min(salary)
				 from		instructor
				 where		dept_name = 'Finance');

-- Another method using SOME
select	name
from	instructor
where	salary > some (select	salary
					  from		instructor
					  where		dept_name = 'Finance');

-- You can also use ANY, which is equivalent to SOME
select	name
from	instructor
where	salary > any (select	salary
					 from		instructor
					 where		dept_name = 'Finance');

-- Another method using SELF JOIN
select	distinct s.name
from	instructor as s, instructor as t
where	s.salary > t.salary
and		t.dept_name = 'Finance';

-- Use join on inequality (often called Non-Equi Join)
select	distinct s.name
from	instructor as s join instructor as t
			on	s.salary > t.salary
where	t.dept_name = 'Finance';

-- You may check https://www.w3schools.com/sql/sql_join_self.asp for more about Self Join.
-- You may check https://www.essentialsql.com/non-equi-join-sql-purpose/ for more about Non-Equi Join.


-- 17. Find the courses offered in Fall 2017 or Spring 2018 (course_id is enough). 
select	distinct course_id
from	section
where	(semester = 'Fall' and year = 2017)
or		(semester = 'Spring' and year = 2018);

-- Another method that uses the keyword UNION
(select	course_id from section where semester = 'Fall' and year = 2017)
union
(select	course_id from section where semester = 'Spring' and year = 2018);
-- Note: UNION will remove duplicate rows automatically, so DISTINCT is not needed. You can use UNION ALL to keep duplicates


-- 18. Find the courses offered in both Fall 2017 and Spring 2018.

-- The following one seems right, but not working
select	course_id
from	section
where	(semester = 'Fall' and year = 2017)
and		(semester = 'Spring' and year = 2018);

-- We can use INTERSECT
(select	course_id from section where semester = 'Fall' and year = 2017)
intersect
(select	course_id from section where semester = 'Spring' and year = 2018);
-- INTERSECT ALL is not supported in SQL Server

-- You can also use subquery and IN
select	distinct course_id
from	section
where	semester = 'Fall' and year =2017
and		course_id in (select	course_id
					 from		section
					 where		semester = 'Spring' and year = 2018);
	
-- Or as proposed by some students in the class, use = and SOME, which is less common
select	distinct course_id
from	section
where	semester = 'Fall' and year =2017
and		course_id = some (select	course_id
						 from		section
						 where		semester = 'Spring' and year = 2018);


-- 19. Find the courses offered in Fall 2017 but not Spring 2018.
(select	course_id from section where semester = 'Fall' and year = 2017)
except
(select	course_id from section where semester = 'Spring' and year = 2018);
-- EXCEPT ALL is not supported in SQL Server

-- Or use NOT IN
select	distinct course_id
from	section
where	semester = 'Fall' and year =2017
and		course_id not in (select	course_id
						 from		section
						 where		semester = 'Spring' and year = 2018);

-- Or use != and ALL
select	distinct course_id
from	section
where	semester = 'Fall' and year =2017
and		course_id != all (select	course_id
						 from		section
						 where		semester = 'Spring' and year = 2018);

-- Using != and SOME gives a different result, which is not correct. Why?
select	distinct course_id
from	section
where	semester = 'Fall' and year =2017
and		course_id != some (select	course_id
						  from		section
						  where		semester = 'Spring' and year = 2018);

-- 20. Find all instructors not from History or Biology department.
select	name
from	instructor
where	dept_name != 'History'
and		dept_name !='Biology';

-- Use NOT IN, which has better readability and can be easily extended
select	name
from	instructor
where	dept_name not in ('History', 'Biology');