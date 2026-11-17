# SQL intermedio-avanzado con PostgreSQL

Curso guiado para quien ya escribe consultas básicas (`SELECT`, `WHERE`, `JOIN` simple, `GROUP BY`) y quiere dominar SQL: JOINs a fondo, CTEs recursivas, funciones de ventana, JSONB, transacciones, índices, `EXPLAIN` y patrones de análisis.

**Claude Code es el profesor:** te explica cada tema, revisa tus consultas y lleva tu progreso. Cada persona avanza a su ritmo.

Temas: ver [`temario.md`](temario.md).

Todo corre en Docker, sobre una base de ejemplo de una tienda online (clientes, productos, pedidos, pagos, empleados y eventos web). Los datos son iguales para todos.

---

## Qué necesitas

| Herramienta | Para qué |
|---|---|
| [Docker Desktop](https://www.docker.com/products/docker-desktop/) | Trae PostgreSQL, `psql` y pgAdmin. No instalas nada más |
| [Git](https://git-scm.com/downloads) | Para descargar el curso y guardar tu avance |
| [Claude Code](https://claude.com/claude-code) | El profesor |
| Un editor, ej. [VS Code](https://code.visualstudio.com/) | Para escribir tus archivos `.sql` |

## Cómo empezar

1. **Haz un fork** de este repositorio en GitHub (botón *Fork*). Así tienes tu propia copia donde guardar tu progreso.
2. Clona tu fork:

   ```powershell
   git clone https://github.com/<tu-usuario>/courses.git
   cd courses\curso-sql-intermedio-avanzado
   ```

3. Abre Claude Code **dentro de esta carpeta** (es importante: aquí están las reglas del curso):

   ```powershell
   claude
   ```

4. Escribe: **"Quiero empezar el curso"**. Claude te preguntará quién eres; elige **"Soy un usuario nuevo"**, dile tu nombre y te creará tu carpeta en `alumnos/`.
5. Sigue con el Tema 0.

## Retomar otro día (o en otra computadora)

- Tu avance vive en `alumnos/<tu-nombre>/` (`PROGRESO.md` y tus `.sql`). Al terminar una sesión, súbelo a **tu** fork:

  ```powershell
  git add alumnos/<tu-nombre>
  git commit -m "Progress: topic N"
  git push
  ```

- En otra computadora: clona tu fork, `docker compose up -d`, recrea tu base con `reset-db.sh` (Tema 0), abre `claude` en esta carpeta y elige tu nombre.

## Ojo

- `docker compose down -v` **borra todas las bases**. Para apagar usa `docker compose down`, sin `-v`.
- Usuario y clave (`student` / `student`) son solo para tu laptop: Postgres y pgAdmin escuchan únicamente en `localhost`.
