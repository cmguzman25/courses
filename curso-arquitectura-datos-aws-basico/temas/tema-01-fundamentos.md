# Tema 1 — Fundamentos de arquitectura de datos + primer recurso

> **Objetivo:** entender los conceptos base que usaremos todo el curso y crear tu primer recurso en "AWS" con Terraform: un bucket S3.
>
> **Tiempo estimado:** 45–60 minutos.
>
> **Carpeta del ejercicio:** `alumnos/<tu-nombre>/modulos/01-primer-bucket/` (reemplaza `<tu-nombre>` por tu carpeta, ej. `carlos`)
>
> **Antes de empezar:** el entorno del Tema 0 debe estar levantado (`docker compose up -d localstack herramientas`).

---

## 1.1 Tipos de datos

| Tipo | Qué es | Ejemplos |
|---|---|---|
| **Estructurados** | Filas y columnas fijas, como una tabla de Excel | CSV, tablas SQL |
| **Semiestructurados** | Tienen orden, pero cada registro puede traer campos distintos | JSON, XML, Avro |
| **No estructurados** | Sin forma de tabla | Imágenes, audio, PDFs, logs de texto libre |

Ejemplo del mismo cliente en dos formatos:

```
CSV (estructurado):
id,nombre,ciudad
1,Ana,Lima

JSON (semiestructurado):
{"id": 1, "nombre": "Ana", "telefonos": ["999111222", "988777666"]}
```

El JSON permite listas y campos opcionales; el CSV no.

> **Parquet** es un formato de archivo columnar, comprimido y con esquema. Es el formato estrella para análisis. Lo usaremos desde el Tema 3.

---

## 1.2 OLTP vs. OLAP

Son dos formas de usar una base de datos.

| | OLTP (transaccional) | OLAP (analítico) |
|---|---|---|
| Para qué | Que la aplicación funcione | Reportes y análisis |
| Tipo de consulta | Muchas y pequeñas: "dame el pedido 123" | Pocas y grandes: "ventas por mes de los últimos 3 años" |
| Quién la usa | La app, los clientes | Analistas, dashboards, ML |
| En AWS | RDS, DynamoDB | Redshift, Athena |

**Regla práctica:** no hagas reportes pesados sobre la base de la aplicación, porque la vuelves lenta para los clientes. Se copian los datos a un sistema analítico. Eso es justamente lo que hace un ingeniero de datos.

---

## 1.3 Batch vs. streaming

- **Batch (por lotes):** se procesa un grupo de datos cada cierto tiempo. Ejemplo: cada noche se procesan las ventas del día.
- **Streaming (en tiempo real):** se procesa cada evento apenas llega, en segundos. Ejemplo: detectar un fraude en el momento de la compra.

| | Batch | Streaming |
|---|---|---|
| Rapidez | Minutos u horas | Segundos |
| Complejidad | Más simple | Más compleja |
| En el curso | Temas 5, 12 | Temas 7, 8 |

Batch suele ser más barato y fácil. Usa streaming solo cuando el negocio realmente necesite el dato al instante.

---

## 1.4 ETL vs. ELT

Las letras son los mismos pasos, en distinto orden:

- **E**xtraer: sacar los datos de la fuente.
- **T**ransformar: limpiarlos, unirlos, calcular.
- **L**oad (cargar): guardarlos en el destino.

```
ETL:  fuente ──► transformar ──► guardar        (se guarda ya limpio)
ELT:  fuente ──► guardar crudo ──► transformar  (se limpia después)
```

Hoy se usa mucho **ELT** con data lakes: guardar el dato crudo es barato, y si mañana cambias una regla de limpieza puedes volver a procesarlo desde el original.

---

## 1.5 Data lake, data warehouse y lakehouse

| | Data lake | Data warehouse | Lakehouse |
|---|---|---|---|
| Qué es | Un gran almacén de archivos en cualquier formato | Una base de datos analítica con tablas bien definidas | Un lago con tablas tipo warehouse encima |
| Formato | CSV, JSON, Parquet, imágenes... | Tablas SQL | Parquet + formato de tabla (Iceberg, Delta) |
| Costo | Muy barato | Más caro | Barato |
| En AWS | S3 | Redshift | S3 + Iceberg + Athena/Spark |

Imagínalo así: el **lago** es una bodega donde guardas todo en cajas, el **warehouse** es una tienda con estantes ordenados y etiquetados, y el **lakehouse** es la bodega con estantes y etiquetas.

---

## 1.6 Arquitectura por zonas (raw, processed, curated)

Los datos de un lago se organizan en capas según qué tan limpios están. También se llama arquitectura *medallion* (bronce, plata, oro).

```
 Fuentes ──► RAW (bronce) ──► PROCESSED (plata) ──► CURATED (oro) ──► Consumo
             tal cual llegan   limpios y validados   listos para el    BI, ML,
             nunca se tocan    formato común         negocio           APIs
```

| Zona | Qué contiene | Ejemplo |
|---|---|---|
| **raw** | El archivo original, sin cambios | `ventas_2026-11-05.csv` tal como llegó |
| **processed** | Datos limpios, tipos correctos, sin duplicados | Las mismas ventas en Parquet, sin filas con errores |
| **curated** | Datos agregados para responder preguntas del negocio | Ventas totales por día y tienda |

**Por qué separar:** si algo sale mal en la limpieza, raw sigue intacto y puedes volver a procesar.

**La arquitectura que construiremos en el curso:**

```
               ┌──────────┐      ┌──────────────┐
 CSV ─────────►│ S3 raw   │─────►│ Lambda       │──► S3 processed ──► Spark ──► S3 curated
               └──────────┘ evt  │ validación   │                                  │
 Eventos ─► Kinesis ─► Firehose ─┘              │                          DuckDB (SQL)
                                 └──────┬───────┘                                  │
                                        ▼                                  PostgreSQL (DWH)
                                  SNS / SQS / DynamoDB
                     Orquestado con Step Functions + EventBridge
                     Observado con CloudWatch · Secretos en Secrets Manager
```

No hace falta entenderla ahora; la armaremos pieza por pieza.

---

## 1.7 Ejercicio: tu primer bucket S3

Un **bucket** es una "carpeta raíz" en S3 donde guardas archivos (S3 los llama *objetos*). Es la base de todo data lake en AWS.

> **Regla de AWS:** el nombre del bucket debe ser único en todo el mundo, en minúsculas, sin espacios ni guiones bajos. En LocalStack no hay competencia, pero acostúmbrate a la regla.

### Paso 1 — Crear la carpeta del ejercicio

Dentro del contenedor (`docker compose exec herramientas bash`):

```bash
mkdir -p /curso/alumnos/<tu-nombre>/modulos/01-primer-bucket
cd /curso/alumnos/<tu-nombre>/modulos/01-primer-bucket
cp /curso/modulos/00-entorno/providers.tf .
```

Cada tema es un proyecto de Terraform separado, por eso copiamos `providers.tf`.

### Paso 2 — Escribir `main.tf`

Crea `alumnos/<tu-nombre>/modulos/01-primer-bucket/main.tf` desde VS Code:

```hcl
# Creates an S3 bucket
resource "aws_s3_bucket" "first" {
  bucket = "my-first-data-bucket"
}

# Shows the bucket name and ARN when done
output "bucket_name" {
  value = aws_s3_bucket.first.bucket
}

output "bucket_arn" {
  value = aws_s3_bucket.first.arn
}
```

Qué significa:
- `resource`: palabra fija. Esta vez **crea** algo (en el Tema 0 usamos `data`, que solo lee).
- `"aws_s3_bucket"`: el tipo de recurso, fijo del provider aws.
- `"first"`: nombre que tú eliges. Solo existe dentro de Terraform.
- `bucket = "..."`: el nombre real del bucket en AWS.
- **ARN** (*Amazon Resource Name*): el "DNI" de un recurso en AWS. Lo genera AWS, por eso lo mostramos con un `output`.

### Paso 3 — El ciclo de Terraform

```bash
terraform init       # descarga los providers
terraform fmt        # ordena el formato del código
terraform validate   # revisa que no haya errores de sintaxis
terraform plan       # muestra qué va a crear, SIN crear nada
terraform apply      # crea de verdad (escribe "yes")
```

En el `plan` debes ver algo así:

```
  # aws_s3_bucket.first will be created
  + resource "aws_s3_bucket" "first" {
      + bucket = "my-first-data-bucket"
      ...
Plan: 1 to add, 0 to change, 0 to destroy.
```

El `+` significa "se va a crear". Lee siempre el `plan` antes de aplicar: en AWS real es lo que te salva de borrar algo por error.

Al terminar el `apply`:

```
bucket_name = "my-first-data-bucket"
bucket_arn = "arn:aws:s3:::my-first-data-bucket"
```

### Paso 4 — Comprobar con la AWS CLI

```bash
aws s3 ls                                          # el bucket aparece en la lista

printf 'id,name\n1,Ana\n2,Luis\n' > hello.csv      # crea un CSV pequeño
aws s3 cp hello.csv s3://my-first-data-bucket/ # lo sube al bucket
aws s3 ls s3://my-first-data-bucket/          # ver el contenido del bucket
aws s3 cp s3://my-first-data-bucket/hello.csv - # muestra el archivo en pantalla
```

### Paso 5 — Ver qué recuerda Terraform

```bash
terraform state list       # recursos que Terraform administra
terraform output           # vuelve a mostrar los outputs
```

Terraform guarda lo que creó en el archivo `terraform.tfstate`. Lo veremos a fondo en el Tema 2.

---

## 🎯 Reto

1. Agrega un segundo bucket llamado `my-second-data-bucket` con su propio `output` del ARN.
2. Ejecuta `terraform plan` y comprueba que dice `1 to add` (el primero ya existe, no lo vuelve a crear).
3. Aplica y verifica con `aws s3 ls`.

<details>
<summary>Ver solución</summary>

```hcl
resource "aws_s3_bucket" "second" {
  bucket = "my-second-data-bucket"
}

output "second_bucket_arn" {
  value = aws_s3_bucket.second.arn
}
```

</details>

---

## 🧹 Limpieza

```bash
aws s3 rm s3://my-first-data-bucket --recursive   # vacía el bucket
terraform destroy                                      # borra todo lo creado (escribe "yes")
rm hello.csv
```

> **Ojo:** Terraform no puede borrar un bucket que tiene archivos; por eso primero se vacía. En AWS real, `destroy` borra de verdad: lee bien el plan antes de escribir `yes`.

---

## ✅ Checklist

- [ ] Puedo explicar con mis palabras OLTP vs. OLAP y batch vs. streaming.
- [ ] Sé la diferencia entre ETL y ELT.
- [ ] Sé qué guarda cada zona: raw, processed y curated.
- [ ] Creé un bucket con `terraform apply` y lo vi con `aws s3 ls`.
- [ ] Subí un archivo al bucket.
- [ ] Hice el reto del segundo bucket.
- [ ] Limpié con `terraform destroy`.

---

**Siguiente:** [Tema 2 — Terraform esencial](tema-02-terraform-esencial.md)
