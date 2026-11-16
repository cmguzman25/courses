# Propuesta de ejercicios · SQL (PostgreSQL)

Todos usan la base `practice` (tienda: `customers`, `categories`, `products`, `employees`, `orders`, `order_items`).
✅ = ya creado · ⬜ = pendiente de crear. Se crean a medida que se avanza.

## Básico — consultar una sola tabla
| #   | Ejercicio | Temas |
|-----|-----------|-------|
| 001 | ✅ Clientes de Madrid | SELECT, WHERE, ORDER BY |
| 002 | ⬜ Productos entre 20 y 50 € | BETWEEN, ORDER BY |
| 003 | ⬜ Clientes cuyo email empieza por una letra | LIKE / ILIKE |
| 004 | ⬜ Ciudades distintas de los clientes | DISTINCT |
| 005 | ⬜ Los 5 productos más caros | ORDER BY + LIMIT |
| 006 | ⬜ Pedidos de un trimestre | Filtros de fecha |
| 007 | ⬜ Empleados sin jefe | IS NULL |
| 008 | ⬜ Precio con IVA | Columnas calculadas, ROUND, alias |
| 009 | ⬜ Clasificar productos por stock | CASE |
| 010 | ⬜ Pedidos por estado | COUNT + GROUP BY simple |

## Intermedio — combinar y agregar
| #   | Ejercicio | Temas |
|-----|-----------|-------|
| 001 | ✅ Ventas entregadas por categoría | JOIN, GROUP BY, HAVING, SUM |
| 002 | ✅ Actividad de todos los clientes (incluye los que nunca compraron) | LEFT JOIN, COUNT DISTINCT, COALESCE |
| 003 | ✅ Organigrama: jefe y equipo de cada empleado | SELF JOIN, LEFT JOIN, COUNT |
| 004 | ⬜ Ticket medio por cliente | AVG, subconsulta |
| 005 | ⬜ Productos que nunca se vendieron | NOT IN vs NOT EXISTS |
| 006 | ⬜ Ventas mensuales | DATE_TRUNC, GROUP BY |
| 007 | ⬜ Productos por encima del precio medio de su categoría | Subconsulta correlacionada |
| 008 | ⬜ Ciudades con más de N clientes compradores | JOIN + HAVING COUNT DISTINCT |
| 009 | ⬜ Unir listados de contactos | UNION / UNION ALL |
| 010 | ⬜ Pedidos con importe total | Agregación por pedido + COALESCE |

## Avanzado — ventanas, CTE y técnicas
| #   | Ejercicio | Temas |
|-----|-----------|-------|
| 001 | ✅ Top 3 de clientes por mes | CTE, RANK |
| 002 | ⬜ Ventas acumuladas | SUM() OVER (ORDER BY) |
| 003 | ⬜ Variación respecto al mes anterior | LAG / LEAD |
| 004 | ⬜ Organigrama completo | WITH RECURSIVE |
| 005 | ⬜ Días sin pedidos | generate_series + LEFT JOIN |
| 006 | ⬜ Cuota de cada categoría sobre el total | Ventanas con PARTITION BY |
| 007 | ⬜ Clientes recurrentes (2 meses seguidos) | Ventanas + gaps and islands |
| 008 | ⬜ Matriz categoría × mes | Pivot con FILTER / CASE |
| 009 | ⬜ Primer y último pedido por cliente | DISTINCT ON, FIRST_VALUE |
| 010 | ⬜ Optimizar una consulta lenta | EXPLAIN ANALYZE, índices |

## Convención
- Código: `<lenguaje>/<nivel>/<nnn>` (p. ej. `sql-postgres/intermedio/002`).
- Enunciado: `ejercicios/<lenguaje>/<nivel>/<nnn>-<slug-en-ingles>.html`
- Solución: `soluciones/<lenguaje>/<nivel>/<nnn>-<slug-en-ingles>.sql`
- Alta en `tracking.exercises` y en `docker/postgres/init/04_tracking.sql`.

## Otros lenguajes en el futuro
Se añade una carpeta hermana (`ejercicios/python/...`, `ejercicios/sql-mysql/...`), su servicio en `docker-compose.yml` si necesita motor propio, y sus filas en `tracking.exercises` con el `language` correspondiente. La estadística ya agrupa por lenguaje.
