-- prelude

DROP TABLE IF EXISTS order_items    CASCADE;
DROP TABLE IF EXISTS orders         CASCADE;
DROP TABLE IF EXISTS products       CASCADE;
DROP TABLE IF EXISTS addresses      CASCADE;
DROP TABLE IF EXISTS customers      CASCADE;
DROP TABLE IF EXISTS articles       CASCADE;
DROP TABLE IF EXISTS logs           CASCADE;
DROP TABLE IF EXISTS events         CASCADE;

CREATE TABLE customers (
                           id          BIGSERIAL PRIMARY KEY,
                           name        TEXT        NOT NULL,
                           email       TEXT        NOT NULL UNIQUE,   
                           created_at  DATE        NOT NULL
);

CREATE TABLE addresses (
                           id           BIGSERIAL PRIMARY KEY,
                           customer_id  BIGINT     NOT NULL REFERENCES customers(id),
                           city         TEXT       NOT NULL,
                           street       TEXT       NOT NULL
);

CREATE TABLE products (
                          id      BIGSERIAL PRIMARY KEY,
                          name    TEXT            NOT NULL,
                          category TEXT           NOT NULL,
                          price   NUMERIC(10,2)   NOT NULL
);

CREATE TABLE orders (
                        id           BIGINT PRIMARY KEY,
                        customer_id  BIGINT            NOT NULL REFERENCES customers(id),
                        created_at   TIMESTAMP         NOT NULL,
                        status       TEXT              NOT NULL CHECK (status IN ('new','paid','shipped','canceled')),
                        total_amount NUMERIC(12,2)     NOT NULL
);

CREATE TABLE order_items (
                             order_id   BIGINT      NOT NULL REFERENCES orders(id),
                             product_id BIGINT      NOT NULL REFERENCES products(id),
                             qty        INT         NOT NULL,
                             price      NUMERIC(10,2) NOT NULL,
                             PRIMARY KEY (order_id, product_id)
);

CREATE TABLE articles (
                          id            BIGSERIAL PRIMARY KEY,
                          title         TEXT        NOT NULL,
                          body          TEXT        NOT NULL,
                          published_at  TIMESTAMP   NOT NULL
);

CREATE TABLE logs (
                      id           BIGSERIAL PRIMARY KEY,
                      customer_id  BIGINT      REFERENCES customers(id),
                      action       TEXT        NOT NULL,
                      payload      JSONB       NOT NULL,
                      created_at   TIMESTAMP   NOT NULL
);

CREATE TABLE events (
                        id     BIGSERIAL PRIMARY KEY,
                        room   TEXT       NOT NULL,
                        period TSRANGE    NOT NULL               
);


-- ---------- customers ----------
INSERT INTO customers (name, email, created_at)
SELECT 'User '||gs,
       'user'||gs||'@ex.com',
       DATE '2024-01-01' + ((gs % 180))  
FROM generate_series(1, 10000) AS gs;

-- ---------- addresses ----------
INSERT INTO addresses (customer_id, city, street)
SELECT c.id,
       CASE (c.id % 5)
           WHEN 0 THEN 'Almaty'
           WHEN 1 THEN 'ALMATY'
           WHEN 2 THEN 'almaty'
           WHEN 3 THEN 'Astana'
           ELSE 'Shymkent'
           END,
       'Street '||((random()*1000)::int)
FROM customers c;

-- ---------- products ----------
INSERT INTO products (name, category, price)
SELECT 'Product '||gs,
       (ARRAY['Electronics','Books','Grocery','Furniture','Toys'])[(gs % 5)+1],
       round((1000 + random()*500000)::numeric, 2)
FROM generate_series(1, 1000) AS gs;

-- ---------- orders----------
INSERT INTO orders (id, customer_id, created_at, status, total_amount)
SELECT 200000 + gs,                                      
       1 + (random()*9999)::int,
       TIMESTAMP '2025-01-01'
           + (gs % 180) * INTERVAL '1 day'
           + (random()*86400 || ' seconds')::interval,
       (ARRAY['new','paid','shipped','canceled'])[1 + (random()*3)::int],
       round((10000 + random()*500000)::numeric, 2)
FROM generate_series(1, 100000) AS gs;

-- ---------- order_items ----------
WITH pm AS (SELECT max(id) AS n FROM products)
INSERT INTO order_items (order_id, product_id, qty, price)
SELECT o.id,
       ((o.id * 97 + s * 13) % pm.n) + 1 AS product_id,
       1 + (random()*3)::int          AS qty,
       p.price
FROM orders o
         CROSS JOIN generate_series(1, 3) AS s
         CROSS JOIN pm
         JOIN products p ON p.id = ((o.id * 97 + s * 13) % pm.n) + 1;

-- ---------- articles ----------
INSERT INTO articles (title, body, published_at)
SELECT 'Article '||gs,
       'Body '||gs,
       TIMESTAMP '2025-01-01' + (gs % 180) * INTERVAL '1 day'
FROM generate_series(1, 10000) AS gs;

-- ---------- logs ----------
INSERT INTO logs (customer_id, action, payload, created_at)
SELECT 1 + (random()*9999)::int,
       (ARRAY['login','search','purchase'])[1 + (random()*2)::int],
       jsonb_build_object(
               'ip', '10.0.'||(gs % 255)||'.'||(1+(gs%200)),
               'success', (random() > 0.2),
               'tags', jsonb_build_array('auth','web'),
               'props', jsonb_build_object(
                       'browser', (ARRAY['Chrome','Safari','Firefox'])[1+(gs%3)],
                       'os', (ARRAY['Windows','macOS','Linux'])[1+((gs+1)%3)]
                        )
       ),
       TIMESTAMP '2025-01-01' + (gs % 180) * INTERVAL '1 day'
FROM generate_series(1, 100000) AS gs;

-- ---------- events ----------
INSERT INTO events (room, period)
SELECT lpad(((gs % 300)+100)::text, 3, '0') AS room,
       tsrange(
               TIMESTAMP '2025-11-01' + (gs % 7) * INTERVAL '1 day'
                   + ((gs % 480) * 3) * INTERVAL '1 minute',
               TIMESTAMP '2025-11-01' + (gs % 7) * INTERVAL '1 day'
                   + (((gs % 480) * 3) + 30) * INTERVAL '1 minute',
               '[)'
       )
FROM generate_series(1, 50000) AS gs;



-- task 1
-- without index: 65,97 ms (avg time)
explain (analyze, buffers)
select * from orders
where created_at between '2025-03-01' and '2025-03-30 23:59:59';

-- with index, avg time 8,289 ms
create index if not exists index_order_created
on orders
using btree(created_at);

explain (analyze, buffers)
select * from orders
where created_at between '2025-03-01' and '2025-03-30 23:59:59';


-- task 2
-- without index, exec_time: 5,911 ms using max-heap sort
explain analyze
select * from articles
order by published_at desc
limit 50;


-- with index scan backwards, exec_time: 3,058
create index index_published
on articles
using btree(published_at);

explain analyze
select * from articles
order by published_at desc
limit 50;



-- task 3
-- without index: 1,336 ms
explain analyze
select * from articles
where title = 'Article 7';


-- with hash index: 0.622 ms (the difference is small, because SeqScan for 10k elements isn't expensive)
create index index_hash_title
on articles
using hash(title);

explain analyze
select * from articles
where title = 'Article 7';



-- task 4
-- without hash index (0,194 ms)
explain analyze
select * from products where name = 'Product 9';

-- with hash index (0,115 ms, 1.67x faster)
create index if not exists index_hash_name on products using hash(name);
explain analyze
select * from products where name = 'Product 9';


-- task 5
-- without index: 27,515 ms exec_time, 4,302 ms planning time
explain analyze
select * from orders where customer_id=746 and created_at between '2025-06-01' and '2025-06-30 23:59:59' order by created_at;

-- with index: 0,462 ms exec_time, 5,606 ms planning time: 59,56x faster!
create index index_composite_id_time on orders using btree(customer_id, created_at);
explain analyze
select * from orders where customer_id=746 and created_at between '2025-06-01' and '2025-06-30 23:59:59' order by created_at;


-- task 6
-- without index (0,420 ms exec_time, 0,175 ms plan_time)
explain analyze
select * from orders where status = 'paid' order by created_at desc limit 100;


-- with index: (0,288 ms exec_time, 0.243 ms plan_time)
create index index_composite_status_created on orders using btree(status, created_at);
explain analyze
select * from orders where status = 'paid' order by created_at desc limit 100;


-- task 7
-- without index (sort by price desc, then SeqScan with 1,365 ms exec_time):
explain analyze
select * from products where category = 'Electronics' order by price desc limit 100;

-- with index: (no sort, direct index scan with 0,938 ms exec_time)
create index index_descending_price_category on products using btree(category, price desc);
explain analyze
select * from products where category = 'Electronics' order by price desc limit 100;


-- task 8
insert into addresses(customer_id, city, street) values (7, 'Almaty', 'Street 429') returning id, customer_id, city, street;
create unique index index_unique_city on addresses using btree(customer_id, lower(city), street);
-- ОШИБКА:  создать уникальный индекс "index_unique_city" не удалось
--SQL state: 23505
-- Detail: Ключ (customer_id, lower(city), street)=(7, almaty, Street 429) дублируется.

-- std::why() primary expression returns 2 rows, unique index expects indexation on non-identical rows:
select * from addresses where customer_id = 7 and lower(city) = 'almaty';


-- task 9
-- without index: 4,771 ms with filter and removed 4000 rows
explain analyze
select * from addresses where lower(city) = 'almaty';

-- with index: exec_time: 1,675 ms (really fast)
create index index_city_lower on addresses using btree(lower(city));
explain analyze
select * from addresses where lower(city) = 'almaty';


-- task 10
-- without index: 37,438 ms
explain analyze
select * from orders where date_trunc('day', created_at) = date '2025-03-15';

-- with index: 2.164 ms
create index index_truncated_data on orders using btree(date_trunc('day', created_at));
create index index_hashed_data on orders using hash(date_trunc('day', created_at));
explain analyze
select * from orders where date_trunc('day', created_at) = date '2025-03-15';