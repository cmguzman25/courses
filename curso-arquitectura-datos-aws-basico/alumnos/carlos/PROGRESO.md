# Progreso del alumno

**Alumno:** Carlos
**Tema actual:** Tema 3 — Data lake en S3 (por empezar)
**Última actualización:** 2026-11-16

## Preferencias

- Respuestas simples y cortas, con analogías.
- Código en inglés; explicaciones en español.
- Teoría primero, ejercicio al final del tema.
- Le gusta preguntar el "por qué" y comparar con casos reales (Glue, EMR, Lambda, warehouse).

## Estado de los temas

⬜ pendiente · 🟡 en curso · ✅ terminado

- ✅ Tema 0 — Preparación del entorno
- ✅ Tema 1 — Fundamentos + primer bucket
- ✅ Tema 2 — Terraform esencial
- ⬜ Tema 3 — Data lake en S3

---

## ✅ Tema 0 — Preparación del entorno (terminado)

**Qué hizo:** levantó LocalStack y herramientas, entró al contenedor, probó la CLI (`sts`, `s3 mb/ls/rb`) y corrió el primer `terraform apply` con un `data` source.

**Dudas que tuvo:**
- Qué son LocalStack y el contenedor herramientas.
- Desde qué carpeta se ejecuta `docker compose exec` (desde la raíz del curso).
- Qué es el prompt `root@...:/curso#`.
- Sintaxis de bloques: `palabra_fija "tipo" "nombre_tuyo"`; `data` vs `resource` vs `output`.
- `providers.tf`: `required_providers` (plugins que se instalan en `init`) y `endpoints` (a dónde mandar cada servicio).

**Problemas resueltos:**
- Red de Docker agotada → red fija `curso-datos` con subred 10.150.0.0/24.
- Puerto 4566 ocupado por otro proyecto → LocalStack del curso en 4567 en Windows.
- VS Code sin colores para `.tf` → extensión HashiCorp Terraform.

## ✅ Tema 1 — Fundamentos + primer bucket (terminado)

**Qué hizo:** teoría completa, creó un bucket, subió un CSV y lo leyó, hizo el reto del segundo bucket y limpió.

**Dudas que tuvo:**
- Significado de OLTP y OLAP.
- Si batch es más barato y si Spark es más barato que Lambda (depende del volumen; batch vs streaming no es lo mismo que Spark vs Lambda).
- Glue streaming: existe, corre 24/7 y cada job tiene sus propios workers. Glue (aislado) vs EMR (compartido).
- Si el cifrado se puede simular (KMS sí; los permisos no se aplican).
- Por qué siguen existiendo warehouses si hay lakehouse; seguridad fina en lakehouse (Lake Formation); caché y vistas materializadas.
- Qué es un ARN; qué es `force_destroy`; `printf ... >`; el `-` como destino en `aws s3 cp`.

**Errores que cometió:**
- Output sin `.bucket` (mostraba el recurso entero).
- En el reto, puso un output del nombre en lugar del ARN que se pedía.
- Olvidó correr `terraform fmt` después de editar.

## ✅ Tema 2 — Terraform esencial (terminado)

**Qué hizo:** variables, locals, outputs con `for`, `for_each` con lista y luego con mapa, validación de variables, drift (uno accidental por reinicio de LocalStack y otro provocado), reto del mapa con `retention_days` y limpieza.

**Dudas que tuvo:**
- Cómo `main.tf` ve a `var` (Terraform junta todos los `.tf` de la carpeta).
- Qué hace `toset`, qué es `each.key`, y si `Zone` es fijo (no lo es: es el nombre de una etiqueta).
- La expresión `{ for zone, b in ... : zone => b.bucket }`.
- Cómo se conecta `terraform.tfvars` con las variables (por nombre).
- `terraform state list` y `terraform output`.
- Qué es drift y cuándo hay error (solo cuando algo ya existe sin estar en el estado → import).
- Cómo ver las características de un bucket; `aws s3` vs `aws s3api`.

**Errores que cometió:**
- `aws_aws_s3_bucket` (prefijo repetido).
- `var. environment` (espacio después del punto).
- `enviroment` mal escrito, y al corregirlo quedó una referencia con el nombre viejo.
- `"curate"` en vez de `"curated"`.
- `terraform output bucket` en vez de `buckets`.
- `each.key.retention_days` en vez de `each.value.retention_days`.

**A reforzar:** revisar la ortografía de los nombres; leer el mensaje de error y la línea que indica.

---

## ⬜ Próximo: Tema 3 — Data lake en S3

Pendiente crear `temas/tema-03-data-lake-s3.md`. Conectar con lo que ya vio: el cifrado AES256 por defecto que apareció en un plan y los `retention_days` del reto del Tema 2 (ciclo de vida).
