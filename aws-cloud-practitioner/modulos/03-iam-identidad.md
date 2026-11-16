# Módulo 03 — IAM e identidad

**Dominio 2 (30%)** · **Horas:** 4 · **Estado:** ⬜

## 1. Saber hacer

- [ ] Explicar usuario / grupo / rol / política y cuándo se usa cada uno
- [ ] Decir qué se hace y qué NO se hace con el usuario raíz
- [ ] Aplicar el principio de menor privilegio a un caso
- [ ] Explicar cómo evalúa IAM una petición (denegado por defecto, deny explícito gana)
- [ ] Distinguir IAM, IAM Identity Center y Cognito

## 2. Fuente

**Principal:** AWS Cloud Practitioner Essentials — Módulo 7 (Seguridad)
**Práctica obligatoria:** crea tu cuenta, activa MFA en la raíz, crea un usuario admin y usa ese.

## 3. Preguntas

### A. Usuario raíz

1. **P:** ¿Qué tiene de especial el usuario raíz?
   **R:** Acceso total y sin límite a la cuenta. Se crea con la cuenta y no se le pueden quitar permisos.
2. **P:** ¿Qué haces con la raíz nada más crear la cuenta?
   **R:** Activar MFA, guardar la contraseña, borrar sus claves de acceso y no volver a usarla para el día a día.
3. **P:** ¿Qué tareas solo puede hacer la raíz?
   **R:** Cerrar la cuenta, cambiar el plan de soporte, cambiar el email/nombre de la cuenta, restaurar permisos de IAM perdidos.

### B. Usuarios, grupos, roles

4. **P:** ¿Qué es un usuario IAM?
   **R:** Identidad permanente para una persona o app, con credenciales propias (contraseña y/o claves de acceso).
5. **P:** ¿Para qué sirve un grupo?
   **R:** Asignar permisos a un conjunto de usuarios de golpe. Un grupo no tiene credenciales y no puede contener otros grupos.
6. **P:** **Contraste:** usuario vs rol
   **R:** Usuario = credenciales permanentes, es "alguien". Rol = permisos temporales que **cualquiera asume** (una EC2, un servicio, otra cuenta, un usuario federado). No tiene contraseña.
7. **P:** ¿Cómo le das a una EC2 permiso para leer un bucket de S3?
   **R:** Le asignas un **rol IAM**. Nunca metes claves de acceso dentro de la instancia.
8. **P:** ¿Qué es una política IAM?
   **R:** Documento JSON que define permisos: Effect (Allow/Deny), Action, Resource y opcionalmente Condition.
9. **P:** Política gestionada vs en línea
   **R:** Gestionada = reutilizable en varias identidades (de AWS o tuya). En línea = pegada a una sola identidad, se borra con ella.

### C. Evaluación de permisos

10. **P:** Si a un usuario no le dices nada, ¿qué puede hacer?
    **R:** Nada. Denegación implícita por defecto.
11. **P:** Una política le da Allow y otra le da Deny sobre lo mismo. ¿Qué gana?
    **R:** El **Deny explícito** siempre gana.
12. **P:** ¿Qué es el principio de menor privilegio?
    **R:** Dar solo los permisos necesarios para la tarea, y nada más. Es la recomendación base de AWS.

### D. Más allá de IAM

13. **P:** ¿Qué es MFA y qué protege?
    **R:** Segundo factor además de la contraseña. Protege contra credenciales robadas. Obligatorio en la raíz.
14. **P:** **Contraste:** IAM Identity Center vs IAM
    **R:** IAM = identidades dentro de una cuenta. Identity Center (antes AWS SSO) = acceso único a **varias cuentas** y apps, normalmente conectado a tu directorio corporativo.
15. **P:** **Contraste:** IAM vs Cognito
    **R:** IAM = quién administra tu infraestructura AWS. Cognito = login de los **usuarios finales de tu aplicación** (móvil/web).
16. **P:** ¿Qué es la federación de identidades?
    **R:** Iniciar sesión en AWS con un proveedor externo (Active Directory, Google, SAML) sin crear usuarios IAM.

## 4. Mazo

- [ ] Preguntas en Anki (mazo: `AWS CLF::03 IAM`)

## 5. Feynman

> Explica a un compañero nuevo cómo darías acceso a: (a) un desarrollador humano,
> (b) una aplicación en EC2, (c) una empresa externa. Y por qué cada caso es distinto.

**Dónde me trabé:**

## 6. Simulacro

| Intento | Fecha | Nota | ¿Cerrado? |
|---------|-------|------|-----------|
| 1 | | / | |

## 7. Bitácora del módulo

| Fallo | Causa real | Acción |
|-------|-----------|--------|
| | | |
