-- NOT FINISHED (6/11, 2026-10-08 22:07 Legion game zone 2+1, 1st pc) => FINISHED (11/11, 2026-10-09 00:32 Kbtu 2 corpus 7B)

-- -- prelude
-- CREATE TABLE customers (
--                            id        serial PRIMARY KEY,
--                            first_name text,
--                            last_name  text,
--                            email      text,
--                            city       text
-- );

-- INSERT INTO customers (first_name,last_name,email,city) VALUES
--                                                             ('Ayan','Akhmetov','ayan@example.com','Almaty'),
--                                                             ('Dana','Sadykova','DANA@MAIL.KZ','Astana'),
--                                                             ('Jasur','Tulegenov','jasur@uni.edu','Shymkent'),
--                                                             ('Maria','Ivanova','maria@site.kz','Almaty'),
--                                                             ('Timur','Bek','timur@nowhere.kz','Karaganda'),
--                                                             ('Alina','Orlova',NULL,'astana');  -- нижний регистр для ILIKE


-- CREATE TABLE products (
--                           id       serial PRIMARY KEY,
--                           name     text,
--                           category text,
--                           price    numeric(10,2),
--                           status   text,
--                           rating   int,
--                           sku      text
-- );

-- INSERT INTO products (name,category,price,status,rating,sku) VALUES
--                                                                  ('Phone','Electronics', 900,'active',   5,'EL-001-PHN'),
--                                                                  ('Laptop','Electronics',1500,'active',  5,'EL-002-LPT'),
--                                                                  ('Watch','Wearables',   200,'draft',    4,'AC-010-WCH'),
--                                                                  ('Camera','Electronics',450,'active',   3,'EL-011-CAM'),
--                                                                  ('Mouse','Accessories',  20,'archived', 5,'AC-100-MSE'),
--                                                                  ('Keyboard','Accessories',35,'active',  4,'AC-200-KBD');


-- CREATE TABLE orders (
--                         id         serial PRIMARY KEY,
--                         customer_id int REFERENCES customers(id),
--                         product_id  int REFERENCES products(id),
--                         quantity    int,
--                         order_date  date
-- );

-- INSERT INTO orders (customer_id,product_id,quantity,order_date) VALUES
--                                                                     (1,1, 2,'2025-01-05'),
--                                                                     (2,1,10,'2025-02-01'),
--                                                                     (3,2, 1,'2025-01-15'),
--                                                                     (5,4, 0,'2025-02-14');  -- ноль для демонстрации NULLIF


-- CREATE TABLE competitor_offers (
--                                    product_id int REFERENCES products(id),
--                                    price      numeric(10,2)
-- );

-- INSERT INTO competitor_offers (product_id,price) VALUES
--                                                      (1,800),(1,950),
--                                                      (2,1400),
--                                                      (3,NULL),
--                                                      (4,480),
--                                                      (5,25),
--                                                      (6,30);


-- task 1
select id, name, price, ROUND(price*1.12, 2) as price_with_vat, POWER(2, rating) as score_pow
from products;

-- task 2
select id, name, floor(price/100) as floor_hundreds, ceil(price/3) as ceil_div3
from products;

-- task 3
select id, (first_name || ' ' || last_name) as full_name, length(first_name || ' ' || last_name) as name_len, split_part(email, '@', 2) as email_domain
from customers;

-- task 4
select id, first_name, city
from customers
where city ilike 'astana';

-- task 5
select id, name, price,
case
  when price >= 1000 then 'premium'
  when price >= 200 then 'mid'
else 'budget'
end as price_segment
from products;

-- task 6
select 
o.id,
c.first_name as customer,
p.name as product,
o.quantity as quantity,
p.price / nullif(o.quantity, 0) as unit_price, 
coalesce(c.email, 'n/a') as email_safe
from orders o
join customers c on o.customer_id = c.id
join products p on o.product_id = p.id;


-- task 7
select category, count(*) as cnt, round(avg(price), 2) as avg_price
from products
group by category
having avg(price) > 100
order by avg_price desc;

-- task 8
select p.id, p.name
from products p
where exists (
  select 1
  from orders o
  where o.product_id = p.id
);

-- task 9
select c.id, c.first_name, c.last_name
from customers c
where c.id not in (
  select o.customer_id
  from orders o
);

-- task 10
select p.id, p.name, p.price
from products p
where p.price > any (
  select co.price
  from competitor_offers co
  where co.product_id = p.id
  and price is not null
);

-- task 11

insert into customers (first_name, last_name, email, city) values
	('Nurdaulet', 'Malik', 'minafeed645@gmail.com', 'Almaty'),
	('Asset', 'Amal', 'a_amal@kbtu.kz', 'almaty'),
	('Islambek', 'Alpamysh', null, 'ALMATY'),
	('Nurmerei', 'Almurat', 'nurtraktor@mail.kz', 'almatY')
returning id, (first_name || ' ' || last_name) as name, coalesce(email, 'n/a'), city; 
