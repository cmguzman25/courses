# Módulo 06 — Almacenamiento

**Dominio 3 (34%)** · **Horas:** 4 · **Estado:** ⬜

## 1. Saber hacer

- [ ] Elegir entre S3, EBS, EFS e Instance Store ante un caso
- [ ] Elegir la clase de S3 correcta según patrón de acceso
- [ ] Explicar versionado y ciclo de vida en S3
- [ ] Saber cuándo se usa la familia Snow y Storage Gateway

## 2. Fuente

**Principal:** AWS Cloud Practitioner Essentials — Módulo 5
**Práctica:** crea un bucket, sube un archivo, activa versionado, bórralo.

## 3. Preguntas

### A. El contraste principal

1. **P:** **Contraste:** almacenamiento de objetos, de bloques y de archivos
   **R:** Objetos (S3) = archivos completos con metadatos, acceso por API. Bloques (EBS) = disco de una máquina, modificas solo el bloque cambiado. Archivos (EFS/FSx) = sistema de archivos compartido en red.
2. **P:** ¿Cuándo EBS y cuándo EFS?
   **R:** EBS = disco de **una** instancia, atado a **una AZ**. EFS = sistema de archivos compartido por **muchas** instancias, **multi-AZ** y elástico.
3. **P:** ¿Qué es Instance Store y cuál es su trampa?
   **R:** Disco físico local de la instancia, muy rápido, pero **efímero**: si paras o terminas la instancia, se pierden los datos.

### B. Amazon S3

4. **P:** ¿Qué durabilidad ofrece S3?
   **R:** 99,999999999% (11 nueves), replicando en varias AZ dentro de la Región.
5. **P:** ¿Cuál es el tamaño máximo de un objeto en S3?
   **R:** 5 TB.
6. **P:** ¿Los buckets de S3 son públicos por defecto?
   **R:** No. Son privados y desde 2023 el bloqueo de acceso público viene activado.
7. **P:** Clases de S3 y cuándo
   **R:** **Standard** = acceso frecuente · **Intelligent-Tiering** = patrón desconocido, mueve solo · **Standard-IA** = poco frecuente pero acceso rápido · **One Zone-IA** = igual pero en 1 AZ, más barato, reproducible · **Glacier Instant Retrieval** = archivo con acceso en ms · **Glacier Flexible Retrieval** = minutos-horas · **Glacier Deep Archive** = el más barato, 12+ horas.
8. **P:** ¿Para qué sirve una política de ciclo de vida?
   **R:** Mover objetos entre clases o borrarlos automáticamente al cumplir cierta edad. Es la forma principal de ahorrar en S3.
9. **P:** ¿Qué hace el versionado?
   **R:** Guarda todas las versiones de un objeto; te protege de sobrescrituras y borrados accidentales.
10. **P:** ¿Qué copia objetos a otra Región automáticamente?
    **R:** Cross-Region Replication (requiere versionado activado).

### C. EBS

11. **P:** Tipos de volumen EBS
    **R:** SSD de uso general (gp2/gp3) · SSD IOPS provisionadas (io1/io2) para bases de datos exigentes · HDD optimizado para rendimiento (st1) · HDD frío (sc1) para acceso raro.
12. **P:** ¿Qué es una instantánea (snapshot) de EBS y dónde se guarda?
    **R:** Copia de seguridad incremental del volumen, guardada en S3 (gestionado por AWS). Permite recrear el volumen en otra AZ o Región.

### D. Híbrido y transferencia

13. **P:** ¿Qué es AWS Storage Gateway?
    **R:** Pasarela híbrida: tus servidores locales acceden a almacenamiento en AWS como si fuera local (File, Volume, Tape Gateway).
14. **P:** ¿Cuándo usas la familia Snow?
    **R:** Para mover volúmenes grandes de datos (TB/PB) cuando la red no da abasto: dispositivos físicos que AWS te envía. Snowcone (pequeño) y Snowball Edge.
15. **P:** ¿Qué servicio copia datos entre local y AWS **por red**, de forma gestionada?
    **R:** AWS DataSync.
16. **P:** ¿Qué centraliza copias de seguridad de muchos servicios AWS?
    **R:** AWS Backup.
17. **P:** **Contraste:** FSx for Windows File Server vs FSx for Lustre
    **R:** Windows File Server = comparticiones SMB para cargas Windows. Lustre = sistema de archivos de altísimo rendimiento para HPC y machine learning.

## 4. Mazo

- [ ] Preguntas en Anki (mazo: `AWS CLF::06 Almacenamiento`)

## 5. Feynman

> Una empresa guarda facturas: se consultan mucho el primer mes, casi nunca al año,
> y por ley hay que conservarlas 10 años. Diseña el almacenamiento y justifícalo.

**Dónde me trabé:**

## 6. Simulacro

| Intento | Fecha | Nota | ¿Cerrado? |
|---------|-------|------|-----------|
| 1 | | / | |

## 7. Bitácora del módulo

| Fallo | Causa real | Acción |
|-------|-----------|--------|
| | | |
