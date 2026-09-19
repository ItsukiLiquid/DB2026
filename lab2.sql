-- Task 1
create table departments(
  dept_id serial primary key,
dept_name varchar(255) not null unique
);


-- Task 2
create table employees  (
  emp_id serial primary key,
  first_name varchar(50) not null,
  last_name varchar(50) not null,
  salary numeric(12, 2),
  dept_id int references departments(dept_id)
);


-- Task 3
alter table employees
add column email varchar(100) unique;

-- Task 4
alter table employees
rename column email to work_email;


-- Task 5
alter table employees
alter column work_email type text;

-- Task 6
alter table employees
alter column work_email set default 'UNKNOWN';


-- Task 7
alter table employees
drop column work_email;


-- Task 8
alter table employees
add constraint salary_positive check (salary > 0);


-- Task 9
alter table employees
alter column salary set not null;


-- Task 10
alter table employees
alter column salary drop not null;


-- Task 11
create table projects (
  project_id serial primary key,
  project_name varchar(100) not null unique,
  budget numeric(12, 2) check (budget > 1000)
);


-- Task 12
create table employee_projects (
  emp_id int references employees(emp_id) on delete cascade,
  project_id int references projects(project_id) on delete cascade,
  primary key (emp_id, project_id)
);


-- Task 13
alter table employees
add constraint employee_unique unique (first_name, last_name, dept_id);


-- Task 14
create index idx_employees_last_name on employees(last_name);


-- Task 15
insert into departments (dept_name) values
  ('IT'),
  ('HR'),
  ('Finance');


-- Task 16
insert into employees (first_name, last_name, salary, dept_id)
values
('Nurdaulet', 'Malik', 6700, 1),
('Nurmerei', 'Almurat', 6500, 2),
('Islambek', 'Alpamysh', 5800, 3),
('Asset', 'Amal', 6700, 1),
('Altynbek', 'Amankozha', 5800, 3);


-- Task 17
update employees
set salary = salary * 1.1 where dept_id = 1;


-- Task 18
select (first_name || ' ' || last_name) as name, salary
from employees
order by salary desc;


-- Task 19
delete from employees where salary < 1000;


-- Task 20
drop table employee_projects;