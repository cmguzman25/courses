# Tema 0 — Preparar el entorno

> **Objetivo:** al terminar tendrás PostgreSQL funcionando en Docker, tu propia copia de la base de la tienda y dos formas de consultarla: `psql` (terminal) y pgAdmin (navegador).
>
> **Tiempo estimado:** 30 minutos (la primera vez descarga las imágenes).
>
> **Carpeta del ejercicio:** `alumnos/<tu-nombre>/ejercicios/tema-00/`

---

## 0.1 Por qué todo dentro de Docker

En tu laptop **solo necesitas Docker Desktop** y un editor (por ejemplo VS Code). PostgreSQL no se instala en Windows: vive en un contenedor.

Piensa en Docker como una **cocina de alquiler ya equipada**: llegas, cocinas y te vas. En otra computadora alquilas la misma cocina, con los mismos utensilios.

| Ventaja | Qué significa |
|---|---|
| Portable | En otra laptop instalas Docker, copias la carpeta y listo |
| Misma versión para todos | Todos usan PostgreSQL 18 y los mismos datos |
| Sin miedo a romper | Si destrozas tus datos, los recreas en segundos |

---

## 0.2 El contenedor de PostgreSQL y el de trabajo

El curso levanta tres contenedores:

```
 Tu laptop ─── solo Docker Desktop
 │
 ├── "herramientas" (sql-herramientas)  ← aquí entras: psql, createdb, dropdb
 │        ve la carpeta del curso en /curso
 │                 │  db:5432
 │                 ▼
 ├── "db" (sql-db)                      ← el servidor PostgreSQL 18
 │        base "shop"          → copia de referencia (no se toca)
 │        base "shop_<tu-nombre>" → la tuya, para practicar
 │                 ▲
 └── "pgadmin" (sql-pgadmin)            ← cliente gráfico, en tu navegador
          http://localhost:5061

 Todos viven en la misma red de Docker: "curso-sql"
```

**Idea clave:** un servidor PostgreSQL puede tener **varias bases de datos**, como un edificio con varios departamentos. `shop` es el departamento piloto que nadie toca. Tú vives en `shop_<tu-nombre>`: puedes pintar las paredes y, si algo sale mal, te lo dejan como nuevo.

### El `docker-compose.yml`, en lo importante

| Parte | Para qué |
|---|---|
| `image: postgres:18` | La imagen oficial de PostgreSQL |
| `127.0.0.1:5450:5432` | Desde Windows, Postgres está en el puerto **5450** (no el 5432 de siempre, para no chocar con otros proyectos) |
| `POSTGRES_USER` / `POSTGRES_PASSWORD` = `student` | Usuario y clave de la base. Solo sirven en tu laptop |
| `./docker/postgres/init:/docker-entrypoint-initdb.d` | Scripts que crean las tablas y cargan los datos **la primera vez** que arranca |
| `sql-data:/var/lib/postgresql` | Un volumen: los datos sobreviven aunque apagues los contenedores |
| `PGHOST=db`, `PGUSER`, `PGPASSWORD` (en `herramientas`) | Hacen que `psql` se conecte solo, sin escribir usuario ni clave |
| `networks: curso-sql` | Red propia con rango fijo (`10.170.0.0/24`), para no chocar con otras redes de Docker |

> ⚠️ **`docker compose down -v` borra el volumen: todas las bases de todos los alumnos.** Para apagar usa `docker compose down` **sin** `-v`.

---

## 0.3 Conectarse con `psql` y con un cliente gráfico

| Herramienta | Cuándo usarla |
|---|---|
| **`psql`** (terminal) | Ejecutar tus archivos `.sql`, ver resultados rápidos. Es lo que verás en cualquier servidor real |
| **pgAdmin** (navegador) | Explorar tablas con clics, ver el esquema, escribir consultas con autocompletado |

Comandos de `psql` que usarás todo el curso (empiezan con `\` y no llevan `;`):

| Comando | Qué hace |
|---|---|
| `\l` | Lista las bases de datos |
| `\c shop_<tu-nombre>` | Se cambia a otra base |
| `\dt` | Lista las tablas |
| `\d orders` | Describe una tabla: columnas, tipos, restricciones |
| `\i archivo.sql` | Ejecuta un archivo |
| `\x` | Activa o desactiva la vista vertical (útil con filas anchas) |
| `\timing` | Muestra cuánto tardó cada consulta |
| `\q` | Sale de `psql` |

---

## 0.4 Ejercicio: levantar el entorno y crear tu base

**1. Arranca los contenedores.** Abre **PowerShell** en la carpeta del curso (dentro de donde clonaste el repositorio):

```powershell
cd <donde-clonaste>\courses\curso-sql-intermedio-avanzado
docker compose up -d
```

La primera vez descarga las imágenes y carga los datos (un par de minutos). Comprueba:

```powershell
docker compose ps
```

Resultado esperado:

```
NAME               SERVICE        STATUS
sql-db             db             Up (healthy)
sql-herramientas   herramientas   Up
sql-pgadmin        pgadmin        Up
```

**2. Crea tu propia base.** Entra al contenedor de trabajo:

```powershell
docker compose exec herramientas bash
```

Y dentro ejecuta (con tu nombre en minúsculas, sin tildes ni espacios):

```bash
bash /curso/scripts/reset-db.sh <tu-nombre>
```

Resultado esperado:

```
Creating database shop_<tu-nombre>...
NOTICE:  database "shop_<tu-nombre>" does not exist, skipping
Database shop_<tu-nombre> is ready.
```

El `NOTICE` es normal: avisa que no había una base anterior que borrar.

Sal con `exit`.

**3. A partir de ahora, entra siempre así** (PowerShell), para que `psql` abra tu base directamente:

```powershell
docker compose exec -e PGDATABASE=shop_<tu-nombre> herramientas bash
```

Dentro, escribe `psql`. El prompt debe decir:

```
shop_<tu-nombre>=#
```

> ⚠️ **`reset-db.sh` borra y recrea tu base.** Hoy no pasa nada, pero desde el Tema 11 modificarás datos: si lo ejecutas, pierdes esos cambios. Úsalo cuando quieras empezar de cero.

**4. Conéctate con pgAdmin.** Abre en el navegador `http://localhost:5061`.
- Ya aparece el servidor **SQL course** a la izquierda. Ábrelo; pide la clave: `student` (marca *Save password*).
- Despliega **Databases** → `shop_<tu-nombre>` → **Schemas** → **public** → **Tables**.
- Clic derecho en tu base → **Query Tool**. Ahí escribes y ejecutas consultas (botón ▶ o `F5`).

---

## 0.5 Recorrido por el modelo de datos de la tienda

Una tienda online que vende en España y Latinoamérica. Los pedidos van de 2023 a 2025 y los eventos web son de 2025.

| Tabla | Filas | Qué guarda |
|---|---|---|
| `categories` | 12 | Categorías en árbol: `parent_category_id` apunta a la categoría padre |
| `products` | 200 | Catálogo. `attributes` es JSONB y `tags` es un array |
| `customers` | 2,020 | Clientes. `referred_by` apunta al cliente que los recomendó |
| `employees` | 14 | Organigrama. `manager_id` apunta al jefe |
| `orders` | 20,000 | Pedidos. `employee_id` vacío = compra online sin vendedor |
| `order_items` | 49,897 | Líneas de cada pedido, con el precio del momento de la venta |
| `payments` | 21,021 | Pagos: aprobados, rechazados y reembolsos |
| `web_events` | 191,851 | Clics en la web: `page_view`, `product_view`, `add_to_cart`, `checkout`, `purchase` |

**Cómo se relacionan:**

```
 categories ──< products ──< order_items >── orders >── customers
     └─< (padre)                               │  └──< payments    └─< (referred_by)
                                               │
                                     employees ┘  (vendedor)
                                     └─< (manager_id)

 web_events >── customers   (solo si el visitante inició sesión)

 A ──< B  significa: un A tiene muchos B
```

> **Hay datos "sucios" a propósito:** emails con mayúsculas y espacios, teléfonos en formatos distintos, clientes duplicados, eventos repetidos, productos que nunca se vendieron. No es un error: los usarás en los ejercicios.

---

## Ejercicio: explorar tu base

Crea la carpeta `alumnos/<tu-nombre>/ejercicios/tema-00/` y dentro un archivo `explore.sql`. Escribe ahí cada consulta y ejecútalo desde `psql` con:

```
\i /curso/alumnos/<tu-nombre>/ejercicios/tema-00/explore.sql
```

**1. Mira las tablas y la estructura de `orders`:**

```sql
\dt
\d orders
```

Fíjate en las restricciones: la `CHECK` sobre `status` y las claves foráneas hacia `customers` y `employees`.

**2. Cuenta productos por categoría:**

```sql
SELECT c.name AS category, count(*) AS products
FROM products AS p
JOIN categories AS c ON c.category_id = p.category_id
GROUP BY c.name
ORDER BY c.name;
```

Resultado esperado:

```
  category   | products
-------------+----------
 Accessories |       25
 Books       |       25
 Fitness     |       25
 Furniture   |       25
 Kitchen     |       25
 Laptops     |       25
 Outdoor     |       25
 Phones      |       25
```

Solo aparecen 8 de las 12 categorías: las otras 4 son "padres" (Electronics, Computers, Home, Sports) y no tienen productos directos. Lo aprovecharás en el Tema 4.

**3. Los primeros pedidos:**

```sql
SELECT order_id, customer_id, employee_id, ordered_at, status, shipping_city, discount_code
FROM orders
ORDER BY order_id
LIMIT 3;
```

Resultado esperado:

```
 order_id | customer_id | employee_id |       ordered_at       |  status   | shipping_city | discount_code
----------+-------------+-------------+------------------------+-----------+---------------+---------------
        1 |           9 |           7 | 2023-01-03 08:30:58+00 | delivered | Madrid        |
        2 |           2 |             | 2023-01-10 05:49:48+00 | returned  | Santiago      |
        3 |           1 |             | 2023-01-12 11:02:30+00 | delivered | Bogota        |
```

Las celdas vacías son `NULL`. El `+00` de la fecha es la zona horaria (UTC): lo verás en el Tema 8.

**4. Repite la consulta 2 en pgAdmin** (Query Tool). Mismo resultado, otra herramienta.

---

## Reto

¿Cuántos pedidos hay en cada estado (`status`)? Ordénalos de más a menos.

<details>
<summary>Solución</summary>

```sql
SELECT status, count(*) AS orders
FROM orders
GROUP BY status
ORDER BY orders DESC;
```

```
  status   | orders
-----------+--------
 delivered |  16996
 cancelled |   1548
 returned  |    959
 pending   |    229
 paid      |    152
 shipped   |    116
```

Los `pending`, `paid` y `shipped` son pedidos de los últimos días de 2025 que todavía no llegaron al cliente.

</details>

---

## Limpieza

En este tema no modificaste datos, así que no hay nada que deshacer.

- Sal de `psql` con `\q` y del contenedor con `exit`.
- Si quieres apagar: `docker compose down` (**sin** `-v`). Tu base se conserva.

---

## ✅ Checklist del Tema 0

- [ ] `docker compose ps` muestra `sql-db` (healthy), `sql-herramientas` y `sql-pgadmin` en `Up`.
- [ ] Creaste tu base con `reset-db.sh` y el prompt de `psql` dice `shop_<tu-nombre>=#`.
- [ ] Conoces `\dt`, `\d`, `\i` y `\q`.
- [ ] Abriste tu base en pgAdmin y ejecutaste una consulta.
- [ ] Tu `explore.sql` está en `alumnos/<tu-nombre>/ejercicios/tema-00/`.
- [ ] Sabes que `docker compose down -v` borra todas las bases.

---

## Comandos del día a día

Se escriben en **PowerShell**, desde la carpeta del curso:

| Qué quieres hacer | Comando |
|---|---|
| Arrancar el entorno | `docker compose up -d` |
| Entrar a trabajar | `docker compose exec -e PGDATABASE=shop_<tu-nombre> herramientas bash` y luego `psql` |
| Reiniciar tu base desde cero | dentro del contenedor: `bash /curso/scripts/reset-db.sh <tu-nombre>` |
| Abrir pgAdmin | `http://localhost:5061` |
| Ver si está todo arriba | `docker compose ps` |
| Apagar (sin borrar datos) | `docker compose down` |

**Pasar el curso a otra laptop:** instala Docker Desktop, clona el repositorio, ejecuta `docker compose up -d` y vuelve a crear tu base con `reset-db.sh`. Los datos son siempre los mismos.

**Desde otro cliente de Windows** (DBeaver, VS Code, etc.): host `localhost`, puerto `5450`, usuario `student`, clave `student`, base `shop_<tu-nombre>`.

---

## Problemas que pueden aparecer

**1. `all predefined address pools have been fully subnetted`**
- **Qué pasa:** Docker tiene muchas redes y se quedó sin rangos libres.
- **Solución aplicada:** el curso usa una red con rango fijo (`10.170.0.0/24`). Si choca con otra red tuya, cambia el rango en el `docker-compose.yml` (ej. `10.171.0.0/24`).

**2. `Bind for 127.0.0.1:5450 failed: port is already allocated`**
- **Qué pasa:** otro programa usa el puerto 5450 (o el 5061 de pgAdmin).
- **Solución:** cambia el número de la izquierda en `ports:` del `docker-compose.yml` (ej. `5451:5432`). Dentro de Docker nada cambia.

**3. `database "shop_<tu-nombre>" does not exist`**
- **Qué pasa:** todavía no creaste tu base, o se borró el volumen.
- **Solución:** `bash /curso/scripts/reset-db.sh <tu-nombre>`.

**4. `reset-db.sh: line 1: $'\r': command not found`**
- **Qué pasa:** el script quedó con saltos de línea de Windows.
- **Solución:** el `.gitattributes` del curso lo evita al clonar. Si igual pasa: `sed -i 's/\r$//' /curso/scripts/reset-db.sh`.

**5. `relation "orders" does not exist`**
- **Qué pasa:** estás conectado a otra base (por ejemplo `postgres`).
- **Solución:** mira el prompt de `psql` y cámbiate con `\c shop_<tu-nombre>`.

---

**Siguiente:** Tema 1 — Repaso exprés y orden de ejecución *(la guía se escribe cuando llegues)*
