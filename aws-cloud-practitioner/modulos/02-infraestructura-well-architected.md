# Módulo 02 — Infraestructura global y Well-Architected

**Dominio 1 (24%)** · **Horas:** 3 · **Estado:** ⬜

## 1. Saber hacer

- [ ] Explicar Región, Zona de Disponibilidad y Ubicación de Borde, y cómo se relacionan
- [ ] Elegir una Región justificando con los 4 criterios
- [ ] Nombrar los 6 pilares del Well-Architected Framework y qué cubre cada uno
- [ ] Aplicar los principios de diseño en la nube a un caso concreto

## 2. Fuente

**Principal:** AWS Cloud Practitioner Essentials — Módulos 2 y 8
Apoyo: AWS Well-Architected Framework (whitepaper, solo la intro y los pilares)

## 3. Preguntas

### A. Infraestructura global

1. **P:** ¿Qué es una Región?
   **R:** Un área geográfica con varias Zonas de Disponibilidad aisladas entre sí. Los datos no salen de la Región salvo que tú lo autorices.
2. **P:** ¿Qué es una Zona de Disponibilidad (AZ)?
   **R:** Uno o más centros de datos separados físicamente dentro de una Región, con energía y red independientes, unidos por red de baja latencia.
3. **P:** ¿Cuántas AZ tiene como mínimo una Región y por qué importa?
   **R:** Al menos 3. Desplegar en varias AZ es la forma básica de conseguir alta disponibilidad.
4. **P:** Los 4 criterios para elegir Región
   **R:** (1) Cumplimiento normativo / soberanía de datos · (2) latencia respecto a tus usuarios · (3) precio (varía por Región) · (4) disponibilidad del servicio en esa Región.
5. **P:** ¿Qué es una Ubicación de Borde (Edge Location)?
   **R:** Punto de presencia cercano al usuario para cachear contenido. Lo usan CloudFront y Route 53. Hay muchas más que Regiones.
6. **P:** ¿Qué es una Local Zone?
   **R:** Extensión de una Región más cerca de una ciudad concreta, para latencias de un dígito en milisegundos.
7. **P:** **Contraste:** Outposts vs Local Zone vs Wavelength
   **R:** Outposts = hardware AWS en **tu** datacenter. Local Zone = infraestructura AWS cerca de una ciudad. Wavelength = dentro de la red 5G de una telco.
8. **P:** ¿Qué servicios son globales (no regionales)?
   **R:** IAM, Route 53, CloudFront, WAF (con CloudFront) y la facturación.

### B. Well-Architected Framework

9. **P:** Los 6 pilares
   **R:** Excelencia operativa · Seguridad · Fiabilidad · Eficiencia del rendimiento · Optimización de costos · Sostenibilidad.
10. **P:** ¿Qué cubre el pilar de Fiabilidad?
    **R:** Que la carga de trabajo se recupere de fallos y cumpla lo que promete: recuperación, escalado horizontal, pruebas de recuperación.
11. **P:** ¿Qué cubre Excelencia operativa?
    **R:** Ejecutar y monitorizar sistemas y mejorarlos continuamente: automatización, cambios pequeños y reversibles, aprender de los fallos.
12. **P:** ¿Qué herramienta te evalúa contra el framework, gratis?
    **R:** AWS Well-Architected Tool.

### C. Principios de diseño en la nube

13. **P:** ¿Qué significa "diseñar para el fallo"?
    **R:** Asumir que todo componente puede caer: redundancia en varias AZ, sin puntos únicos de fallo, recuperación automática.
14. **P:** ¿Por qué se busca desacoplar los componentes?
    **R:** Para que el fallo o la lentitud de una pieza no arrastre al resto. Se hace con colas (SQS), notificaciones (SNS) y balanceadores.
15. **P:** ¿Qué es "elasticidad" aplicada al diseño?
    **R:** Aprovisionar según la demanda real, no según el pico previsto. Auto Scaling en lugar de sobredimensionar.

## 4. Mazo

- [ ] Preguntas en Anki (mazo: `AWS CLF::02 Infraestructura`)

## 5. Feynman

> Dibuja de memoria: Región → AZ → subred, y encima las Ubicaciones de Borde.
> Explica dónde pondrías una app para que sobreviva a la caída de un centro de datos.

**Dónde me trabé:**

## 6. Simulacro

| Intento | Fecha | Nota | ¿Cerrado? |
|---------|-------|------|-----------|
| 1 | | / | |

## 7. Bitácora del módulo

| Fallo | Causa real | Acción |
|-------|-----------|--------|
| | | |
