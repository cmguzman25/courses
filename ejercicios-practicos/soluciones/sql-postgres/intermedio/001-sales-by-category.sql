-- sql-postgres/intermedio/001 · Delivered sales by category
SELECT c.name                           AS category,
       SUM(oi.quantity)                 AS units_sold,
       SUM(oi.quantity * oi.unit_price) AS total_sales
FROM order_items oi
JOIN orders     o ON o.order_id    = oi.order_id
JOIN products   p ON p.product_id  = oi.product_id
JOIN categories c ON c.category_id = p.category_id
WHERE o.status = 'delivered'
GROUP BY c.name
HAVING SUM(oi.quantity * oi.unit_price) > 1000
ORDER BY total_sales DESC;
