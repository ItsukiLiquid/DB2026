-- prelude
DROP TABLE IF EXISTS order_items;
DROP TABLE IF EXISTS orders;
DROP TABLE IF EXISTS products;
DROP TABLE IF EXISTS customers CASCADE ;

CREATE TABLE customers (
                           id       SERIAL PRIMARY KEY,
                           full_name TEXT    NOT NULL,
                           city      TEXT    NOT NULL,
                           is_vip    BOOLEAN NOT NULL DEFAULT FALSE
);

CREATE TABLE products (
                          id       SERIAL PRIMARY KEY,
                          name     TEXT          NOT NULL,
                          category TEXT          NOT NULL,
                          price    NUMERIC(10,2) NOT NULL
);

CREATE TABLE orders (
                        id          SERIAL PRIMARY KEY,
                        customer_id INTEGER NOT NULL REFERENCES customers(id),
                        order_date  DATE    NOT NULL,
                        status      TEXT    NOT NULL CHECK (status IN ('new', 'paid', 'shipped', 'cancelled'))
);

CREATE TABLE order_items (
                             id         SERIAL PRIMARY KEY,
                             order_id   INTEGER NOT NULL REFERENCES orders(id) ON DELETE CASCADE,
                             product_id INTEGER NOT NULL REFERENCES products(id),
                             quantity   INTEGER NOT NULL CHECK (quantity > 0),
                             unit_price NUMERIC(10,2) NOT NULL
);

INSERT INTO customers (full_name, city, is_vip) VALUES
                                                    ('Alice Akhmetova',   'Almaty',    TRUE),
                                                    ('Bauyrzhan Bek',     'Astana',    FALSE),
                                                    ('Carla Karim',       'Shymkent',  FALSE),
                                                    ('Dias Muratbayev',   'Almaty',    TRUE),
                                                    ('Elena Petrova',     'Karaganda', FALSE);

INSERT INTO products (name, category, price) VALUES
                                                 ('Mechanical Keyboard', 'Electronics', 35000.00),
                                                 ('Gaming Mouse',        'Electronics', 15000.00),
                                                 ('USB-C Cable',         'Electronics',  3000.00),
                                                 ('Office Desk',         'Furniture',   80000.00),
                                                 ('Ergonomic Chair',     'Furniture',   65000.00),
                                                 ('Bookshelf',           'Furniture',   40000.00),
                                                 ('Coffee Mug',          'Accessories',  2500.00),
                                                 ('Notebook',            'Accessories',  1200.00);

INSERT INTO orders (customer_id, order_date, status) VALUES
                                                         (1, DATE '2025-01-01', 'paid'),      
                                                         (1, DATE '2025-01-10', 'shipped'),    
                                                         (2, DATE '2025-01-12', 'new'),        
                                                         (3, DATE '2025-01-15', 'cancelled'),  
                                                         (4, DATE '2025-02-01', 'paid');       

INSERT INTO order_items (order_id, product_id, quantity, unit_price) VALUES
(1, 1, 1, 35000.00),  
(1, 3, 2,  3000.00),  
(1, 7, 1,  2500.00),  

(2, 2, 1, 15000.00), 
(2, 5, 1, 65000.00),  

(3, 4, 1, 80000.00), 

(4, 6, 2, 40000.00),  

(5, 1, 1, 35000.00),  
(5, 8, 5,  1200.00);  


SELECT * FROM customers;
SELECT * FROM products;
SELECT * FROM orders;
SELECT * FROM order_items;




-- task 1
create or replace view v_active_customers as
select id, full_name, city, is_vip
from customers
where is_vip = true;

select * from v_active_customers;
select * from customers;



-- task 2
create or replace view v_order_lines as
select oi.order_id, o.order_date, c.full_name as customer_name, p.name as product_name, category, oi.quantity * oi.unit_price as total
from order_items oi
join orders o on oi.order_id = o.id
join customers c on o.customer_id = c.id
join products p on oi.product_id = p.id;


select * from v_order_lines;



-- task 3
create or replace view v_almaty_customers as
select id, full_name, city, is_vip
from customers
where city = 'Almaty';

select * from v_almaty_customers; -- id 1,4 (Alice and Dias) is shown
-- a)
insert into v_almaty_customers (full_name, city, is_vip) values ('Nurdaulet Malik', 'Almaty', true); -- Added Nurdaulet Malik
select * from v_almaty_customers;

-- b)
update v_almaty_customers
set city = 'Almaty-67'
where full_name = 'Nurdaulet Malik' returning id, full_name, city, is_vip; -- Nurdaulet Malik is set to Almaty-67
select * from v_almaty_customers; -- now Nurdaulet is disappeared



-- task 4
-- a
create view v_paid_orders as
select * from orders
where status = 'paid';

-- b
create view v_recent_paid_orders as
select * from v_paid_orders
where order_date >= date '2025-01-10'
with local check option;


-- c
insert into v_recent_paid_orders (customer_id, order_date, status) values (7, '2026-11-18', 'new') returning id, customer_id, order_date, status;
-- for making view nonempty after updating
insert into v_recent_paid_orders (customer_id, order_date, status) values (7, '2026-11-19', 'paid') returning id, customer_id, order_date, status;

-- violates filter for local recent_paid order: ERROR:  новая строка нарушает ограничение-проверку для представления "v_recent_paid_orders"
-- Ошибочная строка содержит (5, 4, 2025-01-01, paid). 
update v_recent_paid_orders set order_date = '2025-01-01' where id = 5;

-- but this works, because local check option doesn't preserve preceedor's update filterings, only view filters. There is only one new order
update v_recent_paid_orders set status = 'cancelled' where id = 5;
select * from v_recent_paid_orders;

-- POV from cascaded view
drop view v_recent_paid_orders;

create view v_recent_paid_orders as
select * from v_paid_orders
where order_date >= date '2025-01-10'
with cascaded check option;

-- rollback to the initial value
update orders set status = 'paid' where id = 5;

-- now it doesnt work, because cascaded check option now preserves preceedor's filters for update/insert: ERROR:  новая строка нарушает ограничение-проверку для представления "v_paid_orders"
-- Ошибочная строка содержит (5, 4, 2025-02-01, cancelled). 
update v_recent_paid_orders set status = 'cancelled' where id = 5;




-- task 5
create view v_customer_orders as
select c.id, c.full_name, o.id as order_id, o.status
from customers c
join orders o on c.id = o.customer_id;

select * from v_customer_orders;

-- fails, because it is forbidden to update data in view involving more than 1 tables
-- ERROR:  изменить данные в представлении "v_customer_orders" нельзя
-- Представления, выбирающие данные не из одной таблицы или представления, не обновляются автоматически. 
update v_customer_orders set full_name = 'Itsuki Liquid' where full_name = 'Nurdaulet Malik';


-- task 6
create materialized view mv_vip_customers as
select id, full_name, city from customers
where is_vip = true
with data;

select * from mv_vip_customers;
-- update successfull
update customers set is_vip = false where id = 1;
-- yet view still has the row with id 1, because it is stored physically, so it needs refreshment.
select * from mv_vip_customers;

-- refreshed
refresh materialized view mv_vip_customers;
-- now it hided row with id = 1 (so view doesnt show it unless its vip status is false)
select * from mv_vip_customers;


-- task 7
create materialized view mv_sales_by_category as
select p.category, sum(oi.quantity * oi.unit_price) as sum
from products p
join order_items oi on oi.product_id = p.id
group by p.category
with no data;

-- error: MV isn't populated yet
-- ERROR:  материализованное представление "mv_sales_by_category" не было наполнено
-- HINT:  Примените команду REFRESH MATERIALIZED VIEW. 
select * from mv_sales_by_category;

-- now it works
refresh materialized view mv_sales_by_category;
select * from mv_sales_by_category;


-- task 8
create view v_city_customers as
select id, full_name, city
from customers;

-- basic view
select * from v_city_customers;

-- view will be replaced (updated) so there will be one appended city_upper column
create or replace view v_city_customers as
select id, full_name, city, upper(city) as city_upper
from customers;

select * from v_city_customers;


-- task 9
create role reporting;
create role report_user login; -- <-> create user report_user password '12345678';
grant select on v_order_lines, mv_sales_by_category to reporting;
grant reporting to report_user; -- initially, role reporting supports viewing two listed views, as we grant a user this role, users with this role inherit the acccesses from the role


-- task 10
create role app_owner; -- creates role app_owner
alter view v_order_lines owner to app_owner; -- transfers ownership to app_owner (postgres -> app_owner)
create role old_owner; -- new role old_owner
alter view v_city_customers owner to old_owner; -- transfers ownership to old_owner (postgres -> old_owner)
reassign owned by old_owner to app_owner; -- reassigns, or transfers all object owned by old_owner to app_owner
drop owned by old_owner; -- drop owned objects of old_owner (drop objects, which owner is old_role)

-- without reassign owned by or drop owned by, we can't drop role, because role has owned objects or unresolved dependencies