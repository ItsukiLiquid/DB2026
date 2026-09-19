-- prelude
CREATE TABLE IF NOT EXISTS departments ( 
  id SERIAL PRIMARY KEY, 
  department_name TEXT NOT NULL 
); 
CREATE TABLE IF NOT EXISTS employees ( 
  id SERIAL PRIMARY KEY, 
  name TEXT NOT NULL, 
  department TEXT,          -- for simple examples 
  department_id INT,        -- for examples with USING 
  salary NUMERIC(12,2), 
  active BOOLEAN DEFAULT TRUE, 
  city TEXT 
); 

 

CREATE TABLE IF NOT EXISTS students ( 
  id SERIAL PRIMARY KEY, 
  name TEXT NOT NULL, 
  age INT, 
  gpa NUMERIC(3,2), 
  active BOOLEAN DEFAULT TRUE, 
  city TEXT 
); 

-- task 1
insert into students(name, age) values
('Nurdaulet', 18);

update students
set age = age + 1
where name = 'Nurdaulet';

select name, age from students
where name = 'Nurdaulet';


-- task 2
insert into employees (salary, name, department) values
(67000, 'Furina', 'IT');

-- delete from employees where id = 67500;
insert into employees values
(default, 'Neuvillet', default, default, default, default, default); -- default values will be null
-- (67500, 'Neuvillet', 'HR'); <-- UNSPECIFIED column name will be ordered from id, name, department here


-- task 3
insert into employees (name, salary, city) values
('Mavuika', 55000, 'Natlan');
insert into employees (name, salary, city) values ('Mavuika', default, default);


-- task 4
insert into students (name, age, city)
select name, age, 'Almaty'
from (values
('Aruzhan', 19),
('Dias', 20)
) as s(name, age);


-- task 5
insert into students (name, age, city) values
('Asset', 19, 'London'),
('Islambek', 9, 'London'); -- added to retrieve some data

select * from students
-- prints where age > 18 or (age < 10 and city = London)
-- because and have more precedence than first or
where age > 18 or age < 10 and city = 'London';

select * from students
-- prints where (age > 18 or age < 10) and city = 'London', more correct version
where (age > 18 or age < 10) and city = 'London';



-- task 6

delete from employees where id=5; -- removing duplicate unspecified Mavuika
insert into employees (name, department, salary, active) values -- add some values
('Venti', 'IT', 55000, false),
('Zhongli', 'Finance', 64000, true),
('Raiden', 'Finance', 49000, false),
('Nahida', 'IT', 75000, true),
('Colombina', 'Finance', 56000, true),
('Tsaritsa', 'Boss', 100000, true);
select * from employees;

update employees
set salary = salary * 1.1
where department='IT' and active = true
returning id, name, department, salary as salary_upd;


-- task 7
-- renaming Finance -> Marketing to ensure there is at least one employee with appropriate dept
update employees
set department='Marketing'
where department='Finance'
returning id, name, department as dept_newName;

--inserting existing departments of employees to departments table
insert into departments (department_name)
select distinct department
from employees
where department is not null
returning id, department_name as dept_name;

-- setting dept_id to employees because they were left
update employees
set department_id = departments.id
from departments
where employees.department = departments.department_name
returning name, department, department_id;

delete from employees
using departments
where employees.department_id = departments.id
and departments.department_name = 'Marketing'
returning employees.id, employees.name, employees.department_id;



-- task 8
insert into employees (name, salary) values
('Ronova', 95000)
returning id, name, salary*12 as annual;


-- task 9
-- adding HR department

insert into departments (department_name) values ('HR');
update employees
set department='HR', department_id = departments.id
from departments
where department_name = 'HR' and employees.department is null
returning employees.id, employees.name, employees.department, employees.department_id;

-- setting default 50000 salary to null employees
update employees
set salary=50000 where salary is null
returning id, name, salary;

update employees
set salary = salary + 5000
where department = 'HR'
returning id, name, salary-5000 as old_salary, salary as new_salary;


-- task 10

update students
set gpa = case
	when id = 1 then 3.92
	when id = 2 then 1.95
	when id = 3 then 1.5
	when id = 4 then 2.7
	when id = 5 then 2.64
end
where id between 1 and 5
returning id, name, gpa;

delete from students
where gpa < 2
returning id, name, gpa;

select count(*) from students;