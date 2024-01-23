--Ranked rows based on specific ordering
select
	employee_id,
	first_name, 
	last_name, 
	salary,
	rank() over (order by salary desc) as rank
from employee_sample_2
GO

-- create a report to pull top n (n=5) earners in the company
WITH employee_ranking AS (
  SELECT
    employee_id,
    last_name,
    first_name,
    salary,
    RANK() OVER (ORDER BY salary DESC) as ranking
  FROM employee_sample_2
)
SELECT
  employee_id,
  last_name,
  first_name,
  salary
FROM employee_ranking
WHERE ranking <= 5
ORDER BY ranking
GO

-- list highest salary by department
WITH employee_ranking AS (
  SELECT
    employee_id,
    last_name,
    first_name,
    salary,
    dept_id,
    RANK() OVER (PARTITION BY dept_id ORDER BY salary DESC) as ranking
  FRom employee_sample_2
)
SELECT
  dept_id,
  employee_id,
  last_name,
  first_name,
  salary
FROM employee_ranking
WHERE ranking = 1
ORDER BY dept_id, last_name
GO

-- list first 50% rows in result set
with employee_ranking as (
select 
	employee_id,
	first_name,
	last_name,
	salary,
	ntile(2) over (order by salary desc) as ntile
from employee_sample_2
)
select *
from employee_ranking
where ntile = 1
GO

-- number rows in result
select
	employee_id,
	last_name,
	first_name,
	salary,
	ROW_NUMBER() over(order by employee_id) as position
from employee_sample_2
GO

-- Grouping with Rollup to give some kind of running total giving sum total of salaries per department and overall total
SELECT
  dept_id,
  expertise,
  SUM(salary) total_salary
FROM employee_sample_2
GROUP BY ROLLUP (dept_id, expertise);
GO

-- Sum of salaries in select departments
SELECT
  SUM (CASE
    WHEN dept_id = 'SALES'
    THEN salary
    ELSE 0 END) AS total_salary_sales_and_hr,
  SUM (CASE
    WHEN dept_id = 'IT'
    THEN salary
    ELSE 0 END) AS total_salary_it_and_support
FROM employee_sample_2
GO

-- Salaries grouped into 3 categories and counted
SELECT
  CASE
    WHEN salary <= 75000 THEN 'low'
    WHEN salary > 75000 AND salary <= 100000 THEN 'medium'
    WHEN salary > 100000 THEN 'high'
  END AS salary_category,
  count(*)
FROM    employee_sample_2
GROUP BY
  CASE
    WHEN salary <= 75000 THEN 'low'
    WHEN salary > 75000 AND salary <= 100000 THEN 'medium'
    WHEN salary > 100000 THEN 'high'
END
GO

-- match employees to line managers
WITH subordinate AS (
 SELECT 
   employee_id,
   first_name,
   last_name,
   manager_id
  FROM employee_sample_2
  WHERE employee_id = 110 -- id of the top hierarchy employee (CEO)
  
  UNION ALL
  
  SELECT 
    e.employee_id,
    e.first_name,
    e.last_name,
    e.manager_id
  FROM employee_sample_2 e
  JOIN subordinate s
  ON e.manager_id = s.employee_id
)
SELECT 
  t.employee_id,
  t.first_name,
  t.last_name,
  t.manager_id,
  CONCAT(p.first_name, ' ', p.last_name) as 'line_manager'
FROM subordinate t
LEFT JOIN employee_sample_2 p
on t.manager_id = p.employee_id
GO

-- running total of salaries
select 
	e.employee_id,
	e.first_name,
	e.last_name,
	e.salary,
	SUM(s.salary) over (order by s.salary) as 'cummlative_total'
from employee_sample_2 e
INNER JOIN employee_sample_2 s
on e.employee_id = s.employee_id