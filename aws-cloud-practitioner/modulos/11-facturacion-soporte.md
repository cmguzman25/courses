# Módulo 11 — Facturación, precios y soporte

**Dominio 4 (12%)** · **Horas:** 4 · **Estado:** ⬜

> Solo pesa 12%, pero es el módulo más fácil de exprimir: son datos concretos.
> Aquí se ganan puntos baratos.

## 1. Saber hacer

- [ ] Explicar los 3 principios de precios de AWS
- [ ] Elegir la herramienta correcta: Pricing Calculator, Cost Explorer, Budgets o CUR
- [ ] Elegir el plan de soporte adecuado según necesidad y presupuesto
- [ ] Explicar qué ahorra la facturación consolidada

## 2. Fuente

**Principal:** AWS Cloud Practitioner Essentials — Módulo 9
**Práctica:** entra en la consola de Facturación y crea un presupuesto de 5 USD con alerta.

## 3. Preguntas

### A. Cómo cobra AWS

1. **P:** Los 3 principios de precios de AWS
   **R:** Pago por uso · Paga menos cuando te comprometes (reservas/Savings Plans) · Paga menos cuanto más usas (descuentos por volumen).
2. **P:** ¿Qué se paga siempre y qué suele ser gratis en transferencia de datos?
   **R:** La entrada de datos a AWS suele ser gratis; la **salida** hacia internet se cobra. Entre AZ distintas también hay coste.
3. **P:** Los 3 tipos de capa gratuita
   **R:** Gratis siempre (ej. 1 millón de peticiones Lambda al mes) · 12 meses gratis desde el alta (ej. 750 h de t2/t3.micro) · Pruebas de corta duración.

### B. Herramientas de costes

4. **P:** **Contraste:** Pricing Calculator vs Cost Explorer
   **R:** Pricing Calculator = estima **antes** de gastar. Cost Explorer = analiza y visualiza lo que **ya** gastaste, con previsión a futuro.
5. **P:** ¿Qué te avisa (o actúa) al superar un umbral de gasto?
   **R:** AWS Budgets. Puedes fijar presupuestos de coste, uso, reservas o Savings Plans.
6. **P:** ¿Cuál es el informe más detallado de facturación?
   **R:** AWS Cost and Usage Report (CUR): línea por línea, exportable a S3.
7. **P:** ¿Qué detecta gastos anómalos automáticamente con ML?
   **R:** AWS Cost Anomaly Detection.
8. **P:** ¿Para qué sirven las etiquetas de asignación de costes?
   **R:** Etiquetar recursos (proyecto, entorno, equipo) para desglosar la factura por esas dimensiones.

### C. Varias cuentas

9. **P:** ¿Qué aporta la facturación consolidada de Organizations?
   **R:** Una sola factura para todas las cuentas, y el **uso se agrega** para alcanzar antes los descuentos por volumen y compartir reservas/Savings Plans.
10. **P:** ¿Se paga por usar AWS Organizations?
    **R:** No, es gratuito.

### D. Planes de soporte — memoriza esta tabla

| Plan | Coste | Soporte técnico | Tiempo de respuesta (crítico) | Extras |
|------|-------|-----------------|-------------------------------|--------|
| **Basic** | Gratis | No (solo foros, docs, Health) | — | Trusted Advisor limitado |
| **Developer** | Desde ~29 USD/mes | Email, horario laboral, 1 contacto | Sistema caído: < 12 h | Orientación general |
| **Business** | Desde ~100 USD/mes | 24/7 email, chat, teléfono, ilimitado | Producción caída: < 1 h | Trusted Advisor **completo**, API de soporte |
| **Enterprise On-Ramp** | Desde ~5.500 USD/mes | 24/7 + acceso a un **grupo** de TAM | Crítico para el negocio: < 30 min | Revisiones de arquitectura |
| **Enterprise** | Desde ~15.000 USD/mes | 24/7 + **TAM dedicado** | Crítico para el negocio: < 15 min | Concierge de facturación |

11. **P:** ¿Desde qué plan tienes Trusted Advisor completo?
    **R:** Desde Business.
12. **P:** ¿Desde qué plan tienes un TAM dedicado?
    **R:** Enterprise (On-Ramp da acceso a un grupo de TAM, no dedicado).
13. **P:** ¿Desde qué plan hay soporte 24/7 por teléfono y chat?
    **R:** Business.

### E. Otros

14. **P:** ¿Qué es el TCO y por qué importa aquí?
    **R:** Coste total de propiedad: comparar el gasto real de estar on-premises (hardware, energía, personal, espacio) contra la nube. Justifica la migración.
15. **P:** ¿Qué es AWS Marketplace?
    **R:** Catálogo digital para comprar y desplegar software de terceros, facturado dentro de tu cuenta AWS.

## 4. Mazo

- [ ] Preguntas en Anki (mazo: `AWS CLF::11 Facturación`)

## 5. Feynman

> Un jefe te pregunta: "¿cuánto nos va a costar y cómo evito una sorpresa a fin de mes?"
> Respóndele en 10 líneas, nombrando herramientas concretas.

**Dónde me trabé:**

## 6. Simulacro

| Intento | Fecha | Nota | ¿Cerrado? |
|---------|-------|------|-----------|
| 1 | | / | |

## 7. Bitácora del módulo

| Fallo | Causa real | Acción |
|-------|-----------|--------|
| | | |
