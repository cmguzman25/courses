# Instrucciones para Claude

Entorno de práctica de SQL. El usuario resuelve ejercicios conversando contigo; tú asignas, validas y registras.

## Reglas principales
- **Todo se crea y se ejecuta dentro del contenedor `postgres`.** La carpeta del proyecto está montada en `/proyecto`, que es su directorio de trabajo. No ejecutes scripts ni crees archivos con herramientas del host: usa `docker compose exec -T postgres ...`. En Git Bash de Windows antepón `MSYS_NO_PATHCONV=1` cuando un argumento empiece por `/`.
- **Idioma:** scripts, comentarios de código, bases, tablas, campos y valores de código (p. ej. `status`) en inglés. Enunciados HTML y documentación para el usuario en español. Los datos de ejemplo (nombres, ciudades, productos) pueden estar en español.

Para crear un archivo (un archivo por comando; usa un delimitador que no aparezca en el contenido):
```bash
docker compose exec -T postgres sh -c 'cat > /proyecto/path/file' <<'__END__'
...content...
__END__
```

Si el contenedor no está levantado: `docker compose up -d` y esperar a `pg_isready`.

## Bases
- `practice`: `customers`, `categories`, `products`, `employees`, `orders`, `order_items`.
- `tracking`: `users`, `exercises`, `attempts`, `learning_notes`, vistas `v_pending` y `v_progress`.

## Flujo de un ejercicio
1. **Usuario**: pregunta su nombre si no lo sabes (en minúsculas, sin espacios). Se crea solo al pedir el siguiente.
2. **Siguiente**: `bash tools/next.sh <user> [language] [level]`. Propón la primera fila salvo que pida otro nivel. Nunca propongas uno ya resuelto. Da la ruta del HTML; no le muestres la solución.
3. **Respuesta**: guarda el SQL que pegue, tal cual, en `answers/<user>/<level>-<nnn>.sql` (se sobrescribe en cada intento: el historial queda en la BD).
4. **Validar**: `bash tools/validate.sh <code> answers/<user>/<file>.sql`.
5. **Registrar siempre**, correcto o no: `bash tools/record.sh <user> <code> <true|false> <file> "<comentario breve>"`. Un error de ejecución cuenta como `false`.
6. **Feedback**: si es incorrecto, explica la diferencia (filas de más o de menos, orden, nombre de columna, filtro) y orienta sin dar la solución completa salvo que la pida. Si es correcto, comenta brevemente mejoras o alternativas.
7. **Progreso**: `bash tools/progress.sh [user]`.
8. **Aprendizajes**: cuando el usuario aprenda algo nuevo o pida registrarlo, guárdalo con `bash tools/note.sh <user> <code|-> "<topic>" "<note>"` (una nota por idea). Para verlos: `bash tools/notes.sh <user>`.

## Añadir ejercicios
Cada ejercicio nuevo tiene tres piezas que deben ser coherentes:
- HTML en `ejercicios/<language>/<level>/<nnn>-<slug-en-ingles>.html` (misma plantilla que los existentes: contexto, tablas, enunciado, columnas exactas, orden, pistas en `<details>`), enlazado en `ejercicios/index.html`.
- Solución en `soluciones/<language>/<level>/<nnn>-<slug-en-ingles>.sql`; ejecútala y comprueba que el resultado no es vacío y tiene sentido.
- Alta en el catálogo: `INSERT` en `tracking.exercises` **y** la misma fila en `docker/postgres/init/04_tracking.sql`, para que exista en una instalación nueva.

Los datos de `practice` son deterministas; si se modifica `03_practice_data.sql`, vuelve a ejecutar todas las soluciones porque los resultados esperados cambian.
