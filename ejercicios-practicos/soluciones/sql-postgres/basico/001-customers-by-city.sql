-- sql-postgres/basico/001 · Customers from Madrid
SELECT first_name, last_name, email
FROM customers
WHERE city = 'Madrid'
ORDER BY last_name, first_name;
