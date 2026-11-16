# Módulo 05 — Cómputo

**Dominio 3 (34%)** · **Horas:** 5 · **Estado:** ⬜

## 1. Saber hacer

- [ ] Elegir entre EC2, Lambda, contenedores y Beanstalk según el caso
- [ ] Elegir el modelo de compra de EC2 más barato para un patrón de uso dado
- [ ] Explicar qué hace Auto Scaling y qué hace un balanceador, y por qué van juntos
- [ ] Distinguir ECS, EKS y Fargate

## 2. Fuente

**Principal:** AWS Cloud Practitioner Essentials — Módulos 2 y 3
**Práctica:** lanza una EC2 t2/t3.micro, conéctate y bórrala. Crea una Lambda "hola mundo".

## 3. Preguntas

### A. EC2

1. **P:** ¿Qué es EC2?
   **R:** Servidores virtuales bajo demanda. Tú eliges CPU, memoria, red, SO y tú lo administras (IaaS).
2. **P:** ¿Qué es una AMI?
   **R:** La plantilla (SO + configuración + software) desde la que arranca una instancia.
3. **P:** Nombra las familias de instancia por caso de uso
   **R:** Uso general (T, M) · Optimizadas para cómputo (C) · Para memoria (R, X) · Para almacenamiento (I, D) · Para cómputo acelerado/GPU (P, G).

### B. Modelos de compra — la pregunta estrella

4. **P:** On-Demand, ¿cuándo?
   **R:** Cargas impredecibles, cortas o de prueba. Pagas por segundo/hora sin compromiso. La más cara por hora.
5. **P:** **Contraste:** Instancias Reservadas vs Savings Plans
    **R:** Ambas: comprometerse 1 o 3 años a cambio de hasta ~72% de descuento. Reservadas atan a un tipo/familia de instancia; Savings Plans comprometen un **gasto por hora** y son más flexibles (algunos cubren también Lambda y Fargate).
6. **P:** Instancias Spot, ¿cuándo y cuál es el riesgo?
   **R:** Hasta ~90% de descuento usando capacidad sobrante, pero AWS te la puede quitar con 2 minutos de aviso. Solo para cargas tolerantes a interrupción: batch, procesamiento, pruebas.
7. **P:** **Contraste:** Host dedicado vs Instancia dedicada
   **R:** Host dedicado = servidor físico entero para ti, ves los sockets/cores (sirve para licencias BYOL). Instancia dedicada = hardware no compartido, pero sin visibilidad del host.
8. **P:** Necesito capacidad garantizada en una AZ concreta, sin compromiso de plazo. ¿Qué uso?
   **R:** On-Demand Capacity Reservations.

### C. Escalado y balanceo

9. **P:** ¿Qué hace EC2 Auto Scaling?
   **R:** Añade o quita instancias automáticamente según demanda o salud, entre un mínimo, un deseado y un máximo.
10. **P:** ¿Qué hace Elastic Load Balancing?
    **R:** Reparte el tráfico entrante entre varios destinos sanos, en varias AZ.
11. **P:** **Contraste:** ALB vs NLB
    **R:** ALB = capa 7 (HTTP/HTTPS), enruta por ruta o host. NLB = capa 4 (TCP/UDP), altísimo rendimiento y latencia mínima.

### D. Serverless y contenedores

12. **P:** ¿Qué es AWS Lambda?
    **R:** Ejecuta tu código en respuesta a eventos, sin servidores que administrar. Pagas por invocación y duración. Límite de 15 minutos por ejecución.
13. **P:** ¿Qué significa "serverless"?
    **R:** No aprovisionas ni administras servidores, escala solo y pagas por uso. Ejemplos: Lambda, Fargate, S3, DynamoDB, SQS.
14. **P:** **Contraste:** ECS vs EKS
    **R:** Ambos orquestan contenedores. ECS = orquestador propio de AWS, más simple. EKS = Kubernetes gestionado, para quien ya usa Kubernetes.
15. **P:** ¿Qué es Fargate?
    **R:** El modo **sin servidores** de ECS/EKS: no gestionas las EC2 subyacentes. La alternativa es el modo EC2, donde tú mantienes las instancias.
16. **P:** ¿Dónde guardas tus imágenes de contenedor en AWS?
    **R:** Amazon ECR.

### E. Servicios de plataforma

17. **P:** **Contraste:** Elastic Beanstalk vs Lightsail
    **R:** Beanstalk = subes el código y AWS crea y gestiona EC2, balanceador y escalado (PaaS). Lightsail = servidores y stacks preconfigurados a **precio fijo mensual**, para proyectos pequeños.
18. **P:** ¿Qué servicio ejecuta trabajos por lotes gestionados?
    **R:** AWS Batch.

## 4. Mazo

- [ ] Preguntas en Anki (mazo: `AWS CLF::05 Cómputo`)

## 5. Feynman

> Tienes una web con picos los lunes y tráfico bajo el resto de la semana.
> Explica qué cómputo eliges, con qué modelo de compra, y cuánto crees que ahorras.

**Dónde me trabé:**

## 6. Simulacro

| Intento | Fecha | Nota | ¿Cerrado? |
|---------|-------|------|-----------|
| 1 | | / | |

## 7. Bitácora del módulo

| Fallo | Causa real | Acción |
|-------|-----------|--------|
| | | |
