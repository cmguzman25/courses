# Módulo 08 — Bases de datos y analítica

**Dominio 3 (34%)** · **Horas:** 4 · **Estado:** ⬜

## 1. Saber hacer

- [ ] Elegir entre RDS, Aurora, DynamoDB y una BD en EC2 según el caso
- [ ] Distinguir Multi-AZ (disponibilidad) de réplicas de lectura (rendimiento)
- [ ] Elegir el servicio de analítica correcto: Redshift, Athena, Glue, Kinesis, QuickSight
- [ ] Nombrar la base de datos especializada para grafos, series temporales y documentos

## 2. Fuente

**Principal:** AWS Cloud Practitioner Essentials — Módulo 5
Apoyo: página "AWS Databases" (la tabla de casos de uso, nada más)

## 3. Preguntas

### A. Relacionales

1. **P:** ¿Qué es Amazon RDS y qué te quita de encima?
   **R:** Base de datos relacional gestionada: AWS hace el aprovisionamiento, parcheado, copias de seguridad y recuperación. Tú te ocupas de esquemas, datos y consultas.
2. **P:** Motores que soporta RDS
   **R:** MySQL, PostgreSQL, MariaDB, Oracle, SQL Server y Amazon Aurora.
3. **P:** **Contraste:** Multi-AZ vs réplica de lectura
   **R:** Multi-AZ = copia en espera en otra AZ para **alta disponibilidad**, con failover automático; no sirve para leer. Réplica de lectura = copia adicional para **repartir carga de lectura**; se puede promover, pero no es failover automático.
4. **P:** ¿Qué aporta Aurora frente a MySQL/PostgreSQL en RDS?
   **R:** Compatible con ambos, hasta 5x/3x más rendimiento, almacenamiento que crece solo, 6 copias en 3 AZ. Existe Aurora Serverless para cargas intermitentes.
5. **P:** ¿Cuándo montarías la base de datos en EC2 en vez de RDS?
   **R:** Cuando necesitas control total del SO o del motor, o una versión/configuración que RDS no soporta. Asumes tú toda la administración.

### B. NoSQL y especializadas

6. **P:** ¿Qué es DynamoDB?
   **R:** Base NoSQL clave-valor, serverless, escala automáticamente, latencia de milisegundos de un dígito a cualquier escala.
7. **P:** ¿Qué acelera DynamoDB a microsegundos?
   **R:** DAX (DynamoDB Accelerator), su caché en memoria.
8. **P:** ¿Qué servicio da caché en memoria (Redis/Memcached) gestionado?
   **R:** Amazon ElastiCache. Se usa para aliviar la base de datos y guardar sesiones.
9. **P:** Empareja: grafos · documentos (MongoDB) · series temporales · libro contable
   **R:** Neptune · DocumentDB · Timestream · QLDB.

### C. Analítica

10. **P:** ¿Qué es Amazon Redshift?
    **R:** Almacén de datos (data warehouse) para analítica sobre petabytes con SQL. Para informes, no para transacciones.
11. **P:** **Contraste:** Athena vs Redshift
    **R:** Athena = SQL **directamente sobre archivos en S3**, serverless, pagas por dato escaneado; ideal para consultas puntuales. Redshift = clúster de data warehouse para analítica continua e intensiva.
12. **P:** ¿Qué es AWS Glue?
    **R:** Servicio ETL serverless: descubre, cataloga y transforma datos. Su Data Catalog es el índice que usan Athena y Redshift Spectrum.
13. **P:** ¿Qué procesa datos en **streaming** en tiempo real?
    **R:** Amazon Kinesis (Data Streams, Firehose, Data Analytics). Alternativa gestionada de Kafka: Amazon MSK.
14. **P:** ¿Qué crea paneles e informes de negocio (BI)?
    **R:** Amazon QuickSight.
15. **P:** ¿Qué monta un data lake sobre S3 en días en lugar de meses?
    **R:** AWS Lake Formation.
16. **P:** ¿Qué migra bases de datos a AWS con mínima interrupción?
    **R:** AWS Database Migration Service (DMS). Si además cambias de motor, con Schema Conversion Tool (SCT).

## 4. Mazo

- [ ] Preguntas en Anki (mazo: `AWS CLF::08 Bases de datos`)

## 5. Feynman

> Una tienda online necesita: catálogo con búsquedas rápidas, pedidos transaccionales,
> carritos temporales y un informe mensual de ventas. Asigna un servicio a cada uno
> y justifica por qué no usarías el mismo para todo.

**Dónde me trabé:**

## 6. Simulacro

| Intento | Fecha | Nota | ¿Cerrado? |
|---------|-------|------|-----------|
| 1 | | / | |

## 7. Bitácora del módulo

| Fallo | Causa real | Acción |
|-------|-----------|--------|
| | | |
