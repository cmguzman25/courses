# Temario — SQL intermedio-avanzado con PostgreSQL

> Curso práctico para quien ya escribe consultas básicas (`SELECT`, `WHERE`, `JOIN` simple, `GROUP BY`) y quiere dominar SQL de verdad. Todo corre en **PostgreSQL dentro de Docker**.
>
> Todos los temas usan la misma base de ejemplo: una **tienda online** con clientes, productos, pedidos, pagos, empleados y eventos de navegación web. La teoría es breve y cada tema cierra con ejercicios sobre esa base.
>
> El avance de cada persona está en `alumnos/<nombre>/PROGRESO.md`.

---

## Tema 0 — Preparar el entorno → [desarrollo](temas/tema-00-preparar-entorno.md)
- 0.1 Por qué todo dentro de Docker
- 0.2 El contenedor de PostgreSQL y el de trabajo
- 0.3 Conectarse con `psql` y con un cliente gráfico
- 0.4 Cargar la base de ejemplo
- 0.5 Recorrido por el modelo de datos de la tienda

## Tema 1 — Repaso exprés y orden de ejecución
- 1.1 Orden lógico de una consulta: por qué `WHERE` no ve los alias del `SELECT`
- 1.2 `NULL` y la lógica de tres valores
- 1.3 Tipos de datos y conversiones (`CAST` y `::`)
- 1.4 Errores típicos con `GROUP BY` y `HAVING`
- 1.5 Ejercicio diagnóstico

## Tema 2 — JOINs a fondo
- 2.1 `INNER`, `LEFT`, `RIGHT` y `FULL JOIN`: qué filas sobreviven
- 2.2 Semi-join con `EXISTS`
- 2.3 Anti-join: `NOT EXISTS` vs. `NOT IN` (y la trampa del `NULL`)
- 2.4 Self-join
- 2.5 `CROSS JOIN` y `generate_series`
- 2.6 `JOIN LATERAL`
- 2.7 Filas duplicadas por joins (fan-out) y cómo evitarlas
- 2.8 Ejercicio

## Tema 3 — Subconsultas y CTEs
- 3.1 Subconsultas escalares, de tabla y correlacionadas
- 3.2 `IN`, `ANY` y `ALL`
- 3.3 `WITH`: ordenar el razonamiento paso a paso
- 3.4 CTE materializada vs. no materializada
- 3.5 Ejercicio

## Tema 4 — CTEs recursivas
- 4.1 Anatomía: caso base, paso recursivo y condición de parada
- 4.2 Jerarquías: el organigrama de la empresa
- 4.3 Rutas y niveles
- 4.4 Detectar y evitar ciclos
- 4.5 Generar series y calendarios
- 4.6 Ejercicio

## Tema 5 — Agregación avanzada
- 5.1 La cláusula `FILTER`
- 5.2 Agregados condicionales y pivotar con `CASE`
- 5.3 `GROUPING SETS`, `ROLLUP` y `CUBE`
- 5.4 `string_agg` y `array_agg`
- 5.5 Percentiles, mediana y moda
- 5.6 Ejercicio

## Tema 6 — Funciones de ventana I: ranking
- 6.1 `OVER` y `PARTITION BY`: agregar sin colapsar filas
- 6.2 `ROW_NUMBER`, `RANK`, `DENSE_RANK` y `NTILE`
- 6.3 Top-N por grupo
- 6.4 Eliminar duplicados
- 6.5 Ejercicio

## Tema 7 — Funciones de ventana II: navegación y marcos
- 7.1 `LAG` y `LEAD`
- 7.2 `FIRST_VALUE`, `LAST_VALUE` y `NTH_VALUE`
- 7.3 Marcos de ventana: `ROWS`, `RANGE` y `GROUPS`
- 7.4 Acumulados y medias móviles
- 7.5 La cláusula `WINDOW`
- 7.6 Ejercicio

## Tema 8 — Fechas y tiempos
- 8.1 `date`, `timestamp` y `timestamptz`
- 8.2 Zonas horarias
- 8.3 Intervalos y aritmética de fechas
- 8.4 `date_trunc` y `extract`
- 8.5 Calendarios y rellenar días sin datos
- 8.6 Ejercicio

## Tema 9 — Texto y expresiones regulares
- 9.1 Funciones de texto esenciales
- 9.2 `LIKE` / `ILIKE` vs. expresiones regulares
- 9.3 `regexp_match`, `regexp_replace` y `split_part`
- 9.4 Limpieza y normalización de datos
- 9.5 Ejercicio

## Tema 10 — JSONB y arrays
- 10.1 Cuándo usar JSONB (y cuándo no)
- 10.2 Operadores: `->`, `->>`, `#>`, `@>` y `?`
- 10.3 De JSON a filas: `jsonb_to_recordset` y `jsonb_array_elements`
- 10.4 De filas a JSON: `jsonb_build_object` y `jsonb_agg`
- 10.5 Arrays y `unnest`
- 10.6 Ejercicio

## Tema 11 — Modificar datos con seguridad
- 11.1 `INSERT ... SELECT`
- 11.2 `RETURNING`
- 11.3 UPSERT con `ON CONFLICT`
- 11.4 `MERGE`
- 11.5 `UPDATE` y `DELETE` cruzando tablas
- 11.6 Modificar datos dentro de CTEs
- 11.7 Ejercicio

## Tema 12 — Diseño y restricciones
- 12.1 Normalización (1FN, 2FN, 3FN) y cuándo desnormalizar
- 12.2 `PRIMARY KEY`, `FOREIGN KEY`, `UNIQUE`, `CHECK` y `NOT NULL`
- 12.3 Claves naturales vs. sustitutas (`IDENTITY`)
- 12.4 Elegir bien los tipos de datos
- 12.5 Ejercicio: diseñar un módulo nuevo de la tienda

## Tema 13 — Transacciones y concurrencia
- 13.1 ACID en palabras simples
- 13.2 `BEGIN`, `COMMIT`, `ROLLBACK` y `SAVEPOINT`
- 13.3 Niveles de aislamiento y las anomalías que evitan
- 13.4 Bloqueos y `SELECT ... FOR UPDATE`
- 13.5 Deadlocks
- 13.6 Ejercicio con dos sesiones a la vez

## Tema 14 — Índices
- 14.1 Cómo funciona un índice B-tree
- 14.2 Índices compuestos y el orden de las columnas
- 14.3 Índices parciales y de expresión
- 14.4 Índices GIN para JSONB y búsqueda de texto
- 14.5 Cuándo un índice no ayuda (o estorba)
- 14.6 Ejercicio

## Tema 15 — Leer planes de ejecución con `EXPLAIN`
- 15.1 `EXPLAIN` y `EXPLAIN ANALYZE`
- 15.2 Seq scan, index scan e index-only scan
- 15.3 Tipos de join: nested loop, hash y merge
- 15.4 Estadísticas y `ANALYZE`
- 15.5 Reescribir consultas lentas
- 15.6 Ejercicio: acelerar consultas reales de la tienda

## Tema 16 — Vistas, funciones y triggers
- 16.1 Vistas
- 16.2 Vistas materializadas y `REFRESH`
- 16.3 Funciones en SQL y en PL/pgSQL
- 16.4 Triggers: una tabla de auditoría
- 16.5 Ejercicio

## Tema 17 — Seguridad y organización
- 17.1 Roles y permisos (`GRANT` / `REVOKE`)
- 17.2 Esquemas para organizar la base
- 17.3 Row Level Security
- 17.4 Ejercicio: cada vendedor ve solo sus pedidos

## Tema 18 — Patrones de análisis
- 18.1 Gaps & islands (rachas y huecos)
- 18.2 Sesionización de eventos web
- 18.3 Cohortes y retención
- 18.4 Embudos de conversión
- 18.5 Comparaciones período contra período
- 18.6 Ejercicio

## Tema 19 — Proyecto final
- 19.1 El encargo: un reporte analítico de la tienda
- 19.2 Diseñar las consultas
- 19.3 Optimizar con índices y revisar los planes
- 19.4 Presentar los resultados
