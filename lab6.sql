-- task 1
create table if not exists students(
	id serial primary key not null,
	full_name text not null,
	enrolled_at date default CURRENT_DATE,
	email text
);
-- works well
insert into students (full_name, enrolled_at, email) values
('Nurdaulet Malik', '2025-08-25', 'minafeed645@gmail.com')
returning id, full_name, enrolled_at, email;

-- still works well, entolled_at = 2026-10-11, because today is October 11th
insert into students (full_name, email) values
('Islambek Alpamysh', 'i_alpamysh@kbtu.kz')
returning id, full_name, enrolled_at, email;

-- throws an error: значение NULL в столбце "full_name" отношения "students" нарушает ограничение NOT NULL
insert into students (enrolled_at, email) values
('2025-08-27', 'shrek@gmail.com')
returning id, full_name, enrolled_at, email;


-- task 2
create table if not exists courses(
	course_id integer primary key,
	course_name text not null
);
-- works well: course_id = 1 DNE
insert into courses(course_id, course_name) values
(1, 'DB')
returning course_id, course_name;

-- throws an error ERROR:  повторяющееся значение ключа нарушает ограничение уникальности "courses_pkey"
-- Ключ "(course_id)=(1)" уже существует. 
insert into courses(course_id, course_name) values
(1, 'ADS')
returning course_id, course_name;
-- primary key must be unique for all elements, even if the other records are exactly the same, they are different entities in the table


-- task 3
create table if not exists passengers(
	passenger_id serial primary key,
	email text unique
);
-- works well
insert into passengers (email) values ('test@gmail.com') returning passenger_id, email;

-- throwa an ERROR:  повторяющееся значение ключа нарушает ограничение уникальности "passengers_email_key"
-- Ключ "(email)=(test@gmail.com)" уже существует. 
insert into passengers (email) values ('test@gmail.com') returning passenger_id, email;

-- works well
insert into passengers (email) values (null) returning passenger_id, email;
-- also works, because null is uncomparable type of data, or missing/unknown value, so multiple nulls allowed
insert into passengers (email) values (null) returning passenger_id, email;


-- task 4
create table if not exists employees(
	emp_id serial primary key,
	age int check (age >= 18),
	salary numeric(10, 2) check (salary > 0)
);
-- causes an error, because age < 18: ERROR:  новая строка в отношении "employees" нарушает ограничение-проверку "employees_age_check"
-- Ошибочная строка содержит (2, 16, null).
insert into employees (age, salary) values (16, null) returning emp_id, age, salary;

-- causes an error, because salary = 0: ERROR:  новая строка в отношении "employees" нарушает ограничение-проверку "employees_salary_check"
-- Ошибочная строка содержит (3, null, 0.00). 
insert into employees (age, salary) values (null, 0) returning emp_id, age, salary;

-- works well
insert into employees (age, salary) values (30, 5000.00) returning emp_id, age, salary;


-- task 5
create table if not exists products(
	product_id serial primary key,
	regular_price numeric(10, 2) not null,
	discount_price numeric(10, 2) not null,
	check (discount_price < regular_price)
);

-- error: disc_price > regular_price, expected disc_price < reg_price (discount price is bigger than regular)
insert into products (regular_price, discount_price) values (100, 150) returning product_id, regular_price, discount_price;

-- works well
insert into products (regular_price, discount_price) values (150, 100) returning product_id, regular_price, discount_price;


-- task 6
create table if not exists customers(
	customer_id serial primary key,
	full_name text not null
);

create table if not exists orders(
	order_id serial primary key,
	customer_id int not null,
	order_total numeric(10, 2) check (order_total > 0),
	foreign key (customer_id) references customers(customer_id)
);

-- throws an error: no customer with id = 1 exists in the table.
insert into orders(customer_id, order_total) values (1, 67) returning order_id, customer_id, order_total;

-- real case
insert into customers (full_name) values ('Nurdaulet Malik') returning customer_id, full_name;
insert into orders(customer_id, order_total) values (1, 67) returning order_id, customer_id, order_total;

-- First case is failed because we tried to make an order for a person who didn't exist in customer's table
-- In second case we have a customer with id = 1, thus we can make a order for this customer


-- task 7
create table if not exists tickets(
	ticket_id serial primary key,
	price numeric(10, 2),
	constraint positive_price check (price > 0)
);

-- throws an error because row doesn't satisfy constraint positive_price: -5 < 0 => false
insert into tickets(price) values (-5) returning ticket_id, price;

alter table tickets
drop constraint positive_price;

-- as constraint doesn't check price > 0 every value can be inserted without any validation.
-- naming constraints is useful in way to understand the idea, to handle (add/drop) efficiently
insert into tickets(price) values (-5) returning ticket_id, price;


-- task 8
create table accounts(
	account_id serial primary key,
	balance numeric(12, 2),
	email text
);

alter table accounts
add constraint positive_balance check (balance >= 0);

alter table accounts
add constraint unique_email unique(email);

-- works well
insert into accounts(balance, email) values (67, 'minafeed645@gmail.com') returning account_id, balance, email;

-- violates unique constraint of email, therefore denied to insert
insert into accounts(balance, email) values (77, 'minafeed645@gmail.com') returning account_id, balance, email;

-- violates positiveness of balance, because balance < 0, therefoe denied to insert
insert into accounts(balance, email) values (-1, 'shrek@gmail.com') returning account_id, balance, email;

-- adding constraints is important because it validates data, or removes incorrect/invalid/unique records so far
-- for instance: it contains users whose balance is non-negative and have distinct emails etc.



-- task 9
create table if not exists drivers(
	driver_id serial primary key,
	license_number text not null,
	phone_number text
);

insert into drivers(license_number, phone_number) values (null, '+67') returning driver_id, license_number, phone_number;
insert into drivers(license_number, phone_number) values ('67VesnaGenshin08', null) returning driver_id, license_number, phone_number;

-- first one fails because it violates non null rule of license_number: it must contain data
-- second one passes because there is no restriction to phone_number to be null

-- not null enforces value to be not null, literally. More precisely, it means that value should be some data, like any text/number, anything except null


-- task 10
create table if not exists user_profiles(
	user_id serial primary key,
	email text not null,
	first_name text not null
);

alter table user_profiles
add constraint valid_email check (position('@' in email) > 1);

alter table user_profiles
add constraint valid_email2 check (email like '_%@%'); -- another variant

insert into user_profiles (email, first_name) values ('alice@gmail.com', 'Alice') returning user_id, email, first_name;
insert into user_profiles (email, first_name) values ('not_an_email', 'Bob') returning user_id, email, first_name;


-- insert 2 should fail, because not_an_email fails email validation, where expected to be '@' sign.
-- those constraints help to validate and verify correct email addresses of users to use in the future.