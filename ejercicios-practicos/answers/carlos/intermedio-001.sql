select  c.name as category,
sum( oi.quantity) as units_sold,
sum (oi.quantity * oi.unit_price) as total_sales
from orders as o
join order_items as oi on o.order_id = oi.order_id
join products as p on p.product_id = oi.product_id
join categories as c on c.category_id = p.category_id
where o.status = 'delivered'
group by c.name
having sum (oi.quantity * oi.unit_price) > 1000
order by total_sales desc
