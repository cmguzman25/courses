# Tema 0 — Preparación del entorno

> **Objetivo:** al terminar este tema tendrás un "AWS" funcionando en tu laptop y una caja de herramientas (Terraform, AWS CLI y Python) lista para usar. Todo dentro de Docker.
>
> **Tiempo estimado:** 30–45 minutos (la primera vez descarga imágenes).
>
> **Archivos del tema:** `docker-compose.yml`, `docker/herramientas/Dockerfile`, `.gitignore`, `modulos/00-entorno/`

---

## 0.1 Por qué todo dentro de Docker

En tu laptop **solo necesitas Docker Desktop** y un editor (por ejemplo VS Code). Nada más.

Terraform, la AWS CLI y Python no se instalan en Windows: viven dentro de un contenedor llamado `herramientas`. Tú entras a ese contenedor y trabajas desde ahí.

**Ventajas:**
- **Portable:** en otra laptop instalas Docker, copias la carpeta y listo.
- **Mismas versiones para todos:** nadie tiene "en mi máquina sí funciona".
- **Windows limpio:** no instalas nada más.

**Cómo se conectan las piezas:**

```
 Tu laptop ─── solo Docker Desktop
 │
 ├── contenedor "herramientas"   ← aquí entras y escribes los comandos
 │      Terraform · AWS CLI · Python (boto3, DuckDB) · psql
 │      ve la carpeta del curso en /curso
 │                   │
 │                   │  http://localstack:4566
 │                   ▼
 ├── contenedor "localstack"     ← el AWS simulado
 │
 ├── contenedor "spark"          ← se usa desde el Tema 12
 └── contenedor "dwh" (Postgres) ← se usa desde el Tema 14

 Todos viven en la misma red de Docker: "curso-datos"
```

**Idea clave:** dentro de Docker, los contenedores se llaman por su nombre. Por eso LocalStack es `localstack`, no `localhost`. Verás `http://localstack:4566` en todo el curso.

---

## 0.2 Qué es LocalStack y sus limitaciones

LocalStack es un programa que **imita las APIs de AWS**. Terraform y la AWS CLI le hablan igual que a AWS y no notan la diferencia.

Ejemplo: cuando ejecutas `aws s3 mb s3://mi-bucket`, la CLI no va a Amazon. Va a LocalStack, que crea el bucket en tu laptop.

**Lo que tienes que saber:**

| Limitación | Qué significa para ti |
|---|---|
| La versión gratuita no trae Glue, Athena, Redshift ni EMR | Los reemplazamos con Spark, DuckDB y PostgreSQL en Docker (temas 12–14) |
| No aplica los permisos de IAM | Todo está permitido. Igual escribimos bien los permisos, porque en AWS real sí importan |
| Al apagar el contenedor se borra todo | No pasa nada: vuelves a ejecutar `terraform apply` y se recrea |

> **Licencia:** si algún día la imagen te pide `LOCALSTACK_AUTH_TOKEN`, crea una cuenta gratuita en localstack.cloud, copia tu token y descomenta esa línea en el `docker-compose.yml`.

---

## 0.3 Los archivos del entorno

Ya están creados en la raíz del curso. Aquí se explica qué hace cada uno.

### `docker/herramientas/Dockerfile`

Es la "receta" de la caja de herramientas:

```dockerfile
# Course toolbox: Terraform + AWS CLI v2 + Python + Postgres client.
# Works on Intel/AMD PCs (x86_64) and Apple Silicon Macs (arm64).
FROM python:3.12-slim

RUN apt-get update \
 && apt-get install -y --no-install-recommends curl unzip gnupg lsb-release less jq postgresql-client \
 && rm -rf /var/lib/apt/lists/*

# Terraform from the official HashiCorp repository
RUN curl -fsSL https://apt.releases.hashicorp.com/gpg | gpg --dearmor -o /usr/share/keyrings/hashicorp.gpg \
 && echo "deb [signed-by=/usr/share/keyrings/hashicorp.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" \
    > /etc/apt/sources.list.d/hashicorp.list \
 && apt-get update && apt-get install -y --no-install-recommends terraform \
 && rm -rf /var/lib/apt/lists/*

# AWS CLI v2 (picks the installer for the CPU architecture)
RUN curl -fsSL "https://awscli.amazonaws.com/awscli-exe-linux-$(uname -m).zip" -o /tmp/awscli.zip \
 && unzip -q /tmp/awscli.zip -d /tmp \
 && /tmp/aws/install \
 && rm -rf /tmp/aws /tmp/awscli.zip

# Python libraries used by the course scripts
RUN pip install --no-cache-dir boto3 duckdb

WORKDIR /curso
CMD ["sleep", "infinity"]
```

| Línea | Para qué |
|---|---|
| `FROM python:3.12-slim` | Parte de un Linux pequeño que ya trae Python |
| `apt-get install ... jq postgresql-client` | Utilidades: `curl` (descargar), `jq` (leer JSON bonito), `psql` (Postgres) |
| Bloque de Terraform | Instala Terraform desde el repositorio oficial |
| Bloque de AWS CLI | Descarga la CLI correcta según tu procesador (`uname -m`) |
| `pip install boto3 duckdb` | `boto3` = AWS desde Python; `duckdb` = SQL sobre archivos (Tema 13) |
| `CMD ["sleep", "infinity"]` | Mantiene el contenedor encendido para que puedas entrar |

### `docker-compose.yml`

Define todos los contenedores. Lo importante de los dos que usamos ahora:

```yaml
services:
  localstack:
    image: localstack/localstack:4
    container_name: localstack
    ports:
      - "127.0.0.1:4567:4566"   # 4567 on Windows, to avoid clashing with another LocalStack
    environment:
      - SERVICES=s3,iam,sts,lambda,sqs,sns,kinesis,firehose,dynamodb,dynamodbstreams,stepfunctions,events,scheduler,logs,cloudwatch,secretsmanager,ssm,kms
    volumes:
      - "./.localstack:/var/lib/localstack"
      - "/var/run/docker.sock:/var/run/docker.sock"   # LocalStack uses it to run Lambdas

  herramientas:
    build: ./docker/herramientas
    container_name: herramientas
    working_dir: /curso
    volumes:
      - "./:/curso"
      - "terraform-plugins:/root/.terraform.d/plugin-cache"
    environment:
      - AWS_ACCESS_KEY_ID=test
      - AWS_SECRET_ACCESS_KEY=test
      - AWS_DEFAULT_REGION=us-east-1
      - AWS_ENDPOINT_URL=http://localstack:4566
      - TF_PLUGIN_CACHE_DIR=/root/.terraform.d/plugin-cache

networks:
  default:
    name: curso-datos
    ipam:
      config:
        - subnet: 10.150.0.0/24
```

**Las líneas que más importan:**

- **`SERVICES=...`**: qué servicios de AWS enciende LocalStack. Solo los que usaremos, así arranca más rápido.
- **`/var/run/docker.sock`**: LocalStack ejecuta cada Lambda en un contenedor aparte, y para eso necesita usar tu Docker.
- **`./:/curso`**: la carpeta del curso en Windows aparece dentro del contenedor en `/curso`. Lo que editas en VS Code se ve al instante dentro.
- **`AWS_ACCESS_KEY_ID=test` y `AWS_SECRET_ACCESS_KEY=test`**: credenciales falsas. LocalStack acepta cualquiera.
- **`AWS_ENDPOINT_URL=http://localstack:4566`**: hace que la AWS CLI y Python vayan a LocalStack y no a Amazon. Sin esto tendrías que escribir `--endpoint-url` en cada comando.
- **`TF_PLUGIN_CACHE_DIR`**: guarda los providers de Terraform y no los descarga de nuevo en cada tema.
- **`127.0.0.1:4567:4566`**: desde Windows, LocalStack se ve en el puerto 4567 (más abajo se explica por qué no 4566).
- **`networks`**: una red propia con un rango de direcciones fijo (más abajo se explica por qué).

### `.gitignore`

Evita subir a git archivos que no deben compartirse:

```
.localstack/        # datos internos de LocalStack
**/.terraform/      # providers descargados (pesan mucho)
*.tfstate           # estado de Terraform (puede tener contraseñas)
*.tfstate.*
**/build/           # zips de las Lambdas
```

---

## 0.4 Ejercicio: levantar el entorno

Abre **PowerShell** en la carpeta del curso:

```powershell
cd C:\proyectos-personales\cursos\curso-arquitectura-datos-aws-basico
docker compose up -d --build localstack herramientas
```

- `up -d`: arranca los contenedores en segundo plano.
- `--build`: construye la imagen de herramientas (solo tarda la primera vez).

Comprueba que están corriendo:

```powershell
docker compose ps
```

Resultado esperado:

```
NAME           STATUS                    PORTS
herramientas   Up 26 seconds
localstack     Up 26 seconds (healthy)   127.0.0.1:4567->4566/tcp
```

Mira el log de LocalStack hasta ver la palabra `Ready.`:

```powershell
docker logs localstack --tail 5
```

> Si ves un aviso `Unable to download local test SSL certificate`, **ignóralo**. Es la red de la empresa bloqueando una descarga opcional y no afecta al curso.

---

## 0.5 Ejercicio: entrar al contenedor y comprobar que habla con LocalStack

Entra a la caja de herramientas:

```powershell
docker compose exec herramientas bash
```

El prompt cambia a algo como `root@a1b2c3:/curso#`. **Ya estás dentro de Linux.** Desde aquí, todos los comandos del curso se escriben en esta terminal, salvo que se diga lo contrario.

**1. Las herramientas están instaladas:**

```bash
terraform -version
aws --version
python --version
```

**2. LocalStack responde y qué servicios tiene:**

```bash
curl -s http://localstack:4566/_localstack/health | jq .services
```

Los servicios que pediste deben decir `"available"`. Los que no usamos dicen `"disabled"`.

**3. Primera llamada al AWS simulado:**

```bash
aws sts get-caller-identity
```

Resultado esperado:

```json
{
    "UserId": "AKIAIOSFODNN7EXAMPLE",
    "Account": "000000000000",
    "Arn": "arn:aws:iam::000000000000:root"
}
```

`000000000000` es la cuenta falsa de LocalStack. Si ves esto, la CLI está hablando con LocalStack y no con Amazon.

**4. Prueba rápida con S3:**

```bash
aws s3 mb s3://env-check
aws s3 ls
aws s3 rb s3://env-check
```

Creaste y borraste un bucket sin cuenta de AWS.

Para salir del contenedor escribe `exit`. Los contenedores siguen corriendo.

---

## 0.6 El archivo `providers.tf` base

Este archivo le dice a Terraform **a qué "AWS" conectarse**. Lo copiarás al inicio de cada tema.

Está en `modulos/00-entorno/providers.tf`:

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
      Project     = "data-architecture-course"
      Environment = "local"
    }
  }
}
```

**Qué hace cada parte:**

| Parte | Para qué |
|---|---|
| `required_providers` | Qué plugins descarga Terraform: `aws` (los recursos) y `archive` (crear zips para Lambdas) |
| `version = "~> 6.0"` | Acepta cualquier versión 6.x, pero no la 7. Así un cambio grande no te rompe el código |
| `access_key` / `secret_key = "test"` | Credenciales falsas para LocalStack |
| `skip_*` | Le dice a Terraform que no valide contra el AWS real |
| `s3_use_path_style = true` | Usa direcciones `localstack:4566/bucket` en vez de `bucket.localstack:4566`, que no funcionaría en local |
| `endpoints` | La clave de todo: cada servicio apunta a LocalStack |
| `default_tags` | Etiquetas que se ponen solas en todos los recursos |

> **En AWS real** solo cambias este archivo: quitas `access_key`, `secret_key`, los `skip_*` y el bloque `endpoints`. **El resto del código de los temas no cambia.** Esa es la gran ventaja de trabajar así.

### Ejercicio: probar Terraform contra LocalStack

En `modulos/00-entorno/main.tf` hay una prueba mínima (es la base común; la ejecutas en una copia dentro de tu carpeta):

```hcl
# Environment check: reads the identity of the simulated AWS account.
# A data source only reads; it does not create anything.
data "aws_caller_identity" "current" {}

output "account_id" {
  value = data.aws_caller_identity.current.account_id
}
```

Dentro del contenedor:

```bash
mkdir -p /curso/alumnos/<tu-nombre>/modulos/00-entorno
cd /curso/alumnos/<tu-nombre>/modulos/00-entorno
cp /curso/modulos/00-entorno/*.tf .
terraform init
terraform apply
```

- `terraform init` descarga los providers (solo la primera vez).
- `terraform apply` muestra lo que va a hacer y pregunta `Do you want to perform these actions?`. Escribe `yes` y presiona Enter. Aquí no crea recursos, solo guarda el output.

Resultado esperado:

```
Outputs:

account_id = "000000000000"
```

Terraform se conectó a LocalStack. Tu entorno está listo.

---

## ✅ Checklist del Tema 0

- [ ] `docker compose ps` muestra `localstack` (healthy) y `herramientas` (Up).
- [ ] Entraste al contenedor con `docker compose exec herramientas bash`.
- [ ] `aws sts get-caller-identity` devuelve la cuenta `000000000000`.
- [ ] Creaste y borraste un bucket de prueba.
- [ ] `terraform apply` en `alumnos/<tu-nombre>/modulos/00-entorno` muestra `account_id = "000000000000"`.

---

## Comandos del día a día

Se escriben en **PowerShell**, desde la carpeta del curso:

| Qué quieres hacer | Comando |
|---|---|
| Arrancar el entorno | `docker compose up -d localstack herramientas` |
| Entrar a trabajar | `docker compose exec herramientas bash` |
| Ver si está todo arriba | `docker compose ps` |
| Ver el log de LocalStack | `docker logs localstack --tail 20` |
| Apagar todo | `docker compose down` |
| Reconstruir tras cambiar el Dockerfile | `docker compose build herramientas` |

**Pasar el curso a otra laptop:** instala Docker Desktop, copia o clona la carpeta y ejecuta `docker compose up -d --build localstack herramientas`.

---

## Problemas que pueden aparecer

Los dos primeros aparecieron al preparar este tema en una laptop con otros proyectos de Docker.

**1. `all predefined address pools have been fully subnetted`**

- **Qué pasa:** Docker tiene muchas redes creadas (una por cada proyecto con `docker compose`) y se quedó sin rangos de direcciones para una nueva.
- **Solución aplicada:** el `docker-compose.yml` le da a la red del curso un rango fijo (`10.150.0.0/24`), así no depende de los rangos automáticos.
- **Alternativa:** `docker network prune` borra las redes que no están en uso. Ojo: afecta a tus otros proyectos (se recrean solas al levantarlos de nuevo, pero revisa antes qué vas a borrar).

**2. `Bind for 127.0.0.1:4566 failed: port is already allocated`**

- **Qué pasa:** otro LocalStack (de otro proyecto) ya está usando el puerto 4566 en Windows.
- **Solución aplicada:** el del curso usa el puerto **4567** en Windows. Dentro de Docker sigue siendo `localstack:4566`, así que el código no cambia.
- **Nota:** desde el contenedor `herramientas` **nunca** uses el puerto 4567. Ese puerto es solo para Windows (por ejemplo, para abrir `http://localhost:4567/_localstack/health` en el navegador).

**3. `Could not connect to the endpoint URL`**

- **Qué pasa:** LocalStack está apagado o todavía arrancando.
- **Solución:** `docker compose ps` y espera a que diga `healthy`.

**4. Terraform dice que un recurso existe, pero ya no está**

- **Qué pasa:** reiniciaste LocalStack, que borra todo, pero el `terraform.tfstate` todavía recuerda los recursos.
- **Solución:** borra `terraform.tfstate*` de ese tema y vuelve a ejecutar `terraform apply`.

---

**Siguiente:** [Tema 1 — Fundamentos de arquitectura de datos + primer recurso](tema-01-fundamentos.md)
