# Módulo 04 — Seguridad y cumplimiento

**Dominio 2 (30%)** · **Horas:** 5 · **Estado:** ⬜

> El módulo más rentable del examen. Aquí se aprueba o se suspende.

## 1. Saber hacer

- [ ] Repartir cualquier tarea entre AWS y el cliente con el modelo de responsabilidad compartida
- [ ] Elegir el servicio de seguridad correcto ante un escenario ("me atacan por DDoS", "tengo datos sensibles en S3"...)
- [ ] Distinguir cifrado en tránsito y en reposo, y quién gestiona las claves
- [ ] Saber dónde se descargan los informes de cumplimiento

## 2. Fuente

**Principal:** AWS Cloud Practitioner Essentials — Módulo 7
Apoyo: página "Shared Responsibility Model" de AWS (una sola lectura, es corta)

## 3. Preguntas

### A. Responsabilidad compartida

1. **P:** La frase que resume el modelo
   **R:** AWS es responsable de la seguridad **DE** la nube; el cliente, de la seguridad **EN** la nube.
2. **P:** ¿Qué es siempre de AWS?
   **R:** Hardware, centros de datos, red física, virtualización y los servicios gestionados por debajo.
3. **P:** ¿Qué es siempre del cliente?
   **R:** Sus datos, la clasificación de esos datos, la gestión de identidades y accesos, y la configuración que él elige.
4. **P:** En EC2, ¿quién parchea el sistema operativo?
   **R:** El cliente. En EC2 (IaaS) el SO es tuyo.
5. **P:** En RDS, ¿quién parchea el motor de base de datos?
   **R:** AWS. Es un servicio gestionado; tú te ocupas de los datos, usuarios y grupos de seguridad.
6. **P:** ¿Cómo cambia el reparto según IaaS/PaaS/SaaS?
   **R:** Cuanto más gestionado el servicio, más responsabilidad asume AWS. En SaaS al cliente casi solo le queda gestionar sus datos y accesos.

### B. Servicios de protección

7. **P:** ¿Qué protege contra DDoS y qué versiones hay?
   **R:** AWS Shield. **Standard** gratis y automático para todos; **Advanced** de pago, con respuesta 24/7 y protección de costos.
8. **P:** ¿Qué filtra tráfico web malicioso (inyección SQL, XSS)?
   **R:** AWS WAF, con reglas sobre CloudFront, ALB o API Gateway.
9. **P:** **Contraste:** GuardDuty vs Inspector vs Macie
   **R:** GuardDuty = detección **continua de amenazas** analizando logs. Inspector = busca **vulnerabilidades** en EC2, contenedores y Lambda. Macie = descubre y protege **datos sensibles en S3** (PII).
10. **P:** ¿Qué centraliza las alertas de seguridad de todos esos servicios?
    **R:** AWS Security Hub.
11. **P:** ¿Qué servicio investiga la causa raíz de un hallazgo de seguridad?
    **R:** Amazon Detective.
12. **P:** ¿Qué protege el perímetro de red de una VPC de forma gestionada?
    **R:** AWS Network Firewall. Para aplicar reglas de WAF/firewall en varias cuentas: AWS Firewall Manager.

### C. Cifrado y secretos

13. **P:** **Contraste:** KMS vs CloudHSM
    **R:** KMS = gestión de claves gestionada por AWS, integrada con casi todo. CloudHSM = módulo de hardware dedicado, tú controlas las claves por completo (requisitos regulatorios estrictos).
14. **P:** **Contraste:** Secrets Manager vs Parameter Store
    **R:** Secrets Manager = secretos con **rotación automática** (de pago). Parameter Store (Systems Manager) = parámetros y secretos sencillos, gratis, sin rotación nativa.
15. **P:** ¿Qué emite y renueva certificados SSL/TLS gratis?
    **R:** AWS Certificate Manager (ACM).
16. **P:** Cifrado en tránsito vs en reposo
    **R:** En tránsito = TLS/HTTPS mientras viaja. En reposo = cifrado del dato guardado (S3, EBS, RDS). En S3 se puede activar por defecto.

### D. Cumplimiento

17. **P:** ¿Dónde descargas los informes de cumplimiento (SOC, ISO, PCI DSS)?
    **R:** AWS Artifact.
18. **P:** ¿Qué servicio automatiza la recopilación de evidencias para auditorías?
    **R:** AWS Audit Manager.
19. **P:** ¿Quién decide si tu carga cumple una normativa concreta?
    **R:** Tú. AWS certifica su infraestructura; el cumplimiento de tu aplicación es tuyo.

## 4. Mazo

- [ ] Preguntas en Anki (mazo: `AWS CLF::04 Seguridad`)

## 5. Feynman

> Caso: guardas datos médicos en S3 y una app en EC2. Explica qué haces tú y qué
> hace AWS para que eso sea seguro. Nombra al menos 5 servicios y por qué cada uno.

**Dónde me trabé:**

## 6. Simulacro

| Intento | Fecha | Nota | ¿Cerrado? |
|---------|-------|------|-----------|
| 1 | | / | |

## 7. Bitácora del módulo

| Fallo | Causa real | Acción |
|-------|-----------|--------|
| | | |
