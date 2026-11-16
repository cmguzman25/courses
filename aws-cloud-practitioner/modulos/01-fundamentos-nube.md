# Módulo 01 — Fundamentos de la nube

**Dominio 1 (24%)** · **Horas:** 3 · **Estado:** ⬜

## 1. Saber hacer

- [ ] Explicar qué es la computación en la nube en 3 frases, sin jerga
- [ ] Distinguir IaaS / PaaS / SaaS con un ejemplo de AWS cada uno
- [ ] Distinguir nube / híbrido / on-premises y decir cuándo conviene cada uno
- [ ] Explicar CapEx vs OpEx con números
- [ ] Diferenciar escalabilidad, elasticidad, agilidad, alta disponibilidad y tolerancia a fallos
- [ ] Nombrar las 4 formas de interactuar con AWS

## 2. Fuente

**Principal:** AWS Cloud Practitioner Essentials — Módulo 1 (Skill Builder)
Apoyo: guía oficial del examen CLF-C02 (PDF), sección Dominio 1

## 3. Preguntas

### A. Qué es la nube

1. **P:** ¿Qué es la computación en la nube?
   **R:** Entrega bajo demanda de recursos de TI por internet, con pago por uso.
2. **P:** Las 6 ventajas de la nube según AWS
   **R:** (1) Cambiar gasto inicial por gasto variable · (2) beneficiarse de economías de escala · (3) dejar de adivinar la capacidad · (4) más velocidad y agilidad · (5) dejar de gastar en mantener centros de datos · (6) llegar a todo el mundo en minutos.
3. **P:** CapEx vs OpEx
   **R:** CapEx = pagas el servidor por adelantado y lo amortizas. OpEx = pagas por hora/uso, sin inversión inicial. La nube convierte CapEx en OpEx.

### B. Modelos de servicio

4. **P:** IaaS, ¿qué controlas tú? Ejemplo AWS
   **R:** Controlas SO, red y almacenamiento. Ejemplo: EC2.
5. **P:** PaaS, ¿qué gestiona AWS? Ejemplo
   **R:** AWS gestiona SO y runtime; tú solo el código y los datos. Ejemplo: Elastic Beanstalk, RDS.
6. **P:** SaaS. Ejemplo
   **R:** Software terminado, tú solo lo usas. Ejemplo: Amazon WorkMail, Salesforce.

### C. Modelos de despliegue

7. **P:** ¿Cuándo elegir híbrido?
   **R:** Cuando parte de la carga debe quedarse en local: regulación, latencia muy baja, o hardware legado que no se puede migrar.
8. **P:** ¿Qué servicio de AWS lleva infraestructura AWS a tu propio centro de datos?
   **R:** AWS Outposts.

### D. Propiedades clave

9. **P:** Escalabilidad vs elasticidad
   **R:** Escalabilidad = puedes crecer. Elasticidad = creces **y decreces** solo, automáticamente, según la demanda.
10. **P:** Escalado vertical vs horizontal
    **R:** Vertical = instancia más grande. Horizontal = más instancias. En la nube se prefiere el horizontal.
11. **P:** Alta disponibilidad vs tolerancia a fallos
    **R:** HA = poco tiempo caído (recupera rápido). Tolerancia a fallos = sigue funcionando aunque un componente muera, sin interrupción.
12. **P:** Agilidad, en una frase
    **R:** Poder probar una idea en minutos en vez de en meses, porque no compras hardware.

### E. Cómo se usa AWS

13. **P:** Las 4 formas de interactuar con AWS
    **R:** Consola de administración (web), AWS CLI, SDK (código) e Infraestructura como Código (CloudFormation/CDK).

## 4. Mazo

- [ ] Preguntas en Anki (mazo: `AWS CLF::01 Fundamentos`)

## 5. Feynman

> Explica a un amigo sin conocimientos técnicos qué es la nube, por qué una empresa
> se cambiaría a ella, y qué pierde al hacerlo. Máx. 15 líneas, sin mirar.

**Dónde me trabé:**

## 6. Simulacro

| Intento | Fecha | Nota | ¿Cerrado? |
|---------|-------|------|-----------|
| 1 | | / | |

## 7. Bitácora del módulo

| Fallo | Causa real | Acción |
|-------|-----------|--------|
| | | |
