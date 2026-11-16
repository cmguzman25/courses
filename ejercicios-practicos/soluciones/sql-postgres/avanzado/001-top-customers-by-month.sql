-- sql-postgres/avanzado/001 · Top 3 customers per month
WITH monthly_spend AS (
    SELECT DATE_TRUNC('month', o.order_date)::date AS month,
           o.customer_id,
           SUM(oi.quantity * oi.unit_price)        AS total_spent
    FROM orders o
    JOIN order_items oi ON oi.order_id = o.order_id
    WHERE o.status <> 'cancelled'
    GROUP BY 1, 2
), ranked AS (
    SELECT m.*,
           RANK() OVER (PARTITION BY m.month ORDER BY m.total_spent DESC) AS ranking
    FROM monthly_spend m
)
SELECT r.month,
       r.customer_id,
       c.first_name || ' ' || c.last_name AS customer,
       r.total_spent,
       r.ranking
FROM ranked r
JOIN customers c ON c.customer_id = r.customer_id
WHERE r.ranking <= 3
ORDER BY r.month, r.ranking, r.customer_id;
