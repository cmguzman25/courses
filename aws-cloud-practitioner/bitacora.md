# Bitácora — AWS Cloud Practitioner

El archivo más importante del curso. **Ábrelo cada día.**
Un fallo, una línea, el mismo día. Si no anotas la causa real, volverás a fallar lo mismo.

| Fecha | Módulo | Qué fallé | Causa real | Acción tomada |
|-------|--------|-----------|-----------|---------------|
| | | | | |

## Causas y su antídoto

| Causa | Antídoto |
|-------|----------|
| No lo estudié | Añadir al módulo y a Anki |
| Lo confundí con X | Tarjeta de **contraste** en los dos sentidos |
| Leí mal la pregunta | Subrayar el verbo clave (*más barato*, *menos operación*, *más disponible*) |
| Lo sabía pero no lo recordé | Tarjeta más específica + bajar el intervalo |
| Adiviné y acerté | Cuenta como fallo. Anótalo igual. |

## Patrones detectados

Cada 2 semanas relee la tabla y escribe qué se repite.

-

## Errores clásicos de este examen

Ya identificados por otros. Revísalos antes de cada simulacro completo.

- Confundir **Multi-AZ** (disponibilidad) con **réplica de lectura** (rendimiento).
- Creer que los Security Group permiten reglas Deny. No: solo Allow.
- Olvidar que **EBS vive en una sola AZ** y no se comparte entre instancias.
- Asumir que Trusted Advisor completo está en cualquier plan. Es desde **Business**.
- Contestar Spot para cargas críticas. Spot = solo tolerante a interrupción.
- Decir que AWS parchea el SO de EC2. No: eso es del cliente.
- Confundir Region con AZ al hablar de dónde replica S3 (replica en AZ de **la misma** Región).
