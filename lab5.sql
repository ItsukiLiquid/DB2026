-- NOT FINISHED (6/11, 2026-10-08 22:07 Legion game zone 2+1, 1st pc)


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
