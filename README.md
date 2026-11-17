# Cursos

Repositorio de aprendizaje. Todo se construye con el mismo motor de estudio.

## Carpetas

| Carpeta | Qué es |
|---------|--------|
| [`_plantilla/`](_plantilla/README.md) | El **motor de estudio** genérico. No se estudia aquí: se copia. |
| [`aws-cloud-practitioner/`](aws-cloud-practitioner/README.md) | Curso activo: certificación AWS CLF-C02. |
| `trascripcion-videos/` | (existente) |
| [`curso-arquitectura-datos-aws-basico/`](curso-arquitectura-datos-aws-basico/temario.md) | Curso **guiado** con Claude: arquitectura de datos en AWS con Terraform y Docker. Multi-alumno. |
| [`curso-aws-cloud-practitioner-terraform-basico/`](curso-aws-cloud-practitioner-terraform-basico/README.md) | Curso **guiado** con Claude: práctica de Cloud Practitioner en AWS real con Terraform. Multi-alumno. |

> Para crear un curso **guiado** (Claude como profesor, todo en Docker, varios alumnos), el patrón está en [`CLAUDE.md`](CLAUDE.md).

## Cómo empezar un curso nuevo

1. Copia `_plantilla/` y renómbrala con el tema (ej. `kubernetes-cka`).
2. Rellena `00-mapa.md`: 8–12 módulos y qué debes *saber hacer*.
3. Duplica `modulos/00-modulo-plantilla.md` una vez por módulo.
4. Elige **una** fuente principal por módulo.
5. Empieza. Anki todos los días.

## El motor en una línea

**Mapa → Fuente única → Preguntas → Anki → Feynman → Simulacro → Bitácora.**

Las tres que la gente se salta y son las que más rinden: **preguntas**, **Feynman**
y **bitácora**.
