# Tema 2 — Terraform esencial

> **Objetivo:** dominar las piezas de Terraform que usarás en todo el curso: variables, locals, outputs, `for_each` y el estado. Al final crearás los tres buckets de un data lake con un solo bloque de código.
>
> **Tiempo estimado:** 60–90 minutos.
>
> **Carpeta del ejercicio:** `alumnos/<tu-nombre>/modulos/02-terraform-esencial/` (reemplaza `<tu-nombre>` por tu carpeta, ej. `carlos`)
>
> **Antes de empezar:** el entorno del Tema 0 debe estar levantado (`docker compose up -d localstack herramientas`).

---

## 2.1 Providers, resources y data sources

Ya los usaste. Resumen:

| Bloque | Qué hace | Ejemplo |
|---|---|---|
| `provider` | Configura el plugin que habla con un servicio | `provider "aws" { ... }` en `providers.tf` |
| `resource` | **Crea** y administra algo | `resource "aws_s3_bucket" "first" { ... }` |
| `data` | **Lee** algo que ya existe, sin crearlo | `data "aws_caller_identity" "current" {}` |

Todos siguen la forma `palabra_fija "tipo" "nombre_tuyo"`, y se referencian como `tipo.nombre.campo` (los `data` llevan `data.` delante).

---

## 2.2 Variables, locals y outputs

Son las tres formas de manejar valores:

| Bloque | Qué es | Se parece a... |
|---|---|---|
| `variable` | Un valor que **llega de afuera** y puede cambiar en cada ejecución | El parámetro de una función |
| `locals` | Un valor **calculado dentro** del código, para no repetirlo | Una variable interna |
| `output` | Un valor que **sale** al terminar | El `return` de una función |

**Variable:**

```hcl
variable "environment" {
  description = "dev, qa or prod"
  type        = string
  default     = "dev"
}
```

- `type`: qué tipo de dato acepta (`string`, `number`, `bool`, `list(string)`, `map(string)`...).
- `default`: valor si nadie lo pasa. Sin `default`, Terraform te lo pregunta.
- Se usa con `var.environment`.

**Formas de darle valor**, de menor a mayor prioridad:
1. El `default`.
2. El archivo `terraform.tfvars` (se lee solo).
3. En el comando: `terraform plan -var="environment=prod"`.

**Local:**

```hcl
locals {
  prefix = "${var.project}-${var.environment}"   # ej: "sales-dev"
}
```

- `"${...}"` mete un valor dentro de un texto.
- Se usa con `local.prefix` (sin "s").

---

## 2.3 `count` y `for_each`: crear varias cosas con un solo bloque

Sin ellos, para tres buckets escribirías tres bloques casi iguales. Con `for_each`:

```hcl
resource "aws_s3_bucket" "zone" {
  for_each = toset(["raw", "processed", "curated"])
  bucket   = "sales-dev-${each.key}"
}
```

- `for_each` recorre la lista y crea **un bucket por cada elemento**.
- `each.key` es el elemento actual: `"raw"`, luego `"processed"`, luego `"curated"`.
- `toset(...)` convierte la lista en un conjunto (`for_each` lo exige así).
- En el estado quedan como `aws_s3_bucket.zone["raw"]`, `aws_s3_bucket.zone["processed"]`, etc.

**¿Y `count`?** Crea N copias numeradas (`[0]`, `[1]`, `[2]`):

```hcl
resource "aws_s3_bucket" "copy" {
  count  = 3
  bucket = "copy-${count.index}"
}
```

**Prefiere `for_each`.** Con `count`, si borras el elemento del medio de la lista, los números se corren y Terraform **destruye y recrea** los que vienen después. Con `for_each` cada uno tiene su nombre y no pasa. `count` se usa sobre todo para "crear o no crear" algo: `count = var.enabled ? 1 : 0`.

---

## 2.4 El estado (`terraform.tfstate`)

Es la **memoria** de Terraform: un archivo JSON donde anota qué creó y con qué valores.

En cada `plan`, Terraform compara tres cosas:

```
 Tu código (.tf)  ──┐
                    ├──►  diferencias  ──►  plan (+ crear, ~ cambiar, - destruir)
 El estado ─────────┤
                    │
 La realidad (AWS) ─┘   (la consulta para ver si alguien cambió algo "por fuera")
```

**Reglas de oro:**
- **Nunca lo edites a mano ni lo borres.** Si lo borras, Terraform "olvida" lo que creó e intentará crearlo de nuevo.
- **No lo subas a git.** Puede contener contraseñas. Por eso está en `.gitignore`.
- En equipos se guarda **en S3 con bloqueo**, para que dos personas no apliquen a la vez. Lo vemos en el Tema 15.

Comandos para mirarlo sin tocarlo:

```bash
terraform state list                              # qué recursos administra
terraform state show 'aws_s3_bucket.zone["raw"]'  # detalle de uno
```

---

## 2.5 Ciclo de comandos

| Comando | Qué hace | ¿Cambia algo en AWS? |
|---|---|---|
| `terraform init` | Descarga providers. Primero siempre, y otra vez si cambias providers | No |
| `terraform fmt` | Ordena el formato de los `.tf` | No |
| `terraform validate` | Revisa errores de sintaxis | No |
| `terraform plan` | Muestra qué haría | No |
| `terraform apply` | Ejecuta el plan (pide `yes`) | **Sí** |
| `terraform destroy` | Borra todo lo de esta carpeta (pide `yes`) | **Sí** |
| `terraform output` | Muestra los outputs guardados | No |

Símbolos del plan: `+` crear · `~` modificar · `-` destruir · `-/+` destruir y volver a crear.

> **Ojo con `-/+`:** significa que Terraform va a **borrar y recrear** el recurso. En un bucket con datos o una base de datos, eso es perder información. Si lo ves y no lo esperabas, no apliques.

---

## 2.6 Ejercicio: buckets parametrizados y detección de cambios

Vamos a crear los tres buckets del data lake (raw, processed, curated) con variables.

### Paso 1 — Crear la carpeta

Dentro del contenedor:

```bash
mkdir -p /curso/alumnos/<tu-nombre>/modulos/02-terraform-esencial
cd /curso/alumnos/<tu-nombre>/modulos/02-terraform-esencial
cp /curso/modulos/00-entorno/providers.tf .
```

### Paso 2 — Los archivos

Esta vez separamos el código en varios archivos. Terraform lee **todos los `.tf` de la carpeta** como si fueran uno solo; separarlos es solo para ordenarse.

`variables.tf`:

```hcl
variable "project" {
  description = "Short project name"
  type        = string
  default     = "sales"
}

variable "environment" {
  description = "dev, qa or prod"
  type        = string
  default     = "dev"

  validation {
    condition     = contains(["dev", "qa", "prod"], var.environment)
    error_message = "environment must be dev, qa or prod."
  }
}

variable "zones" {
  description = "Data lake zones"
  type        = list(string)
  default     = ["raw", "processed", "curated"]
}
```

El bloque `validation` rechaza valores no permitidos **antes** de tocar nada.

`main.tf`:

```hcl
locals {
  prefix = "${var.project}-${var.environment}"
}

resource "aws_s3_bucket" "zone" {
  for_each = toset(var.zones)
  bucket   = "${local.prefix}-${each.key}"

  tags = {
    Zone = each.key
  }
}
```

`outputs.tf`:

```hcl
output "buckets" {
  description = "Bucket name per zone"
  value       = { for zone, b in aws_s3_bucket.zone : zone => b.bucket }
}
```

El `for` arma un mapa `zona → nombre del bucket`. Se lee: "por cada `zone` y su bucket `b`, pon `zone` apuntando a `b.bucket`".

`terraform.tfvars`:

```hcl
project     = "sales"
environment = "dev"
```

### Paso 3 — Aplicar

```bash
terraform init
terraform fmt
terraform validate
terraform plan        # debe decir: 3 to add
terraform apply       # escribe "yes"
```

Comprueba:

```bash
terraform output buckets
terraform state list
aws s3 ls
```

Resultado esperado de `terraform output buckets`:

```
{
  "curated" = "sales-dev-curated"
  "processed" = "sales-dev-processed"
  "raw" = "sales-dev-raw"
}
```

### Paso 4 — Probar la validación

```bash
terraform plan -var="environment=staging"
```

Debe fallar con tu mensaje `environment must be dev, qa or prod.` y **sin crear nada**.

### Paso 5 — Agregar una zona

En `terraform.tfvars` agrega:

```hcl
zones = ["raw", "processed", "curated", "sandbox"]
```

```bash
terraform plan    # debe decir: 1 to add (solo sandbox)
terraform apply
```

Los otros tres no se tocan, porque `for_each` identifica cada bucket por su nombre.

### Paso 6 — Detectar cambios hechos "por fuera" (*drift*)

Borra un bucket **sin Terraform**, como si alguien lo hiciera a mano desde la consola:

```bash
aws s3 rb s3://sales-dev-sandbox
terraform plan
```

Terraform nota que el bucket ya no existe y propone **volver a crearlo** (`1 to add`). A esto se le llama *drift*: la realidad se desvió del código. Aplica para corregirlo:

```bash
terraform apply
```

> En AWS real, los cambios manuales en la consola son la causa número uno de sorpresas en Terraform. Regla del equipo: **todo cambio pasa por el código**.

---

## 🎯 Reto

Cambia `zones` de lista a **mapa**, para que cada zona tenga sus días de retención, y guárdalos como etiqueta del bucket:

```hcl
zones = {
  raw       = { retention_days = 30 }
  processed = { retention_days = 90 }
  curated   = { retention_days = 365 }
}
```

Pistas:
- El tipo de la variable será `map(object({ retention_days = number }))`.
- Con un mapa no necesitas `toset`: `for_each = var.zones`.
- `each.key` es el nombre de la zona y `each.value.retention_days` el número.

Después de cambiarlo, ejecuta `terraform plan`. ¿Recrea los buckets o solo cambia las etiquetas (`~`)?

<details>
<summary>Ver solución</summary>

`variables.tf`:

```hcl
variable "zones" {
  description = "Data lake zones and their retention in days"
  type = map(object({
    retention_days = number
  }))
  default = {
    raw       = { retention_days = 30 }
    processed = { retention_days = 90 }
    curated   = { retention_days = 365 }
  }
}
```

`main.tf`:

```hcl
resource "aws_s3_bucket" "zone" {
  for_each = var.zones
  bucket   = "${local.prefix}-${each.key}"

  tags = {
    Zone          = each.key
    RetentionDays = tostring(each.value.retention_days)
  }
}
```

Borra la línea `zones = [...]` de `terraform.tfvars`, o cámbiala al formato de mapa.

El plan muestra `~ update in-place` en las etiquetas: los buckets **no** se recrean, porque las claves (`raw`, `processed`, `curated`) son las mismas. Si tenías `sandbox`, ese sí se destruye, porque ya no está en el mapa.

> En el Tema 3 usaremos esos días de verdad, con reglas de ciclo de vida que borran archivos viejos.

</details>

---

## 🧹 Limpieza

```bash
terraform destroy     # revisa que diga "N to destroy" y escribe "yes"
```

Los buckets están vacíos, así que no hace falta vaciarlos antes.

---

## ✅ Checklist

- [ ] Sé la diferencia entre `variable`, `locals` y `output`.
- [ ] Sé tres formas de darle valor a una variable.
- [ ] Puedo explicar por qué se prefiere `for_each` a `count`.
- [ ] Sé qué guarda `terraform.tfstate` y por qué no se edita ni se sube a git.
- [ ] Creé los buckets con `for_each` y vi el output como mapa.
- [ ] Vi fallar la validación con `environment=staging`.
- [ ] Agregué una zona y el plan dijo `1 to add`.
- [ ] Provoqué un *drift* y Terraform lo detectó.
- [ ] Hice el reto del mapa.
- [ ] Limpié con `terraform destroy`.

---

**Anterior:** [Tema 1 — Fundamentos](tema-01-fundamentos.md) · **Siguiente:** [Tema 3 — Data lake en S3](tema-03-data-lake-s3.md)
