# Curso de Arquitectura de Datos en AWS (desde cero) con Terraform y LocalStack

> Curso 100 % práctico. Cada tema es un ejercicio que construyes con **Terraform** y ejecutas en tu máquina con **Docker + LocalStack**, un emulador de AWS. No necesitas cuenta ni consola de AWS.

---

## Índice

- [Módulo 0 — Preparación del entorno](#módulo-0--preparación-del-entorno)
- [Módulo 1 — Fundamentos de arquitectura de datos + primer recurso](#módulo-1--fundamentos-de-arquitectura-de-datos--primer-recurso)
- [Módulo 2 — Terraform esencial](#módulo-2--terraform-esencial)
- [Módulo 3 — Data Lake en S3](#módulo-3--data-lake-en-s3)
- [Módulo 4 — Seguridad con IAM](#módulo-4--seguridad-con-iam)
- [Módulo 5 — Ingesta batch con Lambda y eventos de S3](#módulo-5--ingesta-batch-con-lambda-y-eventos-de-s3)
- [Módulo 6 — Mensajería con SNS y SQS](#módulo-6--mensajería-con-sns-y-sqs)
- [Módulo 7 — Streaming con Kinesis y Firehose](#módulo-7--streaming-con-kinesis-y-firehose)
- [Módulo 8 — Bases NoSQL con DynamoDB](#módulo-8--bases-nosql-con-dynamodb)
- [Módulo 9 — Orquestación con Step Functions y EventBridge](#módulo-9--orquestación-con-step-functions-y-eventbridge)
- [Módulo 10 — Secretos y configuración](#módulo-10--secretos-y-configuración)
- [Módulo 11 — Observabilidad con CloudWatch](#módulo-11--observabilidad-con-cloudwatch)
- [Módulo 12 — Procesamiento con Spark (Glue simulado)](#módulo-12--procesamiento-con-spark-glue-simulado)
- [Módulo 13 — Consultas SQL sobre el lago (Athena simulado)](#módulo-13--consultas-sql-sobre-el-lago-athena-simulado)
- [Módulo 14 — Data Warehouse (Redshift simulado)](#módulo-14--data-warehouse-redshift-simulado)
- [Módulo 15 — Terraform avanzado: módulos, estado remoto y entornos](#módulo-15--terraform-avanzado-módulos-estado-remoto-y-entornos)
- [Módulo 16 — Proyecto final: pipeline de datos de punta a punta](#módulo-16--proyecto-final-pipeline-de-datos-de-punta-a-punta)
- [Apéndice A — Equivalencias AWS real vs. entorno local](#apéndice-a--equivalencias-aws-real-vs-entorno-local)
- [Apéndice B — Solución de problemas](#apéndice-b--solución-de-problemas)
- [Apéndice C — Glosario](#apéndice-c--glosario)

---

## Estructura de carpetas del curso

```
curso-arquitectura-datos-aws-basico/
├── docker-compose.yml          # LocalStack + caja de herramientas + Spark + Postgres
├── docker/herramientas/        # Dockerfile de la caja de herramientas
├── datos/                      # archivos de ejemplo (CSV, JSON)
├── jobs/                       # scripts de Spark (módulo 12)
├── scripts/                    # scripts Python auxiliares
└── modulos/
    ├── 01-primer-bucket/
    ├── 02-terraform-esencial/
    ├── 03-data-lake/
    ├── ...
    └── 16-proyecto-final/
```

Cada carpeta de `modulos/` es un proyecto de Terraform independiente con su propio `providers.tf`.

---

## Módulo 0 — Preparación del entorno

### Objetivos
- Entender por qué todo el curso corre dentro de Docker.
- Levantar LocalStack (el AWS simulado) y la caja de herramientas.
- Entrar a la caja de herramientas y comprobar que habla con LocalStack.

### 0.1 Todo dentro de Docker

En tu máquina **solo necesitas Docker Desktop** (y un editor, por ejemplo VS Code). Terraform, la AWS CLI y Python viven dentro de un contenedor llamado `herramientas`.

Ventajas:
- Para cambiar de laptop basta con instalar Docker y copiar la carpeta del curso (o clonarla con git).
- Todos usan las mismas versiones de las herramientas.
- No ensucias Windows con instalaciones.

```
 Tu laptop (Windows, Mac o Linux) ── solo Docker Desktop
 │
 ├── contenedor "herramientas"  ← aquí entras y escribes los comandos
 │      Terraform · AWS CLI v2 · Python + boto3 + DuckDB · psql
 │      ve la carpeta del curso en /curso  (la editas desde Windows)
 │                  │
 │                  ▼  http://localstack:4566
 ├── contenedor "localstack"    ← el AWS simulado
 ├── contenedor "spark"         ← módulo 12 en adelante
 └── contenedor "dwh" (Postgres)← módulo 14 en adelante
```

> **Importante:** dentro de Docker, LocalStack se llama `localstack`, no `localhost`. Por eso todo el código del curso usa `http://localstack:4566`.

### 0.2 ¿Qué es LocalStack?

LocalStack es un contenedor Docker que expone las mismas APIs que AWS (S3, Lambda, SQS, DynamoDB, etc.) en el puerto `4566`. Terraform y la AWS CLI "creen" que hablan con AWS.

**Limitaciones importantes:**
- La edición gratuita **no** incluye Glue, Athena, EMR, Redshift ni Lake Formation. En este curso los reemplazamos con Spark, DuckDB y PostgreSQL en contenedores (ver Apéndice A).
- Las políticas IAM **no se aplican** por defecto (todo está permitido). Igual las escribimos bien, porque en AWS real sí importan.
- Al reiniciar el contenedor se pierden los recursos (sin persistencia en la edición gratuita). Basta con volver a ejecutar `terraform apply`.

> **Nota de licencia:** LocalStack cambió su modelo de distribución con el tiempo. Si al arrancar la imagen te pide `LOCALSTACK_AUTH_TOKEN`, crea una cuenta gratuita en localstack.cloud, copia tu token y descomenta la línea correspondiente en el `docker-compose.yml`.

### 0.3 Los archivos del entorno

Ya están en la raíz del curso:

**`docker/herramientas/Dockerfile`**: arma la caja de herramientas a partir de una imagen de Python e instala Terraform (repositorio oficial de HashiCorp), la AWS CLI v2, `boto3`, `duckdb` y el cliente `psql`. Funciona en PCs Intel/AMD y en Mac con chip Apple.

**`docker-compose.yml`**: define los cuatro contenedores. Lo más importante del servicio `herramientas`:

```yaml
  herramientas:
    build: ./docker/herramientas
    working_dir: /curso
    volumes:
      - "./:/curso"                                   # la carpeta del curso, compartida con Windows
      - "terraform-plugins:/root/.terraform.d/plugin-cache"
    environment:
      - AWS_ACCESS_KEY_ID=test
      - AWS_SECRET_ACCESS_KEY=test
      - AWS_DEFAULT_REGION=us-east-1
      - AWS_ENDPOINT_URL=http://localstack:4566     # AWS CLI y boto3 apuntan solos a LocalStack
      - TF_PLUGIN_CACHE_DIR=/root/.terraform.d/plugin-cache
```

- El volumen `./:/curso` hace que los archivos que editas en Windows aparezcan al instante dentro del contenedor.
- `AWS_ENDPOINT_URL` hace que la AWS CLI y los scripts de Python vayan a LocalStack sin configurar nada más.
- `TF_PLUGIN_CACHE_DIR` guarda los providers de Terraform para no descargarlos en cada módulo.

`.gitignore` evita subir a git el estado de Terraform, las carpetas `.terraform/` y los datos de LocalStack.

### 0.4 Ejercicio: levantar el entorno

Desde la carpeta del curso, en la terminal de Windows (PowerShell):

```powershell
docker compose up -d --build localstack herramientas
docker compose ps                  # ambos deben aparecer como "running"
docker logs localstack --tail 20   # busca la palabra "Ready."
```

La primera vez tarda unos minutos porque construye la imagen de herramientas.

### 0.5 Ejercicio: entrar a la caja de herramientas

```powershell
docker compose exec herramientas bash
```

Ahora estás **dentro** del contenedor (el prompt cambia). A partir de aquí, todos los comandos del curso se escriben en esta terminal, salvo que se indique lo contrario.

```bash
terraform -version
aws --version
python --version

# ¿LocalStack está vivo y qué servicios tiene?
curl -s http://localstack:4566/_localstack/health | jq

# Primera llamada al "AWS" simulado: debe devolver la cuenta 000000000000
aws sts get-caller-identity
```

Para salir del contenedor escribe `exit`. Los contenedores siguen corriendo.

**Comandos del día a día:**

| Qué quieres hacer | Comando (en PowerShell) |
|---|---|
| Arrancar el entorno | `docker compose up -d localstack herramientas` |
| Entrar a trabajar | `docker compose exec herramientas bash` |
| Apagar todo | `docker compose down` |
| Reconstruir la imagen tras cambiar el Dockerfile | `docker compose build herramientas` |

**Pasar el curso a otra laptop:** instala Docker Desktop, copia o clona la carpeta y ejecuta `docker compose up -d --build localstack herramientas`. Listo.

### 0.6 El archivo `providers.tf` base

Usaremos este archivo en **todos** los módulos. Indica a Terraform que use LocalStack:

```hcl
# providers.tf
terraform {
  required_version = ">= 1.10"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
    archive = {
      source  = "hashicorp/archive"
      version = "~> 2.4"
    }
  }
}

provider "aws" {
  region                      = "us-east-1"
  access_key                  = "test"
  secret_key                  = "test"
  skip_credentials_validation = true
  skip_metadata_api_check     = true
  skip_requesting_account_id  = true
  s3_use_path_style           = true

  endpoints {
    cloudwatch     = "http://localstack:4566"
    dynamodb       = "http://localstack:4566"
    events         = "http://localstack:4566"
    firehose       = "http://localstack:4566"
    iam            = "http://localstack:4566"
    kinesis        = "http://localstack:4566"
    kms            = "http://localstack:4566"
    lambda         = "http://localstack:4566"
    logs           = "http://localstack:4566"
    s3             = "http://localstack:4566"
    scheduler      = "http://localstack:4566"
    secretsmanager = "http://localstack:4566"
    sfn            = "http://localstack:4566"
    sns            = "http://localstack:4566"
    sqs            = "http://localstack:4566"
    ssm            = "http://localstack:4566"
    sts            = "http://localstack:4566"
  }

  default_tags {
    tags = {
      Proyecto = "curso-arquitectura-datos"
      Entorno  = "local"
    }
  }
}
```

> **En AWS real** solo cambia este archivo: quitas `access_key`, `secret_key`, los `skip_*` y el bloque `endpoints`. El resto del código de los módulos es idéntico. Esa es la gran ventaja de este enfoque.

### ✅ Verificación
- `docker ps` muestra el contenedor `localstack` en estado *healthy*.
- `aws sts get-caller-identity` responde con la cuenta `000000000000`.

---

## Módulo 1 — Fundamentos de arquitectura de datos + primer recurso

### Objetivos
- Entender los conceptos base que usaremos el resto del curso.
- Crear tu primer recurso AWS con Terraform.

### 1.1 Conceptos clave

**Tipos de datos**
- *Estructurados*: tablas con esquema fijo (CSV, tablas SQL).
- *Semiestructurados*: JSON, XML, Avro, Parquet con esquema flexible.
- *No estructurados*: imágenes, audio, PDFs, logs en texto libre.

**OLTP vs. OLAP**
| | OLTP (transaccional) | OLAP (analítico) |
|---|---|---|
| Uso | Operaciones de la aplicación | Reportes y análisis |
| Consultas | Muchas, pequeñas, por clave | Pocas, grandes, agregaciones |
| Ejemplo AWS | RDS, DynamoDB | Redshift, Athena |

**Batch vs. Streaming**
- *Batch*: se procesan lotes cada cierto tiempo (cada hora, cada noche).
- *Streaming*: se procesa cada evento casi en tiempo real (segundos).

**ETL vs. ELT**
- *ETL*: extraer → transformar → cargar (se transforma antes de guardar).
- *ELT*: extraer → cargar → transformar (se guarda crudo y se transforma después, común en data lakes).

**Data Lake, Data Warehouse y Lakehouse**
- *Data Lake*: almacenamiento barato de datos en cualquier formato (S3).
- *Data Warehouse*: base de datos analítica con esquema estricto (Redshift).
- *Lakehouse*: un lago con capacidades de warehouse (tablas Iceberg/Delta sobre S3 consultadas con Athena/Spark).

**Arquitectura por zonas (medallion)**
```
 Fuentes ──► RAW (bronce) ──► PROCESSED (plata) ──► CURATED (oro) ──► Consumo
             datos crudos     limpios/validados     agregados de       BI, ML,
             tal cual llegan  y en formato común    negocio            APIs
```

### 1.2 La arquitectura que construiremos

```
               ┌──────────┐      ┌──────────────┐
 CSV ─────────►│ S3 raw   │─────►│ Lambda       │──► S3 processed ──► Spark ──► S3 curated
               └──────────┘ evt  │ validación   │                                   │
 Eventos ─► Kinesis ─► Firehose ─┘              │                          DuckDB (SQL)
                                 └──────┬───────┘                                   │
                                        ▼                                   PostgreSQL (DWH)
                                  SNS / SQS / DynamoDB
                     Orquestado con Step Functions + EventBridge
                     Observado con CloudWatch · Secretos en Secrets Manager
```

### 1.3 Ejercicio: tu primer bucket S3

```bash
mkdir modulos/01-primer-bucket
cd modulos/01-primer-bucket
# copia aquí el providers.tf del módulo 0
```

`main.tf`:

```hcl
resource "aws_s3_bucket" "hola" {
  bucket = "mi-primer-bucket-de-datos"
}

output "nombre_bucket" {
  value = aws_s3_bucket.hola.bucket
}
```

Ejecuta el ciclo básico de Terraform:

```bash
terraform init       # descarga providers
terraform fmt        # formatea el código
terraform validate   # revisa sintaxis
terraform plan       # muestra qué va a crear
terraform apply      # crea (escribe "yes")
```

Comprueba con la CLI:

```bash
aws s3 ls
printf 'id,nombre
1,Ana
2,Luis
' > hola.csv
aws s3 cp hola.csv s3://mi-primer-bucket-de-datos/
aws s3 ls s3://mi-primer-bucket-de-datos/
```

### 🎯 Reto
Añade un segundo bucket llamado `mi-segundo-bucket` y un output que muestre su ARN (`aws_s3_bucket.x.arn`).

### 🧹 Limpieza
```bash
aws s3 rm s3://mi-primer-bucket-de-datos --recursive
terraform destroy
```

---

## Módulo 2 — Terraform esencial

### Objetivos
Dominar lo básico de Terraform que usarás en todo el curso.

### 2.1 Subtemas
- **Providers**: plugins que hablan con una API (AWS, Postgres, etc.).
- **Resources**: lo que creas (`resource "tipo" "nombre"`).
- **Data sources**: información que lees sin crear (`data "tipo" "nombre"`).
- **Variables** (`variable`), **locals** (`locals`) y **outputs** (`output`).
- **Meta-argumentos**: `count`, `for_each`, `depends_on`, `lifecycle`.
- **Estado** (`terraform.tfstate`): el "inventario" de lo que Terraform creó. Nunca lo edites a mano.
- **Comandos**: `init`, `fmt`, `validate`, `plan`, `apply`, `destroy`, `state list`, `output`.

### 2.2 Ejercicio: buckets parametrizados

Carpeta `modulos/02-terraform-esencial/` con `providers.tf` y:

`variables.tf`:

```hcl
variable "proyecto" {
  description = "Nombre corto del proyecto"
  type        = string
  default     = "ventas"
}

variable "entorno" {
  description = "dev, qa o prod"
  type        = string
  default     = "dev"

  validation {
    condition     = contains(["dev", "qa", "prod"], var.entorno)
    error_message = "El entorno debe ser dev, qa o prod."
  }
}

variable "zonas" {
  description = "Zonas del data lake"
  type        = list(string)
  default     = ["raw", "processed", "curated"]
}
```

`main.tf`:

```hcl
locals {
  prefijo = "${var.proyecto}-${var.entorno}"
}

resource "aws_s3_bucket" "zona" {
  for_each = toset(var.zonas)
  bucket   = "${local.prefijo}-${each.key}"

  tags = {
    Zona = each.key
  }
}
```

`outputs.tf`:

```hcl
output "buckets" {
  value = { for zona, b in aws_s3_bucket.zona : zona => b.bucket }
}
```

`terraform.tfvars`:

```hcl
proyecto = "ventas"
entorno  = "dev"
```

Ejecuta:

```bash
terraform init
terraform plan
terraform apply -auto-approve
terraform output buckets
terraform state list
```

Prueba la validación:

```bash
terraform plan -var="entorno=staging"   # debe fallar con tu mensaje de error
```

### 2.3 Ejercicio: ver cómo Terraform detecta cambios
1. Cambia `zonas` en `terraform.tfvars` para añadir `"sandbox"` y ejecuta `terraform plan`: verás `1 to add`.
2. Borra un bucket "por fuera" con `aws s3 rb s3://ventas-dev-sandbox` y ejecuta `terraform plan`: Terraform detecta la diferencia (*drift*) y propone recrearlo.

### 🎯 Reto
Convierte `zonas` en un `map(object({ dias_retencion = number }))` y guarda los días como tag de cada bucket.

### 🧹 Limpieza
`terraform destroy -auto-approve`

---

## Módulo 3 — Data Lake en S3

### Objetivos
Construir un data lake con buenas prácticas: zonas, versionado, cifrado, bloqueo de acceso público, ciclo de vida y particionado.

### 3.1 Subtemas
- **Zonas** raw / processed / curated (un bucket por zona, o prefijos en un bucket).
- **Versionado**: protege contra borrados y sobrescrituras accidentales.
- **Cifrado**: SSE-S3 (AES256) o SSE-KMS.
- **Bloqueo de acceso público**: siempre activado en un data lake.
- **Ciclo de vida**: mover datos viejos a clases más baratas (Standard-IA, Glacier) o borrarlos.
- **Particionado** con estilo Hive: `ventas/anio=2026/mes=11/dia=04/archivo.csv`. Permite a Athena o Spark leer solo lo necesario.
- **Formatos**: CSV/JSON en raw; Parquet (columnar y comprimido) en processed y curated.

### 3.2 Ejercicio: data lake completo

Carpeta `modulos/03-data-lake/`.

`variables.tf`:

```hcl
variable "prefijo" {
  type    = string
  default = "datalake-dev"
}

variable "zonas" {
  type = map(object({
    dias_a_ia      = number
    dias_expiracion = number
  }))
  default = {
    raw       = { dias_a_ia = 30, dias_expiracion = 365 }
    processed = { dias_a_ia = 60, dias_expiracion = 730 }
    curated   = { dias_a_ia = 90, dias_expiracion = 0 }   # 0 = no expira
  }
}
```

`main.tf`:

```hcl
resource "aws_s3_bucket" "zona" {
  for_each = var.zonas
  bucket   = "${var.prefijo}-${each.key}"
  tags     = { Zona = each.key }
}

resource "aws_s3_bucket_versioning" "zona" {
  for_each = aws_s3_bucket.zona
  bucket   = each.value.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "zona" {
  for_each = aws_s3_bucket.zona
  bucket   = each.value.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "zona" {
  for_each                = aws_s3_bucket.zona
  bucket                  = each.value.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_lifecycle_configuration" "zona" {
  for_each = aws_s3_bucket.zona
  bucket   = each.value.id

  rule {
    id     = "mover-a-ia"
    status = "Enabled"
    filter {}

    transition {
      days          = var.zonas[each.key].dias_a_ia
      storage_class = "STANDARD_IA"
    }

    dynamic "expiration" {
      for_each = var.zonas[each.key].dias_expiracion > 0 ? [1] : []
      content {
        days = var.zonas[each.key].dias_expiracion
      }
    }

    noncurrent_version_expiration {
      noncurrent_days = 30
    }
  }
}

# Datos de ejemplo subidos con Terraform, con particionado Hive
resource "aws_s3_object" "ventas_ejemplo" {
  bucket       = aws_s3_bucket.zona["raw"].id
  key          = "ventas/anio=2026/mes=11/dia=04/ventas.csv"
  source       = "${path.module}/datos/ventas.csv"
  etag         = filemd5("${path.module}/datos/ventas.csv")
  content_type = "text/csv"
}
```

`outputs.tf`:

```hcl
output "buckets" {
  value = { for k, b in aws_s3_bucket.zona : k => b.bucket }
}
```

`datos/ventas.csv` (lo reutilizaremos varias veces):

```csv
order_id,customer_id,product,amount,order_date
1001,C01,teclado,45.50,2026-11-04
1002,C02,mouse,19.99,2026-11-04
1003,C01,monitor,189.00,2026-11-04
1004,C03,,25.00,2026-11-04
1005,C04,webcam,abc,2026-11-04
```

> Las filas 1004 (producto vacío) y 1005 (monto inválido) son errores a propósito; los detectaremos en el módulo 5.

Aplica y verifica:

```bash
terraform init && terraform apply -auto-approve
aws s3 ls s3://datalake-dev-raw --recursive
aws s3api get-bucket-versioning --bucket datalake-dev-raw
aws s3api get-bucket-encryption --bucket datalake-dev-raw
aws s3api get-bucket-lifecycle-configuration --bucket datalake-dev-raw
```

Prueba el versionado:

```bash
aws s3 cp datos/ventas.csv s3://datalake-dev-raw/prueba.csv
aws s3 cp datos/ventas.csv s3://datalake-dev-raw/prueba.csv
aws s3api list-object-versions --bucket datalake-dev-raw --prefix prueba.csv
```

### 🎯 Reto
Crea una clave KMS (`aws_kms_key`) y cambia el cifrado de la zona `curated` a `aws:kms` usando `kms_master_key_id`.

### 🧹 Limpieza
Con versionado activo, `terraform destroy` falla si hay objetos. Añade `force_destroy = true` al bucket (solo en entornos de práctica) y luego ejecuta `terraform destroy`.

---

## Módulo 4 — Seguridad con IAM

### Objetivos
Crear roles y políticas con **mínimo privilegio** para los servicios de datos.

### 4.1 Subtemas
- **Usuarios, grupos, roles y políticas**: en arquitecturas de datos casi siempre usamos **roles** que asumen los servicios (Lambda, Glue, Step Functions).
- **Trust policy** (quién puede asumir el rol) vs. **permission policy** (qué puede hacer).
- **Mínimo privilegio**: acciones y recursos concretos, nunca `"*"` si se puede evitar.
- `aws_iam_policy_document`: escribir políticas en HCL en vez de JSON a mano.
- Recordatorio: LocalStack gratuito **no aplica** IAM. Este módulo se valida revisando lo creado.

### 4.2 Ejercicio: rol para una Lambda que lee raw y escribe processed

Carpeta `modulos/04-iam/`.

`main.tf`:

```hcl
locals {
  bucket_raw       = "datalake-dev-raw"
  bucket_processed = "datalake-dev-processed"
}

# Trust policy: solo Lambda puede asumir el rol
data "aws_iam_policy_document" "assume_lambda" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "lambda_etl" {
  name               = "rol-lambda-etl"
  assume_role_policy = data.aws_iam_policy_document.assume_lambda.json
}

# Permisos mínimos
data "aws_iam_policy_document" "etl" {
  statement {
    sid       = "LeerRaw"
    actions   = ["s3:GetObject"]
    resources = ["arn:aws:s3:::${local.bucket_raw}/*"]
  }

  statement {
    sid       = "EscribirProcessed"
    actions   = ["s3:PutObject"]
    resources = ["arn:aws:s3:::${local.bucket_processed}/*"]
  }

  statement {
    sid       = "Logs"
    actions   = ["logs:CreateLogGroup", "logs:CreateLogStream", "logs:PutLogEvents"]
    resources = ["arn:aws:logs:*:*:*"]
  }
}

resource "aws_iam_policy" "etl" {
  name   = "politica-lambda-etl"
  policy = data.aws_iam_policy_document.etl.json
}

resource "aws_iam_role_policy_attachment" "etl" {
  role       = aws_iam_role.lambda_etl.name
  policy_arn = aws_iam_policy.etl.arn
}

# Un grupo de analistas con solo lectura sobre curated
resource "aws_iam_group" "analistas" {
  name = "analistas-datos"
}

data "aws_iam_policy_document" "lectura_curated" {
  statement {
    actions   = ["s3:ListBucket"]
    resources = ["arn:aws:s3:::datalake-dev-curated"]
  }
  statement {
    actions   = ["s3:GetObject"]
    resources = ["arn:aws:s3:::datalake-dev-curated/*"]
  }
}

resource "aws_iam_group_policy" "analistas" {
  name   = "lectura-curated"
  group  = aws_iam_group.analistas.name
  policy = data.aws_iam_policy_document.lectura_curated.json
}

output "rol_arn" {
  value = aws_iam_role.lambda_etl.arn
}

output "politica_json" {
  value = data.aws_iam_policy_document.etl.json
}
```

Verifica:

```bash
terraform init && terraform apply -auto-approve
terraform output -raw politica_json
aws iam list-roles --query "Roles[].RoleName"
aws iam list-attached-role-policies --role-name rol-lambda-etl
```

### 🎯 Reto
Añade a la política una condición para que `s3:PutObject` solo se permita si el objeto se sube cifrado (`condition` con `s3:x-amz-server-side-encryption`).

### 🧹 Limpieza
`terraform destroy -auto-approve`

---

## Módulo 5 — Ingesta batch con Lambda y eventos de S3

### Objetivos
Cuando llega un CSV a la zona raw, una Lambda lo valida automáticamente, escribe las filas buenas en processed (JSON Lines) y separa las filas rechazadas.

### 5.1 Subtemas
- **AWS Lambda**: funciones sin servidor que se ejecutan por eventos.
- **Notificaciones de S3**: `ObjectCreated` → invoca la Lambda.
- **Permisos de invocación** (`aws_lambda_permission`): S3 necesita permiso para invocar la Lambda.
- **Empaquetado** con el provider `archive` (zip).
- **Calidad de datos**: validar y separar registros inválidos (*quarantine*).
- **Evitar bucles**: nunca escribir en el mismo bucket/prefijo que dispara la Lambda.

### 5.2 Ejercicio

Carpeta `modulos/05-lambda-ingesta/`:

```
05-lambda-ingesta/
├── providers.tf
├── main.tf
├── datos/ventas.csv     (copia del módulo 3)
└── src/handler.py
```

`src/handler.py`:

```python
import csv
import io
import json
import os
import urllib.parse

import boto3

s3 = boto3.client("s3")
DEST_BUCKET = os.environ["DEST_BUCKET"]
OBLIGATORIOS = ["order_id", "customer_id", "product", "amount", "order_date"]


def validar(fila):
    for campo in OBLIGATORIOS:
        if not fila.get(campo):
            raise ValueError(f"campo vacio: {campo}")
    fila["amount"] = float(fila["amount"])
    if fila["amount"] <= 0:
        raise ValueError("monto debe ser positivo")
    return fila


def handler(event, context):
    for record in event["Records"]:
        bucket = record["s3"]["bucket"]["name"]
        key = urllib.parse.unquote_plus(record["s3"]["object"]["key"])

        contenido = s3.get_object(Bucket=bucket, Key=key)["Body"].read().decode("utf-8-sig")
        validas, rechazadas = [], []

        for fila in csv.DictReader(io.StringIO(contenido)):
            try:
                validas.append(validar(dict(fila)))
            except ValueError as e:
                rechazadas.append({"fila": fila, "error": str(e)})

        base = key.rsplit(".", 1)[0]
        s3.put_object(
            Bucket=DEST_BUCKET,
            Key=f"{base}.jsonl",
            Body="\n".join(json.dumps(v) for v in validas).encode("utf-8"),
        )
        if rechazadas:
            s3.put_object(
                Bucket=DEST_BUCKET,
                Key=f"rechazados/{base}.json",
                Body=json.dumps(rechazadas, indent=2).encode("utf-8"),
            )

        print(json.dumps({"archivo": key, "validas": len(validas), "rechazadas": len(rechazadas)}))

    return {"status": "ok"}
```

> Dentro de LocalStack, `boto3.client("s3")` se conecta solo al emulador (LocalStack redirige las llamadas). En AWS real el mismo código funciona sin cambios.

`main.tf`:

```hcl
resource "aws_s3_bucket" "raw" {
  bucket        = "ingesta-raw"
  force_destroy = true
}

resource "aws_s3_bucket" "processed" {
  bucket        = "ingesta-processed"
  force_destroy = true
}

# --- IAM ---
data "aws_iam_policy_document" "assume" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "lambda" {
  name               = "rol-validador-ventas"
  assume_role_policy = data.aws_iam_policy_document.assume.json
}

data "aws_iam_policy_document" "permisos" {
  statement {
    actions   = ["s3:GetObject"]
    resources = ["${aws_s3_bucket.raw.arn}/*"]
  }
  statement {
    actions   = ["s3:PutObject"]
    resources = ["${aws_s3_bucket.processed.arn}/*"]
  }
  statement {
    actions   = ["logs:CreateLogGroup", "logs:CreateLogStream", "logs:PutLogEvents"]
    resources = ["*"]
  }
}

resource "aws_iam_role_policy" "lambda" {
  role   = aws_iam_role.lambda.id
  policy = data.aws_iam_policy_document.permisos.json
}

# --- Lambda ---
data "archive_file" "lambda" {
  type        = "zip"
  source_file = "${path.module}/src/handler.py"
  output_path = "${path.module}/build/handler.zip"
}

resource "aws_lambda_function" "validador" {
  function_name    = "validador-ventas"
  role             = aws_iam_role.lambda.arn
  handler          = "handler.handler"
  runtime          = "python3.12"
  filename         = data.archive_file.lambda.output_path
  source_code_hash = data.archive_file.lambda.output_base64sha256
  timeout          = 30
  memory_size      = 256

  environment {
    variables = {
      DEST_BUCKET = aws_s3_bucket.processed.bucket
    }
  }
}

# --- Disparador S3 -> Lambda ---
resource "aws_lambda_permission" "s3" {
  statement_id  = "PermitirS3"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.validador.function_name
  principal     = "s3.amazonaws.com"
  source_arn    = aws_s3_bucket.raw.arn
}

resource "aws_s3_bucket_notification" "raw" {
  bucket = aws_s3_bucket.raw.id

  lambda_function {
    lambda_function_arn = aws_lambda_function.validador.arn
    events              = ["s3:ObjectCreated:*"]
    filter_prefix       = "ventas/"
    filter_suffix       = ".csv"
  }

  depends_on = [aws_lambda_permission.s3]
}
```

Despliega y prueba:

```bash
terraform init && terraform apply -auto-approve

aws s3 cp datos/ventas.csv s3://ingesta-raw/ventas/anio=2026/mes=11/dia=04/ventas.csv

# espera unos segundos (la primera ejecución descarga la imagen de Lambda)
aws logs tail /aws/lambda/validador-ventas --since 10m
aws s3 ls s3://ingesta-processed --recursive
aws s3 cp s3://ingesta-processed/rechazados/ventas/anio=2026/mes=11/dia=04/ventas.json -
```

Resultado esperado: 3 filas válidas y 2 rechazadas.

Invocación manual (útil para depurar):

```bash
aws lambda invoke --function-name validador-ventas --payload fileb://evento.json salida.json
```

con `evento.json`:

```json
{"Records":[{"s3":{"bucket":{"name":"ingesta-raw"},"object":{"key":"ventas/anio=2026/mes=11/dia=04/ventas.csv"}}}]}
```

### 🎯 Reto
1. Añade una regla: rechazar filas cuya `order_date` no tenga formato `YYYY-MM-DD`.
2. Cambia el código, ejecuta `terraform apply` y observa cómo `source_code_hash` hace que Terraform redespliegue solo la Lambda.

### 🧹 Limpieza
`terraform destroy -auto-approve`

---

## Módulo 6 — Mensajería con SNS y SQS

### Objetivos
Desacoplar productores y consumidores con el patrón **fan-out** (SNS → varias colas SQS), reintentos y **DLQ** (cola de mensajes fallidos).

### 6.1 Subtemas
- **SQS**: colas; el consumidor *tira* (pull) de los mensajes. Estándar vs. FIFO.
- **SNS**: tópicos pub/sub; *empuja* (push) a los suscriptores.
- **Fan-out**: un evento → varios consumidores independientes.
- **Visibility timeout**, **maxReceiveCount** y **Dead Letter Queue**.
- **Event source mapping**: Lambda lee de SQS automáticamente.
- **Idempotencia**: un mensaje puede llegar más de una vez; el consumidor debe tolerarlo.

### 6.2 Ejercicio: fan-out de pedidos

```
SNS "pedidos" ─┬─► SQS "facturacion" ──► Lambda consumidora ──(falla 3 veces)──► SQS "facturacion-dlq"
               └─► SQS "analitica"   (se lee a mano)
```

Carpeta `modulos/06-mensajeria/`.

`src/consumidor.py`:

```python
import json


def handler(event, context):
    for record in event["Records"]:
        mensaje_sns = json.loads(record["body"])          # SNS envuelve el mensaje
        pedido = json.loads(mensaje_sns["Message"])
        if pedido.get("amount", 0) < 0:
            raise ValueError(f"Pedido invalido: {pedido}")  # provoca reintento -> DLQ
        print(f"Facturando pedido {pedido['order_id']} por {pedido['amount']}")
```

`main.tf`:

```hcl
resource "aws_sns_topic" "pedidos" {
  name = "pedidos"
}

resource "aws_sqs_queue" "facturacion_dlq" {
  name                      = "facturacion-dlq"
  message_retention_seconds = 1209600 # 14 días
}

resource "aws_sqs_queue" "facturacion" {
  name                       = "facturacion"
  visibility_timeout_seconds = 60
  redrive_policy = jsonencode({
    deadLetterTargetArn = aws_sqs_queue.facturacion_dlq.arn
    maxReceiveCount     = 3
  })
}

resource "aws_sqs_queue" "analitica" {
  name = "analitica"
}

# Permitir que SNS escriba en las colas
data "aws_iam_policy_document" "sns_a_sqs" {
  for_each = {
    facturacion = aws_sqs_queue.facturacion.arn
    analitica   = aws_sqs_queue.analitica.arn
  }
  statement {
    actions   = ["sqs:SendMessage"]
    resources = [each.value]
    principals {
      type        = "Service"
      identifiers = ["sns.amazonaws.com"]
    }
    condition {
      test     = "ArnEquals"
      variable = "aws:SourceArn"
      values   = [aws_sns_topic.pedidos.arn]
    }
  }
}

resource "aws_sqs_queue_policy" "colas" {
  for_each = {
    facturacion = aws_sqs_queue.facturacion
    analitica   = aws_sqs_queue.analitica
  }
  queue_url = each.value.id
  policy    = data.aws_iam_policy_document.sns_a_sqs[each.key].json
}

resource "aws_sns_topic_subscription" "colas" {
  for_each = {
    facturacion = aws_sqs_queue.facturacion.arn
    analitica   = aws_sqs_queue.analitica.arn
  }
  topic_arn = aws_sns_topic.pedidos.arn
  protocol  = "sqs"
  endpoint  = each.value
}

# --- Lambda consumidora ---
data "aws_iam_policy_document" "assume" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "consumidor" {
  name               = "rol-consumidor-facturacion"
  assume_role_policy = data.aws_iam_policy_document.assume.json
}

data "aws_iam_policy_document" "consumidor" {
  statement {
    actions   = ["sqs:ReceiveMessage", "sqs:DeleteMessage", "sqs:GetQueueAttributes"]
    resources = [aws_sqs_queue.facturacion.arn]
  }
  statement {
    actions   = ["logs:CreateLogGroup", "logs:CreateLogStream", "logs:PutLogEvents"]
    resources = ["*"]
  }
}

resource "aws_iam_role_policy" "consumidor" {
  role   = aws_iam_role.consumidor.id
  policy = data.aws_iam_policy_document.consumidor.json
}

data "archive_file" "consumidor" {
  type        = "zip"
  source_file = "${path.module}/src/consumidor.py"
  output_path = "${path.module}/build/consumidor.zip"
}

resource "aws_lambda_function" "consumidor" {
  function_name    = "consumidor-facturacion"
  role             = aws_iam_role.consumidor.arn
  handler          = "consumidor.handler"
  runtime          = "python3.12"
  filename         = data.archive_file.consumidor.output_path
  source_code_hash = data.archive_file.consumidor.output_base64sha256
  timeout          = 30
}

resource "aws_lambda_event_source_mapping" "facturacion" {
  event_source_arn = aws_sqs_queue.facturacion.arn
  function_name    = aws_lambda_function.consumidor.arn
  batch_size       = 10
}

output "topic_arn" {
  value = aws_sns_topic.pedidos.arn
}
```

Prueba (crea `pedido_ok.json` y `pedido_malo.json`):

`pedido_ok.json`
```json
{"order_id": 2001, "amount": 50}
```
`pedido_malo.json`
```json
{"order_id": 2002, "amount": -10}
```

```bash
terraform init && terraform apply -auto-approve
topic=$(terraform output -raw topic_arn)

aws sns publish --topic-arn "$topic" --message file://pedido_ok.json
aws sns publish --topic-arn "$topic" --message file://pedido_malo.json

# La cola de analítica recibe ambos
aws sqs receive-message --queue-url http://localstack:4566/000000000000/analitica --max-number-of-messages 10

# Logs de la Lambda
aws logs tail /aws/lambda/consumidor-facturacion --since 10m

# Tras ~3 reintentos (60 s cada uno), el pedido malo llega a la DLQ
aws sqs get-queue-attributes --queue-url http://localstack:4566/000000000000/facturacion-dlq --attribute-names ApproximateNumberOfMessages
```

### 🎯 Reto
Crea una cola FIFO `facturacion.fifo` con `fifo_queue = true` y `content_based_deduplication = true`, y explica en un comentario cuándo usar FIFO en un pipeline de datos.

### 🧹 Limpieza
`terraform destroy -auto-approve`

---

## Módulo 7 — Streaming con Kinesis y Firehose

### Objetivos
Ingerir eventos en tiempo (casi) real: Kinesis Data Streams para procesar al vuelo y Firehose para aterrizar el stream en S3.

### 7.1 Subtemas
- **Kinesis Data Streams**: shards, partition key, retención, orden por shard.
- **Consumidores**: Lambda con `event source mapping` (lotes, posición inicial).
- **Amazon Data Firehose**: entrega gestionada a S3 con *buffering* (tamaño/tiempo) y compresión.
- **Cuándo usar cada uno**: Streams = procesamiento personalizado y baja latencia; Firehose = "llevar todo a S3" sin código.
- Alternativas en AWS real: MSK (Kafka gestionado).

### 7.2 Ejercicio: clickstream de una tienda

```
script productor ──► Kinesis "clicks" ──┬──► Lambda (cuenta eventos por tipo, logs)
                                        └──► Firehose ──► S3 "stream-raw/clicks/"
```

Carpeta `modulos/07-streaming/`.

`src/consumidor_kinesis.py`:

```python
import base64
import json
from collections import Counter


def handler(event, context):
    tipos = Counter()
    for record in event["Records"]:
        evento = json.loads(base64.b64decode(record["kinesis"]["data"]))
        tipos[evento["tipo"]] += 1
    print(json.dumps({"lote": len(event["Records"]), "por_tipo": tipos}))
```

`main.tf`:

```hcl
resource "aws_kinesis_stream" "clicks" {
  name             = "clicks"
  shard_count      = 1
  retention_period = 24
}

resource "aws_s3_bucket" "stream_raw" {
  bucket        = "stream-raw"
  force_destroy = true
}

# --- Rol para Firehose ---
data "aws_iam_policy_document" "assume_firehose" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["firehose.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "firehose" {
  name               = "rol-firehose-clicks"
  assume_role_policy = data.aws_iam_policy_document.assume_firehose.json
}

data "aws_iam_policy_document" "firehose" {
  statement {
    actions   = ["kinesis:DescribeStream", "kinesis:GetShardIterator", "kinesis:GetRecords", "kinesis:ListShards"]
    resources = [aws_kinesis_stream.clicks.arn]
  }
  statement {
    actions   = ["s3:PutObject", "s3:GetBucketLocation", "s3:ListBucket"]
    resources = [aws_s3_bucket.stream_raw.arn, "${aws_s3_bucket.stream_raw.arn}/*"]
  }
}

resource "aws_iam_role_policy" "firehose" {
  role   = aws_iam_role.firehose.id
  policy = data.aws_iam_policy_document.firehose.json
}

resource "aws_kinesis_firehose_delivery_stream" "clicks_s3" {
  name        = "clicks-a-s3"
  destination = "extended_s3"

  kinesis_source_configuration {
    kinesis_stream_arn = aws_kinesis_stream.clicks.arn
    role_arn           = aws_iam_role.firehose.arn
  }

  extended_s3_configuration {
    role_arn           = aws_iam_role.firehose.arn
    bucket_arn         = aws_s3_bucket.stream_raw.arn
    prefix             = "clicks/"
    buffering_size     = 1
    buffering_interval = 60
  }
}

# --- Lambda consumidora ---
data "aws_iam_policy_document" "assume_lambda" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "lambda" {
  name               = "rol-consumidor-kinesis"
  assume_role_policy = data.aws_iam_policy_document.assume_lambda.json
}

data "aws_iam_policy_document" "lambda" {
  statement {
    actions = [
      "kinesis:DescribeStream", "kinesis:DescribeStreamSummary", "kinesis:GetShardIterator",
      "kinesis:GetRecords", "kinesis:ListShards", "kinesis:ListStreams"
    ]
    resources = [aws_kinesis_stream.clicks.arn]
  }
  statement {
    actions   = ["logs:CreateLogGroup", "logs:CreateLogStream", "logs:PutLogEvents"]
    resources = ["*"]
  }
}

resource "aws_iam_role_policy" "lambda" {
  role   = aws_iam_role.lambda.id
  policy = data.aws_iam_policy_document.lambda.json
}

data "archive_file" "lambda" {
  type        = "zip"
  source_file = "${path.module}/src/consumidor_kinesis.py"
  output_path = "${path.module}/build/consumidor_kinesis.zip"
}

resource "aws_lambda_function" "consumidor" {
  function_name    = "consumidor-clicks"
  role             = aws_iam_role.lambda.arn
  handler          = "consumidor_kinesis.handler"
  runtime          = "python3.12"
  filename         = data.archive_file.lambda.output_path
  source_code_hash = data.archive_file.lambda.output_base64sha256
}

resource "aws_lambda_event_source_mapping" "clicks" {
  event_source_arn  = aws_kinesis_stream.clicks.arn
  function_name     = aws_lambda_function.consumidor.arn
  starting_position = "LATEST"
  batch_size        = 50
}
```

Productor: `scripts/productor_clicks.py` (en la raíz del curso):

```python
import json
import random
import time
from datetime import datetime, timezone

import boto3

# Las credenciales y la dirección de LocalStack vienen de las variables
# de entorno del contenedor "herramientas" (AWS_ENDPOINT_URL, etc.)
kinesis = boto3.client("kinesis")

TIPOS = ["vista", "click", "carrito", "compra"]

for i in range(200):
    usuario = f"U{random.randint(1, 20):02d}"
    evento = {
        "evento_id": i,
        "usuario": usuario,
        "tipo": random.choices(TIPOS, weights=[60, 25, 10, 5])[0],
        "ts": datetime.now(timezone.utc).isoformat(),
    }
    kinesis.put_record(StreamName="clicks", Data=json.dumps(evento) + "\n", PartitionKey=usuario)
    time.sleep(0.05)

print("200 eventos enviados")
```

Ejecuta:

```bash
terraform init && terraform apply -auto-approve
python /curso/scripts/productor_clicks.py

aws logs tail /aws/lambda/consumidor-clicks --since 10m
# espera ~60 s al buffer de Firehose
aws s3 ls s3://stream-raw/clicks/ --recursive
```

> Fíjate en que el productor añade `"\n"` a cada evento: así Firehose escribe un JSON por línea (JSON Lines), formato fácil de leer luego con Spark o DuckDB.

### 🎯 Reto
Añade `compression_format = "GZIP"` a Firehose y comprueba que los archivos en S3 llegan comprimidos.

### 🧹 Limpieza
`terraform destroy -auto-approve`

---

## Módulo 8 — Bases NoSQL con DynamoDB

### Objetivos
Modelar datos de acceso rápido por clave, con índices secundarios, TTL y DynamoDB Streams para propagar cambios (CDC).

### 8.1 Subtemas
- **Clave de partición (PK)** y **clave de ordenación (SK)**.
- **Modelado por patrones de acceso**: primero las preguntas, luego la tabla.
- **GSI** (índice secundario global) para consultas alternativas.
- **Capacidad**: `PAY_PER_REQUEST` vs. aprovisionada.
- **TTL**: borrado automático de elementos expirados.
- **DynamoDB Streams**: captura de cambios (CDC) para alimentar el lago.

### 8.2 Ejercicio: tabla de pedidos con CDC hacia S3

Patrones de acceso:
1. Pedidos de un cliente ordenados por fecha → `PK = cliente`, `SK = fecha#pedido`.
2. Pedidos por estado → GSI `estado-index`.

Carpeta `modulos/08-dynamodb/`.

`src/cdc.py`:

```python
import json
import os
from datetime import datetime, timezone

import boto3

s3 = boto3.client("s3")
BUCKET = os.environ["BUCKET_CDC"]


def handler(event, context):
    cambios = [
        {
            "operacion": r["eventName"],              # INSERT | MODIFY | REMOVE
            "claves": r["dynamodb"]["Keys"],
            "nuevo": r["dynamodb"].get("NewImage"),
            "anterior": r["dynamodb"].get("OldImage"),
        }
        for r in event["Records"]
    ]
    ahora = datetime.now(timezone.utc)
    key = f"pedidos/fecha={ahora:%Y-%m-%d}/{ahora:%H%M%S%f}.jsonl"
    s3.put_object(Bucket=BUCKET, Key=key, Body="\n".join(json.dumps(c) for c in cambios))
    print(f"{len(cambios)} cambios escritos en s3://{BUCKET}/{key}")
```

`main.tf`:

```hcl
resource "aws_dynamodb_table" "pedidos" {
  name         = "pedidos"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "cliente_id"
  range_key    = "fecha_pedido"

  attribute {
    name = "cliente_id"
    type = "S"
  }
  attribute {
    name = "fecha_pedido"
    type = "S"
  }
  attribute {
    name = "estado"
    type = "S"
  }

  global_secondary_index {
    name            = "estado-index"
    hash_key        = "estado"
    range_key       = "fecha_pedido"
    projection_type = "ALL"
  }

  ttl {
    attribute_name = "expira_en"
    enabled        = true
  }

  stream_enabled   = true
  stream_view_type = "NEW_AND_OLD_IMAGES"
}

resource "aws_s3_bucket" "cdc" {
  bucket        = "cdc-pedidos"
  force_destroy = true
}

data "aws_iam_policy_document" "assume" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "cdc" {
  name               = "rol-cdc-pedidos"
  assume_role_policy = data.aws_iam_policy_document.assume.json
}

data "aws_iam_policy_document" "cdc" {
  statement {
    actions   = ["dynamodb:GetRecords", "dynamodb:GetShardIterator", "dynamodb:DescribeStream", "dynamodb:ListStreams"]
    resources = [aws_dynamodb_table.pedidos.stream_arn]
  }
  statement {
    actions   = ["s3:PutObject"]
    resources = ["${aws_s3_bucket.cdc.arn}/*"]
  }
  statement {
    actions   = ["logs:CreateLogGroup", "logs:CreateLogStream", "logs:PutLogEvents"]
    resources = ["*"]
  }
}

resource "aws_iam_role_policy" "cdc" {
  role   = aws_iam_role.cdc.id
  policy = data.aws_iam_policy_document.cdc.json
}

data "archive_file" "cdc" {
  type        = "zip"
  source_file = "${path.module}/src/cdc.py"
  output_path = "${path.module}/build/cdc.zip"
}

resource "aws_lambda_function" "cdc" {
  function_name    = "cdc-pedidos"
  role             = aws_iam_role.cdc.arn
  handler          = "cdc.handler"
  runtime          = "python3.12"
  filename         = data.archive_file.cdc.output_path
  source_code_hash = data.archive_file.cdc.output_base64sha256
  environment {
    variables = { BUCKET_CDC = aws_s3_bucket.cdc.bucket }
  }
}

resource "aws_lambda_event_source_mapping" "cdc" {
  event_source_arn  = aws_dynamodb_table.pedidos.stream_arn
  function_name     = aws_lambda_function.cdc.arn
  starting_position = "LATEST"
  batch_size        = 25
}

# Datos semilla gestionados por Terraform
resource "aws_dynamodb_table_item" "semilla" {
  for_each   = { "C01#1" = "PAGADO", "C01#2" = "ENVIADO", "C02#1" = "PAGADO" }
  table_name = aws_dynamodb_table.pedidos.name
  hash_key   = aws_dynamodb_table.pedidos.hash_key
  range_key  = aws_dynamodb_table.pedidos.range_key

  item = jsonencode({
    cliente_id   = { S = split("#", each.key)[0] }
    fecha_pedido = { S = "2026-11-0${split("#", each.key)[1]}#P${replace(each.key, "#", "")}" }
    estado       = { S = each.value }
    total        = { N = "100" }
  })

  depends_on = [aws_lambda_event_source_mapping.cdc]
}
```

Prueba:

```bash
terraform init && terraform apply -auto-approve

# Patrón 1: pedidos del cliente C01
aws dynamodb query --table-name pedidos \
  --key-condition-expression "cliente_id = :c" \
  --expression-attribute-values '{":c":{"S":"C01"}}'

# Patrón 2: pedidos PAGADOS (por el GSI)
aws dynamodb query --table-name pedidos --index-name estado-index \
  --key-condition-expression "estado = :e" \
  --expression-attribute-values '{":e":{"S":"PAGADO"}}'

# Genera un cambio y revisa el CDC en S3
aws dynamodb update-item --table-name pedidos \
  --key '{"cliente_id":{"S":"C02"},"fecha_pedido":{"S":"2026-11-01#PC021"}}' \
  --update-expression "SET estado = :e" \
  --expression-attribute-values '{":e":{"S":"ENVIADO"}}'

aws logs tail /aws/lambda/cdc-pedidos --since 10m
aws s3 ls s3://cdc-pedidos --recursive
```

> En bash, el JSON va entre comillas simples y no hay que escapar nada. Si el JSON es largo, guárdalo en un archivo y usa `file://archivo.json`.

### 🎯 Reto
Añade un patrón de acceso nuevo: "pedidos de un producto". Diseña y crea el GSI necesario.

### 🧹 Limpieza
`terraform destroy -auto-approve`

---

## Módulo 9 — Orquestación con Step Functions y EventBridge

### Objetivos
Coordinar los pasos de un pipeline con una máquina de estados y programarlo para que corra solo.

### 9.1 Subtemas
- **Step Functions**: estados `Task`, `Choice`, `Pass`, `Wait`, `Parallel`, `Map`, `Succeed`, `Fail`.
- **Reintentos y manejo de errores** (`Retry`, `Catch`).
- **Integraciones directas** (por ejemplo `dynamodb:putItem`) sin escribir Lambdas.
- **EventBridge**: reglas programadas (`rate`, `cron`) y reglas por patrón de evento.
- En AWS real también existen MWAA (Airflow gestionado) y Glue Workflows.

### 9.2 Ejercicio: pipeline diario orquestado

```
EventBridge (cada 5 min) ──► Step Functions:
     ContarArchivos (Lambda) ──► ¿hay archivos? ──sí──► RegistrarMetrica (DynamoDB putItem) ──► Fin
                                        └──no──► SinDatos (Succeed)
     Errores ──► Catch ──► Fallo (Fail)
```

Carpeta `modulos/09-orquestacion/`.

`src/contar.py`:

```python
import os
from datetime import datetime, timezone

import boto3

s3 = boto3.client("s3")


def handler(event, context):
    bucket = os.environ["BUCKET"]
    respuesta = s3.list_objects_v2(Bucket=bucket, Prefix=event.get("prefijo", ""))
    total = respuesta.get("KeyCount", 0)
    return {
        "fecha": datetime.now(timezone.utc).isoformat(),
        "bucket": bucket,
        "total": total,
        "total_str": str(total),   # DynamoDB necesita los números como string
    }
```

`main.tf`:

```hcl
resource "aws_s3_bucket" "datos" {
  bucket        = "orquestacion-datos"
  force_destroy = true
}

resource "aws_dynamodb_table" "metricas" {
  name         = "metricas-pipeline"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "ejecucion"
  attribute {
    name = "ejecucion"
    type = "S"
  }
}

# --- Lambda ---
data "aws_iam_policy_document" "assume_lambda" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "lambda" {
  name               = "rol-lambda-contar"
  assume_role_policy = data.aws_iam_policy_document.assume_lambda.json
}

resource "aws_iam_role_policy" "lambda" {
  role = aws_iam_role.lambda.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      { Effect = "Allow", Action = ["s3:ListBucket"], Resource = aws_s3_bucket.datos.arn },
      { Effect = "Allow", Action = ["logs:*"], Resource = "*" }
    ]
  })
}

data "archive_file" "contar" {
  type        = "zip"
  source_file = "${path.module}/src/contar.py"
  output_path = "${path.module}/build/contar.zip"
}

resource "aws_lambda_function" "contar" {
  function_name    = "contar-archivos"
  role             = aws_iam_role.lambda.arn
  handler          = "contar.handler"
  runtime          = "python3.12"
  filename         = data.archive_file.contar.output_path
  source_code_hash = data.archive_file.contar.output_base64sha256
  environment {
    variables = { BUCKET = aws_s3_bucket.datos.bucket }
  }
}

# --- Step Functions ---
data "aws_iam_policy_document" "assume_sfn" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["states.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "sfn" {
  name               = "rol-sfn-pipeline"
  assume_role_policy = data.aws_iam_policy_document.assume_sfn.json
}

resource "aws_iam_role_policy" "sfn" {
  role = aws_iam_role.sfn.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      { Effect = "Allow", Action = ["lambda:InvokeFunction"], Resource = aws_lambda_function.contar.arn },
      { Effect = "Allow", Action = ["dynamodb:PutItem"], Resource = aws_dynamodb_table.metricas.arn }
    ]
  })
}

resource "aws_sfn_state_machine" "pipeline" {
  name     = "pipeline-diario"
  role_arn = aws_iam_role.sfn.arn

  definition = jsonencode({
    Comment = "Pipeline diario de ejemplo"
    StartAt = "ContarArchivos"
    States = {
      ContarArchivos = {
        Type     = "Task"
        Resource = aws_lambda_function.contar.arn
        Retry = [{
          ErrorEquals     = ["States.TaskFailed"]
          IntervalSeconds = 2
          MaxAttempts     = 2
          BackoffRate     = 2
        }]
        Catch = [{ ErrorEquals = ["States.ALL"], Next = "Fallo" }]
        Next  = "HayArchivos"
      }
      HayArchivos = {
        Type = "Choice"
        Choices = [{
          Variable           = "$.total"
          NumericGreaterThan = 0
          Next               = "RegistrarMetrica"
        }]
        Default = "SinDatos"
      }
      RegistrarMetrica = {
        Type     = "Task"
        Resource = "arn:aws:states:::dynamodb:putItem"
        Parameters = {
          TableName = aws_dynamodb_table.metricas.name
          Item = {
            ejecucion = { "S.$" = "$.fecha" }
            bucket    = { "S.$" = "$.bucket" }
            archivos  = { "N.$" = "$.total_str" }
          }
        }
        End = true
      }
      SinDatos = { Type = "Succeed" }
      Fallo    = { Type = "Fail", Error = "PipelineError", Cause = "Fallo al contar archivos" }
    }
  })
}

# --- EventBridge: ejecución programada ---
data "aws_iam_policy_document" "assume_events" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["events.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "events" {
  name               = "rol-events-pipeline"
  assume_role_policy = data.aws_iam_policy_document.assume_events.json
}

resource "aws_iam_role_policy" "events" {
  role = aws_iam_role.events.id
  policy = jsonencode({
    Version   = "2012-10-17"
    Statement = [{ Effect = "Allow", Action = ["states:StartExecution"], Resource = aws_sfn_state_machine.pipeline.arn }]
  })
}

resource "aws_cloudwatch_event_rule" "cada_5_min" {
  name                = "pipeline-cada-5-min"
  schedule_expression = "rate(5 minutes)"
}

resource "aws_cloudwatch_event_target" "sfn" {
  rule     = aws_cloudwatch_event_rule.cada_5_min.name
  arn      = aws_sfn_state_machine.pipeline.arn
  role_arn = aws_iam_role.events.arn
  input    = jsonencode({ prefijo = "" })
}

output "state_machine_arn" {
  value = aws_sfn_state_machine.pipeline.arn
}
```

Prueba manual (sin esperar a EventBridge):

```bash
terraform init && terraform apply -auto-approve
sm=$(terraform output -raw state_machine_arn)

# 1) Sin archivos -> SinDatos
aws stepfunctions start-execution --state-machine-arn "$sm" --input '{}'
aws stepfunctions list-executions --state-machine-arn "$sm"

# 2) Con archivos -> RegistrarMetrica
aws s3 cp ../03-data-lake/datos/ventas.csv s3://orquestacion-datos/ventas.csv
aws stepfunctions start-execution --state-machine-arn "$sm" --input '{}'
aws dynamodb scan --table-name metricas-pipeline

# Ver el detalle de una ejecución
aws stepfunctions get-execution-history --execution-arn <arn-de-la-ejecucion>
```

### 🎯 Reto
Añade un estado `Map` que procese en paralelo una lista de prefijos (`["ventas/", "clientes/"]`), contando archivos de cada uno.

### 🧹 Limpieza
`terraform destroy -auto-approve`

---

## Módulo 10 — Secretos y configuración

### Objetivos
Nunca poner contraseñas en el código: guardarlas en Secrets Manager, la configuración en SSM Parameter Store, y cifrar con KMS.

### 10.1 Subtemas
- **Secrets Manager**: credenciales de bases de datos y APIs, con rotación.
- **SSM Parameter Store**: configuración (`String`, `StringList`, `SecureString`).
- **KMS**: claves de cifrado gestionadas, alias y rotación.
- **Generar secretos** con el provider `random`.
- Cuidado: los secretos generados por Terraform quedan en el **state** → el state debe estar cifrado y con acceso restringido (módulo 15).

### 10.2 Ejercicio: credenciales del data warehouse

Carpeta `modulos/10-secretos/`. Añade a `providers.tf` dentro de `required_providers`:

```hcl
    random = {
      source  = "hashicorp/random"
      version = "~> 3.6"
    }
```

`main.tf`:

```hcl
resource "aws_kms_key" "datos" {
  description         = "Clave para secretos y datos del curso"
  enable_key_rotation = true
}

resource "aws_kms_alias" "datos" {
  name          = "alias/curso-datos"
  target_key_id = aws_kms_key.datos.key_id
}

resource "random_password" "dwh" {
  length  = 24
  special = false
}

resource "aws_secretsmanager_secret" "dwh" {
  name                    = "curso/dwh/credenciales"
  kms_key_id              = aws_kms_key.datos.arn
  recovery_window_in_days = 0 # solo en práctica: borrado inmediato
}

resource "aws_secretsmanager_secret_version" "dwh" {
  secret_id = aws_secretsmanager_secret.dwh.id
  secret_string = jsonencode({
    host     = "dwh"
    port     = 5432
    database = "dwh"
    username = "etl_user"
    password = random_password.dwh.result
  })
}

resource "aws_ssm_parameter" "config" {
  for_each = {
    "/curso/pipeline/bucket_raw"     = "datalake-dev-raw"
    "/curso/pipeline/tamano_lote"    = "500"
    "/curso/pipeline/correo_alertas" = "datos@ejemplo.com"
  }
  name  = each.key
  type  = "String"
  value = each.value
}

resource "aws_ssm_parameter" "api_key" {
  name   = "/curso/pipeline/api_key_proveedor"
  type   = "SecureString"
  key_id = aws_kms_key.datos.arn
  value  = "cambiar-me"
}
```

`src/leer_config.py` (Lambda que lee configuración y secreto):

```python
import json

import boto3

secrets = boto3.client("secretsmanager")
ssm = boto3.client("ssm")


def handler(event, context):
    params = ssm.get_parameters_by_path(Path="/curso/pipeline/", WithDecryption=True)["Parameters"]
    config = {p["Name"].split("/")[-1]: p["Value"] for p in params}

    secreto = json.loads(secrets.get_secret_value(SecretId="curso/dwh/credenciales")["SecretString"])
    # Nunca imprimas la contraseña en los logs:
    print(f"Conectaria a {secreto['host']}:{secreto['port']} como {secreto['username']}")
    print(f"Config: { {k: v for k, v in config.items() if k != 'api_key_proveedor'} }")
    return {"ok": True}
```

Añade al `main.tf` la Lambda (mismo patrón que en módulos anteriores) con un rol que permita `secretsmanager:GetSecretValue` sobre el secreto, `ssm:GetParametersByPath` sobre `arn:aws:ssm:*:*:parameter/curso/pipeline*` y `kms:Decrypt` sobre la clave.

Verifica:

```bash
terraform init && terraform apply -auto-approve
aws secretsmanager get-secret-value --secret-id curso/dwh/credenciales --query SecretString --output text
aws ssm get-parameters-by-path --path /curso/pipeline/ --with-decryption
aws lambda invoke --function-name leer-config salida.json && cat salida.json
```

### 🎯 Reto
Busca el password en `terraform.tfstate` con `grep password terraform.tfstate`. Reflexiona: ¿por qué esto obliga a proteger el state? Marca el output como `sensitive = true` si lo expones.

### 🧹 Limpieza
`terraform destroy -auto-approve`

---

## Módulo 11 — Observabilidad con CloudWatch

### Objetivos
Saber cuándo un pipeline falla: logs con retención, métricas, filtros de métricas y alarmas que notifican.

### 11.1 Subtemas
- **CloudWatch Logs**: grupos de logs, retención, consultas.
- **Métricas** nativas (`AWS/Lambda` Errors, Duration, Invocations) y personalizadas.
- **Metric filters**: convertir líneas de log en métricas (por ejemplo, contar `"rechazadas"`).
- **Alarmas** → SNS → correo, Slack, PagerDuty.
- **Logs estructurados** en JSON: más fáciles de filtrar.

### 11.2 Ejercicio: alarmas sobre la Lambda de validación

Reutiliza el código del módulo 5. Copia `modulos/05-lambda-ingesta/` a `modulos/11-observabilidad/` y añade `observabilidad.tf`:

```hcl
# Crear el log group ANTES que la Lambda permite controlar la retención
resource "aws_cloudwatch_log_group" "validador" {
  name              = "/aws/lambda/validador-ventas"
  retention_in_days = 14
}

resource "aws_sns_topic" "alertas" {
  name = "alertas-datos"
}

# Cola suscrita al tópico para "ver" las alertas en local (en AWS usarías email)
resource "aws_sqs_queue" "buzon_alertas" {
  name = "buzon-alertas"
}

resource "aws_sns_topic_subscription" "buzon" {
  topic_arn = aws_sns_topic.alertas.arn
  protocol  = "sqs"
  endpoint  = aws_sqs_queue.buzon_alertas.arn
}

# Métrica a partir de logs: filas rechazadas
resource "aws_cloudwatch_log_metric_filter" "rechazadas" {
  name           = "filas-rechazadas"
  log_group_name = aws_cloudwatch_log_group.validador.name
  pattern        = "{ $.rechazadas > 0 }"

  metric_transformation {
    name      = "FilasRechazadas"
    namespace = "CursoDatos"
    value     = "$.rechazadas"
  }
}

# Alarma 1: errores de la Lambda
resource "aws_cloudwatch_metric_alarm" "errores_lambda" {
  alarm_name          = "validador-ventas-errores"
  namespace           = "AWS/Lambda"
  metric_name         = "Errors"
  dimensions          = { FunctionName = aws_lambda_function.validador.function_name }
  statistic           = "Sum"
  period              = 60
  evaluation_periods  = 1
  threshold           = 0
  comparison_operator = "GreaterThanThreshold"
  treat_missing_data  = "notBreaching"
  alarm_actions       = [aws_sns_topic.alertas.arn]
}

# Alarma 2: demasiadas filas rechazadas
resource "aws_cloudwatch_metric_alarm" "rechazadas" {
  alarm_name          = "demasiadas-filas-rechazadas"
  namespace           = "CursoDatos"
  metric_name         = "FilasRechazadas"
  statistic           = "Sum"
  period              = 300
  evaluation_periods  = 1
  threshold           = 10
  comparison_operator = "GreaterThanThreshold"
  treat_missing_data  = "notBreaching"
  alarm_actions       = [aws_sns_topic.alertas.arn]
}
```

Añade `depends_on = [aws_cloudwatch_log_group.validador]` a `aws_lambda_function.validador`.

> Necesitas que la cola acepte mensajes de SNS: añade una `aws_sqs_queue_policy` como en el módulo 6.

Prueba:

```bash
terraform init && terraform apply -auto-approve
aws s3 cp datos/ventas.csv s3://ingesta-raw/ventas/v1.csv

aws logs filter-log-events --log-group-name /aws/lambda/validador-ventas --filter-pattern rechazadas
aws cloudwatch describe-alarms --query "MetricAlarms[].[AlarmName,StateValue]"

# Forzar la alarma para probar la notificación
aws cloudwatch set-alarm-state --alarm-name validador-ventas-errores --state-value ALARM --state-reason "prueba"
aws sqs receive-message --queue-url http://localstack:4566/000000000000/buzon-alertas
```

### 🎯 Reto
Crea un `aws_cloudwatch_dashboard` con un widget de invocaciones y errores de la Lambda.

### 🧹 Limpieza
`terraform destroy -auto-approve`

---

## Módulo 12 — Procesamiento con Spark (Glue simulado)

### Objetivos
Transformar datos de processed a curated con Apache Spark, escribiendo **Parquet particionado**. Es lo que hace un **Glue Job** en AWS real.

### 12.1 Subtemas
- **AWS Glue**: jobs de Spark sin servidor, Data Catalog, crawlers.
- **Spark**: DataFrames, transformaciones perezosas, acciones.
- **Parquet**: formato columnar, compresión, *predicate pushdown*.
- **Particionado** al escribir (`partitionBy`) y tamaño de archivos.
- **Conector S3A**: cómo Spark lee y escribe en S3 (aquí en LocalStack).
- Limitación: LocalStack gratuito no tiene Glue, así que ejecutamos el **mismo código PySpark** en un contenedor de Spark.

### 12.2 Ejercicio

**Paso 1 — Infraestructura con Terraform.** Carpeta `modulos/12-spark/`:

`main.tf`:

```hcl
resource "aws_s3_bucket" "zona" {
  for_each      = toset(["processed", "curated", "scripts"])
  bucket        = "lake-${each.key}"
  force_destroy = true
}

# Datos de entrada (JSON Lines) en processed
resource "aws_s3_object" "ventas" {
  bucket = aws_s3_bucket.zona["processed"].id
  key    = "ventas/ventas.jsonl"
  source = "${path.module}/datos/ventas.jsonl"
  etag   = filemd5("${path.module}/datos/ventas.jsonl")
}

# Guardamos el script en S3 como haría Glue (script_location)
resource "aws_s3_object" "script" {
  bucket = aws_s3_bucket.zona["scripts"].id
  key    = "jobs/ventas_curated.py"
  source = "${path.module}/../../jobs/ventas_curated.py"
  etag   = filemd5("${path.module}/../../jobs/ventas_curated.py")
}
```

`datos/ventas.jsonl`:

```json
{"order_id": "1001", "customer_id": "C01", "product": "teclado", "amount": 45.5, "order_date": "2026-11-03"}
{"order_id": "1002", "customer_id": "C02", "product": "mouse", "amount": 19.99, "order_date": "2026-11-03"}
{"order_id": "1003", "customer_id": "C01", "product": "monitor", "amount": 189.0, "order_date": "2026-11-04"}
{"order_id": "1006", "customer_id": "C03", "product": "teclado", "amount": 45.5, "order_date": "2026-11-04"}
{"order_id": "1007", "customer_id": "C02", "product": "monitor", "amount": 189.0, "order_date": "2026-11-04"}
{"order_id": "1007", "customer_id": "C02", "product": "monitor", "amount": 189.0, "order_date": "2026-11-04"}
```

> La última fila está duplicada a propósito.

**Paso 2 — El job de Spark.** `jobs/ventas_curated.py` (en la raíz del curso):

```python
from pyspark.sql import SparkSession, functions as F

spark = SparkSession.builder.appName("ventas_curated").getOrCreate()

ventas = (
    spark.read.json("s3a://lake-processed/ventas/")
    .dropDuplicates(["order_id"])
    .withColumn("amount", F.col("amount").cast("decimal(10,2)"))
    .withColumn("order_date", F.to_date("order_date"))
    .withColumn("anio", F.year("order_date"))
    .withColumn("mes", F.month("order_date"))
)

# Tabla de hechos limpia, particionada
(ventas.write.mode("overwrite")
    .partitionBy("anio", "mes")
    .parquet("s3a://lake-curated/fact_ventas/"))

# Agregado de negocio: ventas por día y producto
resumen = (ventas.groupBy("order_date", "product")
    .agg(F.count("*").alias("pedidos"), F.sum("amount").alias("total")))

resumen.write.mode("overwrite").parquet("s3a://lake-curated/ventas_diarias/")

resumen.orderBy("order_date", "product").show()
spark.stop()
```

**Paso 3 — Ejecutar.**

```bash
# desde la carpeta del módulo
terraform init && terraform apply -auto-approve

# desde la raíz del curso
docker compose --profile spark up -d spark

docker exec spark /opt/spark/bin/spark-submit \
  --packages org.apache.hadoop:hadoop-aws:3.3.4,com.amazonaws:aws-java-sdk-bundle:1.12.262 \
  --conf spark.hadoop.fs.s3a.endpoint=http://localstack:4566 \
  --conf spark.hadoop.fs.s3a.path.style.access=true \
  --conf spark.hadoop.fs.s3a.connection.ssl.enabled=false \
  --conf spark.hadoop.fs.s3a.access.key=test \
  --conf spark.hadoop.fs.s3a.secret.key=test \
  --conf spark.hadoop.fs.s3a.aws.credentials.provider=org.apache.hadoop.fs.s3a.SimpleAWSCredentialsProvider \
  /opt/jobs/ventas_curated.py

aws s3 ls s3://lake-curated --recursive
```

> La primera ejecución tarda porque descarga los JARs de `hadoop-aws`. Dentro de Docker, LocalStack se llama `localstack` (no `localhost`) porque ambos contenedores comparten la red de Compose.

**Paso 4 — Así sería en AWS real.** Un único recurso Terraform reemplaza el `spark-submit`:

```hcl
resource "aws_glue_job" "ventas_curated" {
  name         = "ventas-curated"
  role_arn     = aws_iam_role.glue.arn
  glue_version = "5.0"
  worker_type  = "G.1X"
  number_of_workers = 2

  command {
    name            = "glueetl"
    script_location = "s3://lake-scripts/jobs/ventas_curated.py"
    python_version  = "3"
  }
}
```

(No lo apliques en LocalStack gratuito: fallará porque Glue no está disponible.)

### 🎯 Reto
Añade una dimensión `dim_clientes` (deduplicada por `customer_id`) y un agregado de "top clientes por monto".

### 🧹 Limpieza
`terraform destroy -auto-approve` y `docker compose --profile spark stop spark`

---

## Módulo 13 — Consultas SQL sobre el lago (Athena simulado)

### Objetivos
Consultar con SQL los Parquet de S3 directamente, sin cargarlos en una base de datos. Es lo que hace **Athena** en AWS real.

### 13.1 Subtemas
- **Athena**: SQL serverless (Trino) sobre S3; se paga por datos escaneados.
- **Glue Data Catalog**: metadatos (tablas, columnas, particiones) sobre los archivos.
- **Particiones y formato columnar**: reducen el costo y el tiempo de consulta.
- **Equivalente local**: DuckDB lee Parquet desde S3 (LocalStack) con la extensión `httpfs`.

### 13.2 Ejercicio

Requisito: haber ejecutado el módulo 12 (los datos deben estar en `lake-curated`).

DuckDB ya viene instalado en el contenedor `herramientas`.

`scripts/consultas_lago.py`:

```python
import duckdb

con = duckdb.connect()
con.execute("INSTALL httpfs; LOAD httpfs;")
con.execute("""
    CREATE SECRET localstack (
        TYPE S3, KEY_ID 'test', SECRET 'test', REGION 'us-east-1',
        ENDPOINT 'localstack:4566', URL_STYLE 'path', USE_SSL false
    );
""")

# "Tabla externa" como en Athena
con.execute("""
    CREATE VIEW fact_ventas AS
    SELECT * FROM read_parquet('s3://lake-curated/fact_ventas/*/*/*.parquet', hive_partitioning = true);
""")

print("== Ventas por mes ==")
con.sql("""
    SELECT anio, mes, COUNT(*) AS pedidos, SUM(amount) AS total
    FROM fact_ventas
    GROUP BY anio, mes
    ORDER BY anio, mes
""").show()

print("== Top productos ==")
con.sql("""
    SELECT product, SUM(amount) AS total
    FROM fact_ventas
    GROUP BY product
    ORDER BY total DESC
""").show()

print("== Poda de particiones: solo lee mes = 11 ==")
con.sql("EXPLAIN SELECT * FROM fact_ventas WHERE mes = 11").show()
```

Ejecuta:

```bash
python scripts/consultas_lago.py
```

**Así sería en AWS real** (para que conozcas los recursos):

```hcl
resource "aws_glue_catalog_database" "lake" {
  name = "lake_curated"
}

resource "aws_athena_workgroup" "analitica" {
  name = "analitica"
  configuration {
    result_configuration {
      output_location = "s3://lake-athena-resultados/"
    }
    bytes_scanned_cutoff_per_query = 1073741824 # 1 GB: protege el bolsillo
  }
}

resource "aws_glue_crawler" "curated" {
  name          = "crawler-curated"
  database_name = aws_glue_catalog_database.lake.name
  role          = aws_iam_role.glue.arn
  s3_target {
    path = "s3://lake-curated/fact_ventas/"
  }
}
```

### 🎯 Reto
Escribe una consulta que calcule, para cada cliente, su ticket promedio y el número de días distintos en que compró.

---

## Módulo 14 — Data Warehouse (Redshift simulado)

### Objetivos
Cargar el modelo curado en un data warehouse relacional con **modelo dimensional** (estrella). Usamos PostgreSQL como sustituto de **Redshift** (Redshift está basado en PostgreSQL) y lo administramos también con Terraform.

### 14.1 Subtemas
- **Modelo dimensional**: tablas de hechos (eventos medibles) y dimensiones (contexto).
- **Esquemas por capa**: `staging` (carga cruda) y `analytics` (modelo final).
- **Carga**: en Redshift `COPY` desde S3; aquí DuckDB lee de S3 y escribe en Postgres.
- **Gobierno de acceso**: roles de solo lectura para analistas.
- En AWS real: Redshift Serverless, distribución y claves de ordenación, Redshift Spectrum.

### 14.2 Ejercicio

**Paso 1 — Levantar Postgres.**

```bash
docker compose --profile dwh up -d postgres
```

**Paso 2 — Esquemas y roles con Terraform.** Carpeta `modulos/14-dwh/`, `main.tf`:

```hcl
terraform {
  required_providers {
    postgresql = {
      source  = "cyrilgdn/postgresql"
      version = "~> 1.25"
    }
  }
}

provider "postgresql" {
  host            = "dwh"
  port            = 5432
  database        = "dwh"
  username        = "dwh_admin"
  password        = "dwh_admin"   # en real: leer de Secrets Manager (módulo 10)
  sslmode         = "disable"
  superuser       = false
}

resource "postgresql_schema" "capa" {
  for_each = toset(["staging", "analytics"])
  name     = each.key
}

resource "postgresql_role" "etl" {
  name     = "etl_user"
  login    = true
  password = "etl_pass"
}

resource "postgresql_role" "analista" {
  name     = "analista"
  login    = true
  password = "analista_pass"
}

resource "postgresql_grant" "etl_staging" {
  for_each    = postgresql_schema.capa
  database    = "dwh"
  role        = postgresql_role.etl.name
  schema      = each.value.name
  object_type = "schema"
  privileges  = ["USAGE", "CREATE"]
}

resource "postgresql_grant" "analista_uso" {
  database    = "dwh"
  role        = postgresql_role.analista.name
  schema      = postgresql_schema.capa["analytics"].name
  object_type = "schema"
  privileges  = ["USAGE"]
}

resource "postgresql_default_privileges" "analista_lectura" {
  database    = "dwh"
  role        = postgresql_role.analista.name
  owner       = postgresql_role.etl.name
  schema      = postgresql_schema.capa["analytics"].name
  object_type = "table"
  privileges  = ["SELECT"]
}
```

```bash
terraform init && terraform apply -auto-approve
```

**Paso 3 — Cargar de S3 al DWH.** `scripts/cargar_dwh.py`:

```python
import duckdb

con = duckdb.connect()
for ext in ("httpfs", "postgres"):
    con.execute(f"INSTALL {ext}; LOAD {ext};")

con.execute("""
    CREATE SECRET localstack (
        TYPE S3, KEY_ID 'test', SECRET 'test', REGION 'us-east-1',
        ENDPOINT 'localstack:4566', URL_STYLE 'path', USE_SSL false
    );
""")
con.execute("ATTACH 'host=dwh port=5432 dbname=dwh user=etl_user password=etl_pass' AS dwh (TYPE postgres);")

# 1) staging: copia fiel del lago
con.execute("""
    CREATE OR REPLACE TABLE dwh.staging.ventas AS
    SELECT order_id, customer_id, product, amount, order_date
    FROM read_parquet('s3://lake-curated/fact_ventas/*/*/*.parquet', hive_partitioning = true);
""")

# 2) analytics: modelo estrella
con.execute("""
    CREATE OR REPLACE TABLE dwh.analytics.dim_producto AS
    SELECT ROW_NUMBER() OVER (ORDER BY product) AS producto_id, product AS nombre
    FROM (SELECT DISTINCT product FROM dwh.staging.ventas);
""")
con.execute("""
    CREATE OR REPLACE TABLE dwh.analytics.dim_fecha AS
    SELECT DISTINCT order_date AS fecha,
           year(order_date) AS anio, month(order_date) AS mes, dayname(order_date) AS dia_semana
    FROM dwh.staging.ventas;
""")
con.execute("""
    CREATE OR REPLACE TABLE dwh.analytics.fact_ventas AS
    SELECT v.order_id, v.customer_id, p.producto_id, v.order_date AS fecha, v.amount
    FROM dwh.staging.ventas v
    JOIN dwh.analytics.dim_producto p ON p.nombre = v.product;
""")
print("Carga completada")
```

```bash
python scripts/cargar_dwh.py
```

**Paso 4 — Consultar como analista.**

```bash
docker exec -it dwh psql -U analista -d dwh -c "SELECT d.mes, p.nombre, SUM(f.amount) total FROM analytics.fact_ventas f JOIN analytics.dim_producto p USING (producto_id) JOIN analytics.dim_fecha d ON d.fecha = f.fecha GROUP BY 1,2 ORDER BY 3 DESC;"

# Debe FALLAR (el analista no tiene acceso a staging)
docker exec -it dwh psql -U analista -d dwh -c "SELECT * FROM staging.ventas;"
```

**Así sería en AWS real:**

```hcl
resource "aws_redshiftserverless_namespace" "dwh" {
  namespace_name      = "dwh"
  db_name             = "dwh"
  admin_username      = "dwh_admin"
  manage_admin_password = true
}

resource "aws_redshiftserverless_workgroup" "dwh" {
  namespace_name = aws_redshiftserverless_namespace.dwh.namespace_name
  workgroup_name = "dwh"
  base_capacity  = 8
}
```

### 🎯 Reto
Crea `dim_cliente` y una vista `analytics.v_ventas_por_cliente`. Comprueba que el analista puede leerla.

### 🧹 Limpieza
`terraform destroy -auto-approve` y `docker compose --profile dwh down`

---

## Módulo 15 — Terraform avanzado: módulos, estado remoto y entornos

### Objetivos
Organizar el código como en un equipo real: módulos reutilizables, estado remoto en S3 con bloqueo y entornos separados (dev/prod).

### 15.1 Subtemas
- **Módulos**: carpetas con `variables.tf`, `main.tf`, `outputs.tf` reutilizables.
- **Estado remoto** (backend S3) y **bloqueo** (`use_lockfile`) para trabajo en equipo.
- **Entornos**: carpeta por entorno (recomendado) vs. workspaces.
- **Buenas prácticas**: versionar providers, `terraform fmt`/`validate` en CI, no subir `*.tfstate` ni `*.tfvars` con secretos a git.
- **Importar** recursos existentes (`import` block) y **mover** recursos (`moved` block).

### 15.2 Ejercicio

Estructura:

```
modulos/15-terraform-avanzado/
├── bootstrap/                 # crea el bucket del state (estado local)
│   ├── providers.tf
│   └── main.tf
├── modules/
│   ├── data_lake/
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   └── outputs.tf
│   └── lambda_python/
│       ├── main.tf
│       ├── variables.tf
│       └── outputs.tf
└── envs/
    ├── dev/
    │   ├── backend.tf
    │   ├── providers.tf
    │   ├── main.tf
    │   └── terraform.tfvars
    └── prod/
        └── (igual que dev con otros valores)
```

**Paso 1 — Bootstrap del state.** `bootstrap/main.tf`:

```hcl
resource "aws_s3_bucket" "tfstate" {
  bucket = "curso-terraform-state"
}

resource "aws_s3_bucket_versioning" "tfstate" {
  bucket = aws_s3_bucket.tfstate.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "tfstate" {
  bucket = aws_s3_bucket.tfstate.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}
```

```bash
cd bootstrap && terraform init && terraform apply -auto-approve && cd ..
```

**Paso 2 — Módulo `data_lake`.**

`modules/data_lake/variables.tf`:

```hcl
variable "prefijo" {
  type = string
}

variable "zonas" {
  type    = list(string)
  default = ["raw", "processed", "curated"]
}

variable "force_destroy" {
  type    = bool
  default = false
}
```

`modules/data_lake/main.tf`:

```hcl
resource "aws_s3_bucket" "zona" {
  for_each      = toset(var.zonas)
  bucket        = "${var.prefijo}-${each.key}"
  force_destroy = var.force_destroy
}

resource "aws_s3_bucket_versioning" "zona" {
  for_each = aws_s3_bucket.zona
  bucket   = each.value.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_public_access_block" "zona" {
  for_each                = aws_s3_bucket.zona
  bucket                  = each.value.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}
```

`modules/data_lake/outputs.tf`:

```hcl
output "buckets" {
  value = { for k, b in aws_s3_bucket.zona : k => b.bucket }
}

output "arns" {
  value = { for k, b in aws_s3_bucket.zona : k => b.arn }
}
```

**Paso 3 — Módulo `lambda_python`** (encapsula rol + zip + función, lo que repetimos en los módulos 5 a 10):

`modules/lambda_python/variables.tf`:

```hcl
variable "nombre"       { type = string }
variable "archivo_src"  { type = string }
variable "handler"      { type = string }
variable "politica_json" { type = string }
variable "variables_entorno" {
  type    = map(string)
  default = {}
}
```

`modules/lambda_python/main.tf`:

```hcl
data "aws_iam_policy_document" "assume" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "this" {
  name               = "rol-${var.nombre}"
  assume_role_policy = data.aws_iam_policy_document.assume.json
}

resource "aws_iam_role_policy" "this" {
  role   = aws_iam_role.this.id
  policy = var.politica_json
}

resource "aws_cloudwatch_log_group" "this" {
  name              = "/aws/lambda/${var.nombre}"
  retention_in_days = 14
}

data "archive_file" "this" {
  type        = "zip"
  source_file = var.archivo_src
  output_path = "${path.root}/build/${var.nombre}.zip"
}

resource "aws_lambda_function" "this" {
  function_name    = var.nombre
  role             = aws_iam_role.this.arn
  handler          = var.handler
  runtime          = "python3.12"
  filename         = data.archive_file.this.output_path
  source_code_hash = data.archive_file.this.output_base64sha256
  timeout          = 60

  environment {
    variables = var.variables_entorno
  }

  depends_on = [aws_cloudwatch_log_group.this]
}
```

`modules/lambda_python/outputs.tf`:

```hcl
output "arn"           { value = aws_lambda_function.this.arn }
output "function_name" { value = aws_lambda_function.this.function_name }
output "role_name"     { value = aws_iam_role.this.name }
```

**Paso 4 — Entorno dev.**

`envs/dev/backend.tf`:

```hcl
terraform {
  backend "s3" {
    bucket                      = "curso-terraform-state"
    key                         = "dev/terraform.tfstate"
    region                      = "us-east-1"
    use_lockfile                = true
    access_key                  = "test"
    secret_key                  = "test"
    endpoints                   = { s3 = "http://localstack:4566" }
    use_path_style              = true
    skip_credentials_validation = true
    skip_requesting_account_id  = true
    skip_metadata_api_check     = true
    skip_region_validation      = true
  }
}
```

`envs/dev/main.tf`:

```hcl
variable "entorno" { type = string }

module "lake" {
  source        = "../../modules/data_lake"
  prefijo       = "empresa-${var.entorno}"
  force_destroy = var.entorno != "prod"
}

data "aws_iam_policy_document" "validador" {
  statement {
    actions   = ["s3:GetObject"]
    resources = ["${module.lake.arns["raw"]}/*"]
  }
  statement {
    actions   = ["s3:PutObject"]
    resources = ["${module.lake.arns["processed"]}/*"]
  }
}

module "validador" {
  source            = "../../modules/lambda_python"
  nombre            = "validador-${var.entorno}"
  archivo_src       = "${path.root}/../../../05-lambda-ingesta/src/handler.py"
  handler           = "handler.handler"
  politica_json     = data.aws_iam_policy_document.validador.json
  variables_entorno = { DEST_BUCKET = module.lake.buckets["processed"] }
}

output "buckets" { value = module.lake.buckets }
```

`envs/dev/terraform.tfvars`:

```hcl
entorno = "dev"
```

Copia `envs/dev` a `envs/prod`, cambia `key = "prod/terraform.tfstate"` en el backend y `entorno = "prod"` en el tfvars.

```bash
cd envs/dev  && terraform init && terraform apply -auto-approve && cd ../..
cd envs/prod && terraform init && terraform apply -auto-approve && cd ../..

aws s3 ls s3://curso-terraform-state --recursive   # dos states separados
aws s3 ls                                         # buckets empresa-dev-* y empresa-prod-*
```

**Paso 5 — Refactor sin destruir con `moved`.** Renombra en dev `module "lake"` a `module "datalake"` y añade:

```hcl
moved {
  from = module.lake
  to   = module.datalake
}
```

`terraform plan` debe mostrar `0 to add, 0 to destroy`.

### 🎯 Reto
1. Crea un bucket a mano con la CLI e intégralo en Terraform con un bloque `import { to = aws_s3_bucket.x  id = "nombre" }`.
2. Escribe un `Makefile` o script `deploy.ps1` que ejecute `fmt -check`, `validate` y `plan` para un entorno dado.

### 🧹 Limpieza
`terraform destroy` en prod, dev y bootstrap (en ese orden).

---

## Módulo 16 — Proyecto final: pipeline de datos de punta a punta

### Enunciado
Una tienda online necesita una plataforma de datos que:

1. Reciba **pedidos en streaming** desde la web (Kinesis).
2. Los aterrice crudos en el lago (Firehose → S3 raw).
3. Cada hora, un pipeline orquestado (EventBridge → Step Functions):
   - valide y limpie los pedidos (Lambda → S3 processed),
   - registre métricas de calidad en DynamoDB,
   - notifique por SNS si la tasa de rechazos supera el 5 %.
4. Una vez al día, transforme a Parquet particionado (Spark → S3 curated).
5. Permita consultas ad-hoc (DuckDB) y cargue el modelo estrella al DWH (Postgres).
6. Tenga secretos en Secrets Manager, alarmas en CloudWatch y estado remoto en S3.

### Arquitectura

```
 Web ─► Kinesis "pedidos" ─► Firehose ─► S3 raw/pedidos/
                                              │
 EventBridge (rate 1 hour) ─► Step Functions ─┤
                                 1. Lambda validar ─► S3 processed/   (+ rechazados/)
                                 2. DynamoDB putItem (métricas)
                                 3. Choice: % rechazos > 5 ─► SNS "alertas"
                                              │
 Spark (diario) ─────────────────────────────► S3 curated/ (Parquet, anio/mes/dia)
                                              │
                     DuckDB (consultas) ◄─────┴─────► Postgres DWH (estrella)

 Transversal: IAM mínimo privilegio · Secrets Manager · CloudWatch · estado remoto
```

### Estructura sugerida

```
modulos/16-proyecto-final/
├── modules/
│   ├── data_lake/         (del módulo 15)
│   ├── lambda_python/     (del módulo 15)
│   ├── streaming/         Kinesis + Firehose + rol
│   ├── orquestacion/      Step Functions + EventBridge + roles
│   └── observabilidad/    SNS + alarmas + log groups
├── src/
│   └── validar_pedidos.py
├── envs/dev/
└── README.md              decisiones de arquitectura
```

### Hitos y criterios de aceptación

| Hito | Entregable | Cómo se comprueba |
|---|---|---|
| 1 | Data lake con 3 zonas, versionado, cifrado y bloqueo público | `aws s3api get-bucket-*` |
| 2 | Kinesis + Firehose escribiendo en `raw/pedidos/` | Ejecutar productor; archivos en S3 tras 60 s |
| 3 | Lambda `validar_pedidos` que lee todo lo nuevo de raw y escribe en processed y rechazados | Archivos en processed; conteos en logs |
| 4 | Step Functions con validar → métricas → choice → SNS | `start-execution` y revisar historial |
| 5 | EventBridge programando el pipeline | `list-executions` muestra ejecuciones automáticas |
| 6 | Job Spark que genera `curated/fact_pedidos/anio=/mes=/dia=` | `aws s3 ls` + consulta DuckDB |
| 7 | Carga al DWH con modelo estrella y rol analista de solo lectura | Consulta con `psql -U analista` |
| 8 | Alarmas de errores y de rechazos, notificación a SNS | `set-alarm-state` + mensaje en cola buzón |
| 9 | Todo en módulos, estado remoto, `dev` y `prod` desplegables | `terraform plan` limpio en ambos entornos |
| 10 | README con diagrama, decisiones y costos estimados en AWS real | Revisión |

### Pistas
- Para que la Lambda procese solo archivos nuevos, guarda en DynamoDB la última clave procesada (*watermark*) o mueve los archivos procesados a un prefijo `archivados/`.
- La Lambda debe devolver `{"total": n, "rechazadas": m, "pct_rechazo": x}` para que el `Choice` de Step Functions decida.
- Usa `"Resource": "arn:aws:states:::sns:publish"` en Step Functions para notificar sin escribir otra Lambda.
- Genera datos con errores (montos negativos, campos vacíos) en el productor para probar las alertas.

### Extensiones opcionales
- Esquemas versionados con **JSON Schema** validados en la Lambda.
- Formato de tabla **Apache Iceberg** en curated (Spark + catálogo Hadoop sobre S3).
- CI con GitHub Actions: `terraform fmt -check`, `validate`, `tflint` y `checkov` (análisis de seguridad).
- Tests de la Lambda con `pytest` + `moto`.

---

## Apéndice A — Equivalencias AWS real vs. entorno local

| Servicio AWS | ¿En LocalStack gratuito? | Sustituto en este curso | Módulo |
|---|---|---|---|
| S3 | ✅ | — | 1, 3 |
| IAM / STS | ✅ (no aplica permisos) | — | 4 |
| Lambda | ✅ (usa Docker) | — | 5 |
| SQS / SNS | ✅ | — | 6 |
| Kinesis Data Streams / Firehose | ✅ | — | 7 |
| DynamoDB + Streams | ✅ | — | 8 |
| Step Functions / EventBridge | ✅ | — | 9 |
| Secrets Manager / SSM / KMS | ✅ | — | 10 |
| CloudWatch Logs / Metrics / Alarms | ✅ | — | 11 |
| Glue (Jobs, Catalog, Crawlers) | ❌ | Contenedor Apache Spark | 12 |
| Athena | ❌ | DuckDB + httpfs | 13 |
| Redshift | ❌ | PostgreSQL 16 | 14 |
| EMR | ❌ | Contenedor Apache Spark | 12 |
| MSK (Kafka) | ❌ | Kinesis (o contenedor Kafka) | 7 |
| Lake Formation | ❌ | IAM + roles de Postgres | 4, 14 |

## Apéndice B — Solución de problemas

| Síntoma | Causa probable | Solución |
|---|---|---|
| `Could not connect to the endpoint URL` | LocalStack apagado | `docker compose up -d localstack` |
| Terraform intenta conectar a `amazonaws.com` | Falta un servicio en `endpoints` | Añádelo al bloque `endpoints` del provider |
| Después de reiniciar Docker, Terraform cree que los recursos existen | LocalStack gratuito no persiste | Borra `terraform.tfstate*` y vuelve a `apply`, o usa `terraform apply -refresh-only` |
| La Lambda no se ejecuta o queda en `Pending` | LocalStack no accede al socket de Docker | Revisa el volumen `/var/run/docker.sock`; la primera vez descarga la imagen, espera |
| `BucketAlreadyExists` / errores de DNS con S3 | Estilo de URL virtual | `s3_use_path_style = true` en el provider |
| Spark: `ClassNotFoundException S3AFileSystem` | Falta `--packages hadoop-aws` | Usa exactamente la línea `spark-submit` del módulo 12 |
| Un contenedor no llega a LocalStack | Usar `localhost` dentro de Docker | Usa `http://localstack:4566` |
| JSON inválido en comandos | Comillas mal puestas | Pon el JSON entre comillas simples o usa archivos `file://` |
| `destroy` falla con `BucketNotEmpty` | Objetos o versiones | `force_destroy = true` en práctica |
| Te pide `LOCALSTACK_AUTH_TOKEN` | Cambio de licencia de la imagen | Crea cuenta gratuita y define el token en el compose |

Ver los logs internos del emulador: `docker logs localstack --tail 100`.

## Apéndice C — Glosario

- **CDC (Change Data Capture)**: capturar inserciones, cambios y borrados de una base de datos como eventos.
- **DLQ (Dead Letter Queue)**: cola donde terminan los mensajes que fallaron varias veces.
- **Drift**: diferencia entre lo que dice el código/state de Terraform y lo que existe realmente.
- **Fan-out**: un mensaje distribuido a varios consumidores.
- **Idempotencia**: procesar lo mismo dos veces produce el mismo resultado.
- **Medallion**: arquitectura de zonas bronce/plata/oro (raw/processed/curated).
- **Particionado Hive**: organizar archivos en carpetas `columna=valor`.
- **Parquet**: formato de archivo columnar y comprimido para analítica.
- **Shard**: unidad de capacidad de un stream de Kinesis.
- **State (Terraform)**: archivo donde Terraform guarda qué recursos administra.
- **Watermark**: marca de hasta dónde se procesaron los datos.

---

**Ruta recomendada:** un módulo por sesión (1–2 horas). Los módulos 0–5 forman la base; 6–11 cubren servicios de integración y operación; 12–14 cubren analítica; 15–16 te preparan para trabajar en equipo y en AWS real.
