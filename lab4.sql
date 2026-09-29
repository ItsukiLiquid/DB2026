---- prelude

-- DROP TABLE IF EXISTS grades CASCADE;
-- DROP TABLE IF EXISTS students CASCADE;
-- DROP TABLE IF EXISTS products CASCADE;
-- DROP TABLE IF EXISTS sales CASCADE;
-- DROP TABLE IF EXISTS web_events_2024 CASCADE;
-- DROP TABLE IF EXISTS web_events_2025 CASCADE;

-- -- students 
-- CREATE TABLE students (
--   id          SERIAL PRIMARY KEY,
--   full_name   VARCHAR(120) NOT NULL,
--   group_name  VARCHAR(20)  NOT NULL,    -- example: CS-21, CS-22, SE-21, SE-22
--   admitted_at DATE         NOT NULL,
--   gpa         NUMERIC(3,2),        
--   scholarship BOOLEAN      NOT NULL DEFAULT FALSE
-- );

-- INSERT INTO students (full_name, group_name, admitted_at, gpa, scholarship) VALUES
-- ('Aliya Tulegen',     'CS-21', '2023-09-01', 3.80, TRUE),
-- ('Dias Murat',        'CS-21', '2023-09-01', 3.50, FALSE),
-- ('Nurlan Zhaksy',     'CS-21', '2023-09-01', NULL,  FALSE),
-- ('Samat Kassym',      'CS-21', '2023-09-01', 2.90, FALSE),

-- ('Aruzhan Akyl',      'CS-22', '2023-09-01', 3.95, TRUE),
-- ('Daniyar Sapar',     'CS-22', '2023-09-01', 3.10, FALSE),
-- ('Ainur Bek',         'CS-22', '2023-09-01', 3.45, FALSE),
-- ('Miras Ali',         'CS-22', '2023-09-01', 3.70, TRUE),

-- ('Kamila Nur',        'SE-21', '2024-09-01', 3.85, TRUE),
-- ('Timur Adil',        'SE-21', '2024-09-01', 2.75, FALSE),
-- ('Zarina Omar',       'SE-21', '2024-09-01', 3.20, FALSE),
-- ('Adlet Serik',       'SE-21', '2024-09-01', NULL,  FALSE),

-- ('Aruzhan Tilek',     'SE-22', '2024-09-01', 3.60, TRUE),
-- ('Kairat Beks',       'SE-22', '2024-09-01', 3.00, FALSE),
-- ('Dana Sadyk',        'SE-22', '2024-09-01', 3.25, FALSE),
-- ('Alibek Sam',        'SE-22', '2024-09-01', 3.90, TRUE);


-- -- grades 
-- CREATE TABLE grades (
--   id         SERIAL PRIMARY KEY,
--   student_id INT NOT NULL REFERENCES students(id) ON DELETE CASCADE,
--   course     VARCHAR(80) NOT NULL,      -- 'Databases', 'Algorithms' и т.п.
--   score      INT NOT NULL CHECK (score BETWEEN 0 AND 100),
--   exam_date  DATE NOT NULL
-- );

-- INSERT INTO grades (student_id, course, score, exam_date) VALUES
-- (1,  'Databases', 90, '2025-05-10'),
-- (1,  'Databases', 88, '2025-06-10'),

-- (2,  'Databases', 84, '2025-05-10'),
-- (2,  'Databases', 80, '2025-06-10'),

-- (3,  'Databases', 70, '2025-05-10'),
-- (3,  'Databases', 75, '2025-06-10'),

-- (4,  'Databases', 60, '2025-05-10'),
-- (4,  'Databases', 65, '2025-06-10'),

-- (5,  'Databases', 95, '2025-05-10'),
-- (5,  'Databases', 90, '2025-06-10'),

-- (6,  'Databases', 78, '2025-05-10'),
-- (6,  'Databases', 82, '2025-06-10'),

-- (7,  'Databases', 85, '2025-05-10'),
-- (7,  'Databases', 86, '2025-06-10'),

-- (8,  'Databases', 81, '2025-05-10'),
-- (8,  'Databases', 79, '2025-06-10'),

-- (9,  'Databases', 92, '2025-05-10'),
-- (9,  'Databases', 90, '2025-06-10'),

-- (10, 'Databases', 83, '2025-05-10'),
-- (10, 'Databases', 84, '2025-06-10'),

-- (1,  'Algorithms', 78, '2025-04-20'),
-- (2,  'Networks',   65, '2025-03-15'),
-- (9,  'Algorithms', 88, '2025-04-22'),
-- (16, 'Databases',  88, '2025-06-12'),
-- (16, 'Databases',  90, '2025-06-25');  

-- -- products
-- CREATE TABLE products (
--   id        SERIAL PRIMARY KEY,
--   title     VARCHAR(200) NOT NULL,
--   category  VARCHAR(60)  NOT NULL,
--   price     NUMERIC(10,2) NOT NULL CHECK (price >= 0),
--   in_stock  BOOLEAN NOT NULL DEFAULT TRUE
-- );

-- INSERT INTO products (title, category, price, in_stock) VALUES
-- ('Pro Keyboard',           'Electronics', 129.99, TRUE),
-- ('UltraPhone Pro',         'Electronics', 999.99, TRUE),
-- ('Laptop Air',             'Electronics', 899.99, FALSE),
-- ('Laptop Pro 13',          'Electronics', 1299.99, TRUE),
-- ('USB-C Hub Pro',          'Electronics', 119.00, TRUE),
-- ('Wireless Mouse',         'Electronics', 45.00,  TRUE),
-- ('4K Monitor',             'Electronics', 349.00, TRUE),
-- ('Budget Tablet',          'Electronics', 179.00, TRUE),
-- ('Tablet Mini',            'Electronics', 399.00, TRUE),
-- ('Gaming Headset',         'Electronics', 149.00, TRUE),

-- ('Pro Blender 1500',       'Home',        149.00, TRUE),
-- ('Chef Knife Pro',         'Home',         89.00, TRUE),
-- ('Vacuum Cleaner',         'Home',        199.00, FALSE),

-- ('Action Camera PRO',      'Electronics', 299.00, TRUE),
-- ('Mountain Bike',          'Sports',     1499.00, TRUE);

-- -- sales 
-- CREATE TABLE sales (
--   id         SERIAL PRIMARY KEY,
--   customer   VARCHAR(120) NOT NULL,
--   region     VARCHAR(40)  NOT NULL,     -- North / South / East / West
--   amount     NUMERIC(12,2) NOT NULL CHECK (amount >= 0),
--   status     VARCHAR(20)  NOT NULL,     -- 'paid' | 'pending' | 'cancelled'
--   created_at TIMESTAMP NOT NULL
-- );

-- INSERT INTO sales (customer, region, amount, status, created_at) VALUES
-- -- NORTH 
-- ('Acme Corp',   'North', 25000, 'paid',     '2025-05-01 10:00'),
-- ('Zenit LLC',   'North', 40000, 'paid',     '2025-05-03 13:20'),
-- ('Polar Ltd',   'North', 38000, 'paid',     '2025-05-07 09:45'),
-- ('Nova Partners','North',15000, 'paid',     '2025-05-15 10:00'),
-- ('Beta Group',  'North', 12000, 'cancelled','2025-05-12 12:00'),
-- ('Acme Corp',   'North',  9000, 'pending',  '2025-05-10 11:00'),

-- -- SOUTH 
-- ('Delta Inc',   'South', 15000, 'paid',     '2025-05-02 14:00'),
-- ('Omega Co',    'South', 20000, 'paid',     '2025-05-05 15:30'),
-- ('Gamma LLC',   'South', 25000, 'paid',     '2025-05-07 16:00'),
-- ('Omega Co',    'South',  6000, 'pending',  '2025-05-09 12:12'),

-- -- EAST 
-- ('Sunrise Ltd', 'East',  60000, 'paid',     '2025-05-01 08:10'),
-- ('Aurora Corp', 'East',  55000, 'paid',     '2025-05-04 09:30'),
-- ('Orion GmbH',  'East',   8000, 'pending',  '2025-05-06 10:00'),
-- ('Equator Ltd', 'East',  12000, 'cancelled','2025-05-17 10:00'),

-- -- WEST 
-- ('WestCo',      'West',  45000, 'paid',     '2025-05-02 11:11'),
-- ('WestCo',      'West',  30000, 'paid',     '2025-05-08 11:12'),
-- ('Sunrise Ltd', 'West',   8000, 'paid',     '2025-05-18 10:00'),
-- ('Foxtrot',     'West',   9000, 'pending',  '2025-05-10 11:13'),
-- ('Foxtrot',     'West',   5000, 'cancelled','2025-05-11 11:14');

-- -- web events
-- CREATE TABLE web_events_2024 (
--   id         SERIAL PRIMARY KEY,
--   user_id    INT NOT NULL,
--   event_type VARCHAR(40) NOT NULL,      -- 'view','click','purchase'
--   created_at TIMESTAMP NOT NULL
-- );

-- CREATE TABLE web_events_2025 (
--   id         SERIAL PRIMARY KEY,
--   user_id    INT NOT NULL,
--   event_type VARCHAR(40) NOT NULL,
--   created_at TIMESTAMP NOT NULL
-- );

-- -- 2024 
-- INSERT INTO web_events_2024 (user_id, event_type, created_at) VALUES
-- (101, 'view',     '2024-06-01 10:00'),
-- (101, 'purchase', '2024-06-01 10:05'),
-- (102, 'click',    '2024-07-02 11:00'),
-- (102, 'purchase', '2024-07-02 11:10'),
-- (103, 'view',     '2024-08-03 12:00'),
-- (104, 'purchase', '2024-08-10 09:00'),
-- (106, 'purchase', '2024-09-05 15:00'),
-- (108, 'purchase', '2024-10-11 17:00');

-- -- 2025 
-- INSERT INTO web_events_2025 (user_id, event_type, created_at) VALUES
-- (102, 'purchase', '2025-01-05 10:00'),
-- (109, 'view',     '2025-02-01 10:10'),
-- (110, 'purchase', '2025-02-14 11:11'),
-- (111, 'click',    '2025-03-01 09:00'),
-- (112, 'purchase', '2025-03-03 13:00'),
-- (113, 'purchase', '2025-04-01 15:00'),
-- (114, 'purchase', '2025-04-02 15:10'),
-- (116, 'purchase', '2025-04-04 17:00');




-- task 1
select distinct group_name
from students
order by group_name asc;


-- task 2
select * from products
where category= 'Electronics' and price between 100 and 500 and in_stock = true
order by price asc, title asc;


-- task 3
select * from products
order by price desc
limit 5 offset 5; -- page N <-> offset = limit_val * N

-- task 4
select * from products
where title ilike '%pro%' and price < 1000
order by title asc
limit 20;

-- task 5
select group_name, count(*) as quantity
from students
group by group_name
order by quantity desc, group_name asc;

-- task 6
select region, sum(amount) as total
from sales
where status = 'paid'
group by region
having sum(amount) > 100000
order by total desc;


-- task 7
select student_id, avg(score) as average_score, count(*) as attempts
from grades
where course = 'Databases'
group by student_id
having count(score) >= 2 and avg(score) >= 85
order by average_score desc
-- limit 10 offset 10; -- is temporarily disables because there are only 5 rows

-- task 8
-- part 1
select count(distinct status) as unique_statuses from sales;
-- part 2
select distinct status
from sales
order by status asc;


-- task 9
select user_id, event_type
from web_events_2024
where event_type = 'purchase'

union

select user_id, event_type
from web_events_2025
where event_type = 'purchase'

order by user_id asc;


-- task 10
select full_name, gpa
from students
order by gpa desc nulls last, full_name asc
limit 30;



-- task 11
insert into students (full_name, group_name, admitted_at, gpa, scholarship) values
('Nurdaulet Malik', 'CS-21', '2025-09-01', 3.92, true)
returning id, full_name, group_name, admitted_at, gpa, scholarship;



select group_name, count(*) as students_quantity, avg(gpa) as avg_gpa
from students
where group_name = 'CS-21'
group by group_name
order by group_name;

select id, full_name, group_name, gpa
from students
where group_name = 'CS-21'
order by gpa desc nulls last, full_name asc;