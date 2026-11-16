select 
    c.customer_id,
    concat(c.first_name , ' ',c.last_name ) as customer,
    city,
    count(distinct (o.order_id)) as orders_count,
    round(coalesce(sum(quantity * unit_price ), 0),2)  as total_spent
from customers as c
left join orders as o on c.customer_id = o.customer_id and  o.status != 'cancelled'
left join order_items as oi on o.order_id = oi.order_id
group by  c.customer_id
order by total_spent desc, c.customer_id asc;
