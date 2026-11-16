-- sql-postgres/intermedio/002 · Customer activity (including customers without orders)
SELECT c.customer_id,
       c.first_name || ' ' || c.last_name                       AS customer,
       c.city,
       COUNT(DISTINCT o.order_id)                               AS orders_count,
       ROUND(COALESCE(SUM(oi.quantity * oi.unit_price), 0), 2)  AS total_spent
FROM customers c
LEFT JOIN orders o       ON o.customer_id = c.customer_id
                        AND o.status <> 'cancelled'
LEFT JOIN order_items oi ON oi.order_id   = o.order_id
GROUP BY c.customer_id, c.first_name, c.last_name, c.city
ORDER BY total_spent DESC, c.customer_id;
