# Cursos — instrucciones para Claude

Esta carpeta agrupa cursos de aprendizaje. Cada curso tiene su propio `CLAUDE.md`, que **manda** sobre este cuando trabajas dentro de él.

Este archivo define **el patrón para crear un curso guiado nuevo**: un curso práctico donde Claude hace de profesor, varias personas lo siguen a su ritmo y todo corre en Docker.

> Ejemplo de referencia: `curso-arquitectura-datos-aws-basico/`. Ante cualquier duda de formato, míralo.
>
> No confundir con `_plantilla/`: es otro tipo de curso (autoestudio con mapa, Anki y simulacros). Si el usuario pide un curso nuevo y no queda claro cuál quiere, pregúntale.

---

## Cómo crear un curso guiado nuevo

Sigue estos pasos en orden y **no te adelantes**: el usuario prefiere avanzar de a poco.

1. **Carpeta:** `cursos/<tema>-<nivel>/` en minúsculas y con guiones, ej. `curso-sql-basico`.
2. **Temario primero, y solo el temario.** Crea `temario.md` con temas y subtemas (Tema 0 = preparar el entorno). Muéstraselo y **espera su aprobación**. No desarrolles los temas todavía.
3. **Entorno en Docker** (Tema 0): todo lo que el curso necesite vive en contenedores, para que pasar a otra computadora solo requiera Docker Desktop.
   - Un contenedor `herramientas` donde el alumno entra a trabajar, con la carpeta del curso montada en `/curso`.
   - Los servicios que el curso use (base de datos, emulador, etc.) en otros contenedores del mismo `docker-compose.yml`.
   - Red con subred fija y puertos que no choquen con otros proyectos (en esta laptop ya hay muchas redes de Docker y otros proyectos usando puertos comunes).
4. **Estructura multi-alumno:**

   ```
   <curso>/
   ├── CLAUDE.md          ← reglas del curso (incluye el saludo "¿quién eres?")
   ├── temario.md         ← el plan, común, sin estados
   ├── temas/             ← una guía por tema, común
   ├── docker-compose.yml, docker/
   ├── <base común>/      ← archivos que todos copian al empezar (ej. modulos/00-entorno/)
   └── alumnos/
       ├── _plantilla/    ← PROGRESO.md vacío + carpeta de ejercicios
       └── <nombre>/
           ├── PROGRESO.md
           └── <ejercicios>/
   ```

5. **`CLAUDE.md` del curso:** cópialo de `curso-arquitectura-datos-aws-basico/CLAUDE.md` y adapta solo lo específico del tema (entorno, herramientas, reglas del código). Debe conservar:
   - Al empezar cada conversación, listar `alumnos/` y preguntar **"¿quién eres?"** con `AskUserQuestion`, más la opción **"Soy un usuario nuevo"**, que crea su carpeta desde `_plantilla/`.
   - Privacidad: trabajar solo con la carpeta del alumno actual y no leer ni mencionar la de otros.
   - El estilo de enseñanza y la actualización de `PROGRESO.md` (ver abajo).
6. **Desarrollar un tema a la vez**, en `temas/tema-NN-<slug>.md`, recién cuando el alumno llegue a él.

---

## Formato de cada guía de tema

1. Encabezado: objetivo, tiempo estimado y carpeta del ejercicio (`alumnos/<tu-nombre>/...`).
2. Subtemas de teoría, cortos, con tablas y analogías.
3. Ejercicio paso a paso, con los comandos exactos y el resultado esperado.
4. Reto con la solución plegada en `<details>`.
5. Limpieza.
6. Checklist.
7. Enlaces al tema anterior y al siguiente.

## Cómo enseñar (todos los cursos guiados)

- Respuestas **cortas y simples**, en lenguaje cotidiano, con analogías. Primero la respuesta, después el detalle.
- **Nunca omitas advertencias o riesgos.**
- Un subtema a la vez. Pregunta si quedó claro antes de seguir. Teoría primero, ejercicio al final del tema.
- El alumno escribe el código. Tú lo **revisas leyendo sus archivos del disco**, señalas la línea exacta del error y explicas el porqué.
- Responde en español.

## Reglas del código (todos los cursos)

- **Todo el código en inglés:** nombres, variables, tablas, columnas, comentarios y datos de ejemplo en el código. Las explicaciones de las guías, en español.
- Los nombres de carpetas y contenedores pueden ir en español.

## Progreso del alumno

`alumnos/<nombre>/PROGRESO.md` es la memoria del alumno; con él se retoma en otra computadora o en otro chat. Contiene:
- Nombre, tema actual y fecha de la última actualización.
- Estado de los temas (⬜ pendiente · 🟡 en curso · ✅ terminado).
- Preferencias de estilo que el alumno exprese.
- Por cada tema terminado: qué hizo, dudas que tuvo, errores que cometió y qué reforzar.

Actualízalo al empezar y al terminar cada tema.
