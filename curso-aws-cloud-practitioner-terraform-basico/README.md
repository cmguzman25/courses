# AWS Cloud Practitioner práctico con Terraform

Curso guiado para quien ya estudió la teoría de **AWS Cloud Practitioner (CLF-C02)** y quiere practicar en AWS de verdad. Se trabaja con **Terraform** (se aprende desde cero) y se explora la **consola de AWS** después de cada práctica.

**Claude Code es el profesor:** te explica cada tema, revisa tu código y lleva tu progreso. Cada persona avanza a su ritmo.

Temas: ver [`temario.md`](temario.md).

> ⚠️ **Este curso usa una cuenta real de AWS y puede costar dinero.** El Tema 3 configura una alarma de precios antes de crear nada que cobre, y cada práctica termina con `terraform destroy`. Si te saltas el `destroy`, pagas.

---

## Qué necesitas

| Herramienta | Para qué |
|---|---|
| [Docker Desktop](https://www.docker.com/products/docker-desktop/) | Trae Terraform y la AWS CLI dentro de un contenedor. No instalas nada más |
| [Git](https://git-scm.com/downloads) | Para descargar el curso y guardar tu avance |
| [Claude Code](https://claude.com/claude-code) | El profesor |
| Una tarjeta de crédito o débito | AWS la pide para crear la cuenta (Tema 1) |
| Un editor, ej. [VS Code](https://code.visualstudio.com/) | Para escribir el código |

## Cómo empezar

1. **Haz un fork** de este repositorio en GitHub (botón *Fork*). Así tienes tu propia copia donde guardar tu progreso.
2. Clona tu fork:

   ```powershell
   git clone https://github.com/<tu-usuario>/courses.git
   cd courses\curso-aws-cloud-practitioner-terraform-basico
   ```

3. Abre Claude Code **dentro de esta carpeta** (es importante: aquí están las reglas del curso):

   ```powershell
   claude
   ```

4. Escribe: **"Quiero empezar el curso"**. Claude te preguntará quién eres; elige **"Soy un usuario nuevo"**, dile tu nombre y te creará tu carpeta en `alumnos/`.
5. Sigue con el Tema 0.

## Retomar otro día (o en otra computadora)

- Tu avance vive en `alumnos/<tu-nombre>/PROGRESO.md`. Al terminar una sesión, súbelo a **tu** fork:

  ```powershell
  git add alumnos/<tu-nombre>
  git commit -m "Progress: topic N"
  git push
  ```

- En otra computadora: clona tu fork, abre `claude` en esta carpeta y elige tu nombre. Claude retoma donde quedaste.
- Tus credenciales de AWS (carpeta `.aws/`) **no** viajan con git, a propósito. En la otra computadora las vuelves a configurar (Claude te guía).

## Reglas de oro

1. **Nunca** subas a git ni compartas tus llaves de AWS. El `.gitignore` ya excluye `.aws/`, `*.tfstate` y `*.tfvars`; no lo cambies.
2. **Siempre** `terraform destroy` al terminar cada práctica, y revisa en la consola que no quedó nada.
3. Si te llega un aviso de la alarma de precios, para y díselo a Claude antes de seguir.
