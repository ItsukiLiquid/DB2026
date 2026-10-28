-- prelude
CREATE TABLE customers (
                           customer_id INT PRIMARY KEY,
                           full_name   TEXT NOT NULL,
                           city        TEXT
);

CREATE TABLE orders (
                        order_id    INT PRIMARY KEY,
                        customer_id INT,
                        order_date  DATE,
                        status      TEXT
);

CREATE TABLE products (
                          product_id   INT PRIMARY KEY,
                          product_name TEXT NOT NULL,
                          category     TEXT
);

CREATE TABLE order_items (
                             order_id   INT,
                             product_id INT,
                             quantity   INT,
                             unit_price NUMERIC(10,2)
);


INSERT INTO customers (customer_id, full_name, city) VALUES
                                                         (1,'Alice','Almaty'),
                                                         (2,'Beka','Astana'),
                                                         (3,'Dana','Shymkent'),
                                                         (4,'Emir','Almaty');

INSERT INTO orders (order_id, customer_id, order_date, status) VALUES
                                                                   (100, 1, '2025-01-10', 'paid'),
                                                                   (101, 1, '2025-02-15', 'pending'),
                                                                   (102, 2, '2025-03-01', 'cancelled'),
                                                                   (103, 5, '2025-03-05', 'paid'),
                                                                   (104, 3, '2025-03-07', 'paid');

INSERT INTO products (product_id, product_name, category) VALUES
                                                              (10,'Laptop','Electronics'),
                                                              (20,'Mouse','Accessories'),
                                                              (30,'Keyboard','Accessories'),
                                                              (40,'Desk','Furniture'),
                                                              (50,'Monitor','Electronics');

INSERT INTO order_items (order_id, product_id, quantity, unit_price) VALUES
                                                                         (100, 10, 1, 500.00),
                                                                         (100, 20, 2,  25.00),
                                                                         (101, 50, 1, 150.00),
                                                                         (102, 20, 1,  25.00),
                                                                         (106, 30, 1,  30.00);




-- task 1
select o.order_id, o.order_date, o.status, c.full_name
from orders o
inner join customers c
on o.customer_id = c.customer_id;


-- task 2
select c.customer_id, c.full_name, count(o.order_id) as order_count
from orders o
right join customers c -- includes non-matching rows from customers, if they haven't ordered
on o.customer_id = c.customer_id
group by c.customer_id, c.full_name; -- group by c.customer_id is also enough



-- task 3
select o.order_id, c.customer_id
from customers c
right join orders o
on o.customer_id = c.customer_id
where c.customer_id is null;


-- task 4
select o.order_id, p.product_id, o.quantity, o.unit_price, p.product_name
from order_items o
join products p
using (product_id);


-- task 5
select o.order_id, c.full_name, p.product_name, oi.quantity
from orders o
join order_items oi on oi.order_id = o.order_id -- connect order with order_items to get product_id and quantity
join customers c on c.customer_id = o.customer_id -- connect order with customers to get customer's name
join products p on p.product_id = oi.product_id -- сonnect product with order item (connected with order) to get product name
where o.status = 'paid'; -- filter to case where product is paid


-- task 6
with all_order_ids as (
	select order_id from orders
	union
	select order_id from order_items
) -- union to get all order_ids from both tables

select ids.order_id, coalesce(sum(oi.quantity * oi.unit_price), 0) as order_total -- set automatically to 0, if null is given
from all_order_ids ids
left join order_items oi -- left join to keep all elements from ids with getting quantity and unit_price from right oi if exists
using (order_id) -- <> on ids.order_id = oi.order_id but only 1 column
group by order_id;



-- task 7
select c.customer_id, c.full_name, o.order_id, o.status
from customers c
full outer join orders o
on c.customer_id = o.customer_id
-- where c.customer_id is null or o.order_id is null -> leaves only null values
order by coalesce(c.customer_id, o.order_id);


-- task 8
select o.order_id, c.customer_id, c.full_name, o.status
from orders o
left join customers c
on c.customer_id = o.customer_id;


-- task 9
select order_id, count(*) as items_count, sum(quantity) as total_qty
from order_items
group by order_id;

-- task 10
select p.product_id, p.product_name, coalesce(sum(oi.quantity), 0) as total_sold
from products p
left join order_items oi
on oi.product_id = p.product_id
group by p.product_id
-- order by p.product_id; -- visual confirmation of correctness