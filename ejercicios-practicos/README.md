# Ejercicios prácticos de SQL (PostgreSQL) en Docker

Entorno portable para practicar SQL. Todo corre en Docker: copia la carpeta a otro PC con Docker instalado y funciona igual. No hace falta instalar nada más.

Código, tablas y campos están en inglés; los enunciados, en español.

## Arrancar

```bash
docker compose up -d
```

La primera vez, Postgres ejecuta solo los scripts de `docker/postgres/init/` y crea:

| Base       | Para qué                                                     |
|------------|--------------------------------------------------------------|
| `practice` | Datos de la tienda sobre los que se hacen los ejercicios     |
| `tracking` | Usuarios, catálogo de ejercicios e intentos (la estadística) |

## Accesos

| Qué        | Dónde                                         | Credenciales                            |
|------------|-----------------------------------------------|-----------------------------------------|
| pgAdmin    | http://localhost:5051                         | sin login; la clave de la BD es `admin` |
| PostgreSQL | `localhost:5440` (desde fuera del contenedor) | `admin` / `admin`                       |
| Enunciados | abrir `ejercicios/index.html` en el navegador | —                                       |

En pgAdmin: Servers → Ejercicios SQL → Databases → `practice` → clic derecho → Query Tool. Los puertos se cambian en `.env`.

## Cómo se practica

1. Pídele a Claude el siguiente ejercicio (por ejemplo: *"soy carlos, dame el siguiente ejercicio"*).
2. Abre el HTML que te indique y escribe la consulta en pgAdmin contra `practice`.
3. Pásale la consulta a Claude. Claude la guarda en `answers/<usuario>/`, la valida contra la solución y registra el intento en `tracking`.
4. Pide tu progreso cuando quieras (*"¿cómo voy?"*).

Las soluciones están en `soluciones/` (fuera de `ejercicios/` para no verlas sin querer).

## Herramientas (se ejecutan dentro del contenedor)

```bash
docker compose exec postgres bash tools/next.sh <user> [language] [level]
docker compose exec postgres bash tools/validate.sh <code> answers/<user>/<file>.sql
docker compose exec postgres bash tools/record.sh <user> <code> <true|false> <file.sql> [comment]
docker compose exec postgres bash tools/progress.sh [user]
docker compose exec postgres bash tools/note.sh <user> <code|-> <topic> "<note>"
docker compose exec postgres bash tools/notes.sh <user>
```

`validate.sh` ejecuta la respuesta en una transacción de solo lectura (no puede romper los datos) y compara su salida con la de la solución: mismas columnas, mismos valores y, si el ejercicio lo exige, mismo orden.

## Llevar el progreso a otro PC

Los datos viven en volúmenes de Docker, que no viajan con la carpeta. Antes de mover:

```bash
docker compose exec postgres sh -c 'pg_dump -U admin -d tracking --data-only -t users -t attempts -t learning_notes > backups/tracking.sql'
```

En el PC nuevo, tras `docker compose up -d`:

```bash
docker compose exec postgres sh -c 'psql -U admin -d tracking -f backups/tracking.sql'
```

## Empezar de cero

```bash
docker compose down -v   # borra volúmenes: datos de práctica, progreso y config de pgAdmin
docker compose up -d
```

## Estructura

```
docker/postgres/init/            scripts que crean las bases (se ejecutan solos la 1.ª vez)
docker/pgadmin/                  servidor preconfigurado para pgAdmin
ejercicios/<lenguaje>/<nivel>/   enunciados HTML (en español)
soluciones/<lenguaje>/<nivel>/   soluciones SQL
tools/                           scripts de validación y seguimiento
answers/<user>/                  respuestas enviadas
backups/                         copias del progreso
```

Ver `PROPUESTA_EJERCICIOS.md` para el temario y cómo añadir ejercicios.
