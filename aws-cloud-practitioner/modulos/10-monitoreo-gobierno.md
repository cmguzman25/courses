# Módulo 10 — Monitoreo, gobierno y migración

**Dominio 3 (34%)** · **Horas:** 4 · **Estado:** ⬜

## 1. Saber hacer

- [ ] Distinguir CloudWatch, CloudTrail y Config sin dudar (cae casi seguro)
- [ ] Explicar qué resuelve AWS Organizations y qué es una SCP
- [ ] Nombrar las 5 categorías de Trusted Advisor
- [ ] Nombrar las 7 R de migración y las 6 perspectivas del CAF

## 2. Fuente

**Principal:** AWS Cloud Practitioner Essentials — Módulos 8 y 9
Apoyo: AWS Cloud Adoption Framework (solo el resumen de las 6 perspectivas)

## 3. Preguntas

### A. El trío que confunde a todo el mundo

1. **P:** **Contraste:** CloudWatch vs CloudTrail vs Config
   **R:** **CloudWatch** = *¿cómo va?* Métricas, logs, alarmas y paneles. **CloudTrail** = *¿quién hizo qué y cuándo?* Auditoría de llamadas a la API. **Config** = *¿cómo está configurado y ha cambiado?* Inventario, historial y reglas de conformidad.
2. **P:** Alguien borró una instancia y quiero saber quién. ¿Qué miro?
   **R:** CloudTrail.
3. **P:** Quiero que me avisen si la CPU pasa del 80%. ¿Qué uso?
   **R:** Una alarma de CloudWatch (que puede notificar por SNS o disparar Auto Scaling).
4. **P:** Quiero comprobar que ningún bucket S3 esté público. ¿Qué uso?
   **R:** Una regla de AWS Config (o Security Hub para verlo agregado).

### B. Gobierno y automatización

5. **P:** ¿Qué es AWS Organizations?
   **R:** Gestión central de varias cuentas: unidades organizativas (OU), facturación consolidada y políticas comunes.
6. **P:** ¿Qué es una SCP?
   **R:** Service Control Policy: define el **máximo** de permisos posibles en una cuenta u OU. No concede permisos, solo limita.
7. **P:** ¿Qué monta una zona de aterrizaje multicuenta con buenas prácticas ya aplicadas?
   **R:** AWS Control Tower.
8. **P:** ¿Qué es AWS Trusted Advisor y sus categorías?
   **R:** Revisa tu cuenta y recomienda mejoras en: optimización de costos, rendimiento, seguridad, tolerancia a fallos y límites de servicio. Con Basic/Developer solo ves un subconjunto.
9. **P:** ¿Qué es infraestructura como código en AWS?
   **R:** AWS CloudFormation: describes la infraestructura en plantillas YAML/JSON y AWS la crea y actualiza. Con CDK la escribes en un lenguaje de programación.
10. **P:** ¿Qué gestiona y parchea flotas de instancias a escala?
    **R:** AWS Systems Manager.
11. **P:** ¿Qué ofrece un catálogo de plantillas aprobadas a los equipos internos?
    **R:** AWS Service Catalog.
12. **P:** **Contraste:** Service Health Dashboard vs Personal Health Dashboard
    **R:** El primero muestra el estado general de los servicios AWS; el segundo (AWS Health) muestra los eventos que afectan **a tus recursos**.

### C. Migración

13. **P:** Las 7 R de migración
    **R:** Rehost (mover tal cual) · Replatform (ajustes menores) · Repurchase (cambiar a SaaS) · Refactor (rediseñar) · Retire (eliminar) · Retain (dejar donde está) · Relocate (mover el hipervisor entero).
14. **P:** Las 6 perspectivas del Cloud Adoption Framework (CAF)
    **R:** Negocio · Personas · Gobernanza · Plataforma · Seguridad · Operaciones. Las 3 primeras son de negocio; las 3 últimas, técnicas.
15. **P:** ¿Qué servicio rastrea el progreso de una migración?
    **R:** AWS Migration Hub. Para descubrir el inventario local: Application Discovery Service. Para replicar servidores: Application Migration Service (MGN).
16. **P:** ¿Qué transfiere archivos por SFTP/FTPS hacia S3?
    **R:** AWS Transfer Family.

## 4. Mazo

- [ ] Preguntas en Anki (mazo: `AWS CLF::10 Gobierno`)

## 5. Feynman

> Explica en 3 frases la diferencia entre CloudWatch, CloudTrail y Config, usando
> una analogía que no sea técnica. Si tardas más de 20 segundos, no lo tienes.

**Dónde me trabé:**

## 6. Simulacro

| Intento | Fecha | Nota | ¿Cerrado? |
|---------|-------|------|-----------|
| 1 | | / | |

## 7. Bitácora del módulo

| Fallo | Causa real | Acción |
|-------|-----------|--------|
| | | |
