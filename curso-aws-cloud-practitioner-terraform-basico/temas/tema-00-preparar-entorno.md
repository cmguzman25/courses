# Tema 0 — Preparar el entorno

> **Objetivo:** al terminar tendrás una "caja de herramientas" con Terraform y la AWS CLI lista para usar, sin instalar nada en Windows salvo Docker Desktop.
>
> **Tiempo estimado:** 20–30 minutos (la primera vez descarga la imagen).
>
> **Carpeta del ejercicio:** `alumnos/<tu-nombre>/modulos/00-entorno/`
>
> **¿Cuesta dinero?** No. En este tema todavía no tocamos AWS.

---

## 0.1 Por qué todo dentro de Docker

En tu laptop **solo necesitas Docker Desktop** y un editor (por ejemplo VS Code).

Terraform y la AWS CLI no se instalan en Windows: viven dentro de un contenedor. Piensa en el contenedor como una **mochila de herramientas**: la abres, trabajas, la cierras. Si cambias de computadora, te llevas la misma mochila.

| Ventaja | Qué significa |
|---|---|
| Portable | En otra laptop instalas Docker, copias la carpeta y listo |
| Mismas versiones para todos | Nadie tiene el problema de "en mi máquina sí funciona" |
| Windows limpio | No instalas Terraform ni la CLI en tu sistema |

**Cómo se conectan las piezas:**

```
 Tu laptop ─── solo Docker Desktop
 │
 └── contenedor "herramientas"   ← aquí entras y escribes los comandos
        Terraform · AWS CLI
        ve la carpeta del curso en /curso
                 │
                 │  Internet (con tus credenciales, desde el Tema 1)
                 ▼
          AWS de verdad  ← tu cuenta
```

> **Diferencia con otros cursos:** aquí **no hay un AWS simulado**. Lo que crees con Terraform aparece en tu cuenta real y puede costar dinero. Por eso hay alarma de precios (Tema 3) y `terraform destroy` al final de cada tema.

---

## 0.2 El contenedor `herramientas`: Terraform y AWS CLI

| Herramienta | Para qué sirve | Analogía |
|---|---|---|
| **Terraform** | Crear y borrar infraestructura escribiendo código | El plano de una casa: lo escribes una vez y la casa se construye igual siempre |
| **AWS CLI** | Hablarle a AWS desde la terminal, comando por comando | El control remoto de AWS |
| **Consola de AWS** (navegador) | Ver y tocar AWS con botones | La vitrina: ahí ves lo que construiste |

En el curso usarás las tres: **Terraform para crear, la consola para mirar y la CLI para comprobar.**

---

## 0.3 El `Dockerfile` y el `docker-compose.yml`

Ya están creados en la raíz del curso. Aquí se explica qué hace cada uno.

### `docker/herramientas/Dockerfile`

Es la "receta" de la mochila:

```dockerfile
# Course toolbox: Terraform + AWS CLI v2 + small utilities.
# Works on Intel/AMD PCs (x86_64) and Apple Silicon Macs (arm64).
FROM python:3.12-slim

RUN apt-get update \
 && apt-get install -y --no-install-recommends curl unzip gnupg lsb-release less jq zip \
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

# Show the active AWS profile in the prompt, so you always know which account you are using
RUN echo 'PS1="[aws:\${AWS_PROFILE:-none}] \w# "' >> /root/.bashrc

WORKDIR /curso
CMD ["sleep", "infinity"]
```

| Línea | Para qué |
|---|---|
| `FROM python:3.12-slim` | Parte de un Linux pequeño (Python servirá para las Lambdas del Tema 10) |
| `apt-get install ... jq zip` | Utilidades: `curl` (descargar), `jq` (leer JSON bonito), `zip` |
| Bloque de Terraform | Instala Terraform desde el repositorio oficial de HashiCorp |
| Bloque de AWS CLI | Descarga la CLI correcta según tu procesador (`uname -m`) |
| `PS1=...` | El prompt muestra con qué perfil de AWS estás trabajando |
| `CMD ["sleep", "infinity"]` | Mantiene el contenedor encendido para que puedas entrar |

### `docker-compose.yml`

```yaml
services:
  herramientas:
    build: ./docker/herramientas
    container_name: cp-herramientas
    working_dir: /curso
    volumes:
      - "./:/curso"
      - "./.aws:/root/.aws"
      - "terraform-plugins:/root/.terraform.d/plugin-cache"
    environment:
      - AWS_DEFAULT_REGION=us-east-1
      - TF_PLUGIN_CACHE_DIR=/root/.terraform.d/plugin-cache

networks:
  default:
    name: curso-cloud-practitioner
    ipam:
      config:
        - subnet: 10.160.0.0/24
```

**Las líneas que más importan:**

- **`herramientas`**: el nombre del servicio. Es el que usas en los comandos (`docker compose exec herramientas ...`).
- **`container_name: cp-herramientas`**: el nombre real del contenedor. Lleva `cp-` (Cloud Practitioner) para no chocar con contenedores de otros cursos.
- **`./:/curso`**: la carpeta del curso en Windows aparece dentro del contenedor en `/curso`. Lo que editas en VS Code se ve al instante dentro.
- **`./.aws:/root/.aws`**: aquí se guardarán tus credenciales de AWS (Tema 1), en la carpeta `.aws/` del curso.
- **`AWS_DEFAULT_REGION=us-east-1`**: la región por defecto (Norte de Virginia). Es donde viven la facturación y los presupuestos.
- **`TF_PLUGIN_CACHE_DIR`**: guarda los providers de Terraform y no los vuelve a descargar en cada tema.
- **`networks`**: una red propia con un rango fijo. Evita errores cuando Docker ya tiene muchas redes de otros proyectos.

> ⚠️ **La carpeta `.aws/` tendrá tus llaves de acceso a AWS.** Quien las tenga puede gastar dinero en tu cuenta. El archivo `.gitignore` del curso ya la excluye: **nunca la subas a git, ni la copies a otro lado, ni la compartas.**

### `.gitignore`

Evita subir a git lo que no debe compartirse:

```
.aws/               # tus credenciales de AWS
**/.terraform/      # providers descargados (pesan mucho)
*.tfstate           # estado de Terraform (puede tener datos sensibles)
*.tfstate.*
*.tfvars            # valores tuyos, como tu email
```

---

## 0.4 Levantar el entorno y entrar al contenedor

Abre **PowerShell** en la carpeta del curso (dentro de donde clonaste el repositorio):

```powershell
cd <donde-clonaste>\courses\curso-aws-cloud-practitioner-terraform-basico
docker compose up -d --build herramientas
```

- `up -d`: arranca el contenedor en segundo plano.
- `--build`: construye la imagen (solo tarda la primera vez, unos minutos).

Comprueba que está corriendo:

```powershell
docker compose ps
```

Resultado esperado:

```
NAME              SERVICE        STATUS
cp-herramientas   herramientas   Up 10 seconds
```

Entra al contenedor:

```powershell
docker compose exec herramientas bash
```

El prompt cambia a:

```
[aws:none] /curso#
```

**Ya estás dentro de Linux.** `aws:none` significa que todavía no tienes credenciales de AWS: es lo esperado, las creas en el Tema 1.

---

## 0.5 Comprobar versiones

Dentro del contenedor:

```bash
terraform version
aws --version
```

Resultado esperado (los números pueden ser más nuevos):

```
Terraform v1.x.x
on linux_amd64

aws-cli/2.x.x Python/3.x.x Linux/... exe/x86_64...
```

Si ves las dos versiones, la mochila está lista.

---

## Ejercicio: tu carpeta de trabajo

Vas a comprobar que lo que creas dentro del contenedor aparece en Windows, y al revés.

**1. Crea tu carpeta del tema** (dentro del contenedor):

```bash
mkdir -p /curso/alumnos/<tu-nombre>/modulos/00-entorno
cd /curso/alumnos/<tu-nombre>/modulos/00-entorno
echo "Hello from the container" > hello.txt
ls
```

**2. Mírala desde Windows:** abre en VS Code o en el Explorador de archivos la carpeta `alumnos\<tu-nombre>\modulos\00-entorno`. Ahí está `hello.txt`.

**3. Al revés:** desde VS Code crea en esa carpeta un archivo `from-windows.txt` con cualquier texto. Vuelve al contenedor:

```bash
cat from-windows.txt
```

Ves el texto que escribiste en Windows. **Es la misma carpeta vista desde dos lados.**

---

## Reto

Dentro del contenedor, ¿qué pasa si ejecutas `aws s3 ls`? Intenta predecir el resultado antes de probarlo.

<details>
<summary>Solución</summary>

Sale un error parecido a:

```
aws: [ERROR]: An error occurred (NoCredentials): Unable to locate credentials. You can configure credentials by running "aws login".
```

(El final del mensaje puede variar según la versión de la CLI.)

La CLI está bien instalada, pero **no sabe quién eres**: no tiene credenciales. Es como tener el control remoto sin pilas. En el Tema 1 creas tu cuenta y tu usuario, y le pones las "pilas" con `aws configure`.

</details>

---

## Limpieza

En este tema no se creó nada en AWS, así que **no hay `terraform destroy`** que hacer.

- Borra los archivos de prueba: `rm hello.txt from-windows.txt`
- Sal del contenedor con `exit`.
- Si quieres apagarlo: `docker compose down` (en PowerShell). Tus archivos no se pierden; viven en la carpeta del curso.

> Desde el Tema 3, **cada** tema termina con `terraform destroy` y una revisión en la consola de AWS. Acostúmbrate desde ya a la idea: **lo que no destruyes, lo pagas.**

---

## ✅ Checklist del Tema 0

- [ ] `docker compose ps` muestra `cp-herramientas` en estado `Up`.
- [ ] Entraste con `docker compose exec herramientas bash` y ves `[aws:none]` en el prompt.
- [ ] `terraform version` y `aws --version` muestran sus versiones.
- [ ] Viste un archivo creado en el contenedor desde Windows, y al revés.
- [ ] Sabes que `.aws/` nunca se sube a git.

---

## Comandos del día a día

Se escriben en **PowerShell**, desde la carpeta del curso:

| Qué quieres hacer | Comando |
|---|---|
| Arrancar el entorno | `docker compose up -d herramientas` |
| Entrar a trabajar (desde el Tema 1) | `docker compose exec -e AWS_PROFILE=<tu-nombre> herramientas bash` |
| Ver si está arriba | `docker compose ps` |
| Apagar | `docker compose down` |
| Reconstruir tras cambiar el Dockerfile | `docker compose build herramientas` |

**Pasar el curso a otra laptop:** instala Docker Desktop, copia o clona la carpeta y ejecuta `docker compose up -d --build herramientas`. La carpeta `.aws/` **no** viaja con git: en la otra laptop vuelves a hacer `aws configure` (Tema 1).

---

## Problemas que pueden aparecer

**1. `all predefined address pools have been fully subnetted`**
- **Qué pasa:** Docker tiene muchas redes y se quedó sin rangos libres.
- **Solución aplicada:** el curso usa una red con rango fijo (`10.160.0.0/24`). Si aun así choca con otra red, cambia ese rango en el `docker-compose.yml` por otro libre (ej. `10.161.0.0/24`).

**2. `Conflict. The container name "/cp-herramientas" is already in use`**
- **Qué pasa:** quedó un contenedor viejo con ese nombre.
- **Solución:** `docker rm -f cp-herramientas` y vuelve a levantar.

**3. La construcción falla al descargar Terraform o la AWS CLI**
- **Qué pasa:** sin internet, o la red de la empresa bloquea la descarga.
- **Solución:** revisa tu conexión (o la VPN) y repite `docker compose up -d --build herramientas`.

---

**Siguiente:** Tema 1 — Tu cuenta de AWS y primeros pasos en la consola *(la guía se escribe cuando llegues)*
