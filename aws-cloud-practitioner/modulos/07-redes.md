# Módulo 07 — Redes y entrega de contenido

**Dominio 3 (34%)** · **Horas:** 5 · **Estado:** ⬜

## 1. Saber hacer

- [ ] Dibujar una VPC con subred pública y privada, y explicar cómo sale a internet cada una
- [ ] Distinguir Security Group y Network ACL sin dudar
- [ ] Elegir entre Direct Connect y VPN para un caso híbrido
- [ ] Explicar qué hace CloudFront y en qué se diferencia de Global Accelerator

## 2. Fuente

**Principal:** AWS Cloud Practitioner Essentials — Módulo 4
**Práctica:** dibuja a mano tu propia VPC. Este módulo se aprende dibujando, no leyendo.

## 3. Preguntas

### A. VPC

1. **P:** ¿Qué es una VPC?
   **R:** Tu red virtual aislada dentro de una Región, donde defines rangos IP, subredes y enrutamiento.
2. **P:** **Contraste:** subred pública vs privada
   **R:** Pública = su tabla de rutas apunta a una Internet Gateway. Privada = no tiene esa ruta; sale a internet (si acaso) por una NAT Gateway.
3. **P:** ¿Qué hace una Internet Gateway?
   **R:** Permite comunicación bidireccional entre la VPC e internet.
4. **P:** ¿Qué hace una NAT Gateway?
   **R:** Deja que instancias en subred **privada** inicien conexiones salientes a internet, sin que internet pueda alcanzarlas.
5. **P:** ¿Puede una subred abarcar varias AZ?
   **R:** No. Cada subred vive en una sola AZ.

### B. El contraste que más cae

6. **P:** **Contraste:** Security Group vs Network ACL
   **R:** **SG**: nivel de instancia · con estado (stateful) · solo reglas Allow · evalúa todas las reglas. **NACL**: nivel de subred · sin estado (stateless) · Allow **y Deny** · evalúa reglas por número, en orden.
7. **P:** Por defecto, un Security Group nuevo ¿qué permite?
   **R:** Todo el tráfico de salida, nada de entrada.
8. **P:** Quiero bloquear una IP concreta que me ataca. ¿SG o NACL?
   **R:** NACL, porque es la única que admite reglas Deny.

### C. Conectividad

9. **P:** **Contraste:** Site-to-Site VPN vs Direct Connect
   **R:** VPN = túnel cifrado **por internet**, barato y rápido de montar, pero con latencia variable. Direct Connect = línea física dedicada, ancho de banda consistente y latencia baja, más cara y tarda semanas.
10. **P:** ¿Qué conecta dos VPC de forma privada, una a una?
    **R:** VPC Peering. Sin tránsito: si A-B y B-C, A no habla con C.
11. **P:** ¿Qué conecta cientos de VPC y redes locales desde un punto central?
    **R:** AWS Transit Gateway.
12. **P:** ¿Qué permite llegar a S3 o DynamoDB sin salir a internet?
    **R:** VPC Endpoints (de tipo Gateway). Para otros servicios: Interface Endpoints / AWS PrivateLink.

### D. DNS y entrega de contenido

13. **P:** ¿Qué es Amazon Route 53?
    **R:** DNS gestionado y registrador de dominios, con comprobaciones de estado y políticas de enrutamiento.
14. **P:** Políticas de enrutamiento de Route 53
    **R:** Simple · Ponderada · Latencia · Failover · Geolocalización · Geoproximidad · Multivalor.
15. **P:** ¿Qué es Amazon CloudFront?
    **R:** CDN: cachea contenido en Ubicaciones de Borde para servirlo cerca del usuario, con menos latencia y menos carga en el origen.
16. **P:** **Contraste:** CloudFront vs Global Accelerator
    **R:** CloudFront **cachea contenido** (HTTP/S) en el borde. Global Accelerator no cachea: da IPs estáticas y enruta el tráfico (TCP/UDP) por la red troncal de AWS hasta el endpoint más cercano.

## 4. Mazo

- [ ] Preguntas en Anki (mazo: `AWS CLF::07 Redes`)

## 5. Feynman

> Dibuja de memoria: VPC con 2 AZ, subred pública con balanceador, subred privada
> con servidores y base de datos. Marca dónde va el SG y dónde la NACL, y por dónde
> sale a internet cada capa.

**Dónde me trabé:**

## 6. Simulacro

| Intento | Fecha | Nota | ¿Cerrado? |
|---------|-------|------|-----------|
| 1 | | / | |

## 7. Bitácora del módulo

| Fallo | Causa real | Acción |
|-------|-----------|--------|
| | | |
