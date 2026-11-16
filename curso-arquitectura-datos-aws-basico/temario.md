# Temario — Arquitectura de Datos en AWS con Terraform y Docker

> Cada tema es un ejercicio práctico con Terraform. Todo corre en Docker: LocalStack simula AWS y el contenedor `herramientas` trae Terraform, la AWS CLI y Python.
>
> El avance de cada persona está en `alumnos/<nombre>/PROGRESO.md`.

---

## Tema 0 — Preparación del entorno → [desarrollo](temas/tema-00-preparacion-entorno.md)
- 0.1 Por qué todo dentro de Docker
- 0.2 Qué es LocalStack y sus limitaciones
- 0.3 El `Dockerfile` de herramientas y el `docker-compose.yml`
- 0.4 Levantar el entorno
- 0.5 Entrar al contenedor y comprobar que habla con LocalStack
- 0.6 El archivo `providers.tf` base

## Tema 1 — Fundamentos de arquitectura de datos + primer recurso → [desarrollo](temas/tema-01-fundamentos.md)
- 1.1 Tipos de datos: estructurados, semiestructurados y no estructurados
- 1.2 OLTP vs. OLAP
- 1.3 Batch vs. streaming
- 1.4 ETL vs. ELT
- 1.5 Data lake, data warehouse y lakehouse
- 1.6 Arquitectura por zonas (raw, processed, curated)
- 1.7 Ejercicio: tu primer bucket S3

## Tema 2 — Terraform esencial → [desarrollo](temas/tema-02-terraform-esencial.md)
- 2.1 Providers, resources y data sources
- 2.2 Variables, locals y outputs
- 2.3 `count` y `for_each`
- 2.4 El estado (`terraform.tfstate`)
- 2.5 Ciclo de comandos: init, plan, apply, destroy
- 2.6 Ejercicio: buckets parametrizados y detección de cambios

## Tema 3 — Data lake en S3
- 3.1 Zonas del lago
- 3.2 Versionado
- 3.3 Cifrado
- 3.4 Bloqueo de acceso público
- 3.5 Ciclo de vida
- 3.6 Particionado estilo Hive
- 3.7 Formatos: CSV, JSON y Parquet
- 3.8 Ejercicio: data lake completo con datos de ejemplo

## Tema 4 — Seguridad con IAM
- 4.1 Usuarios, grupos, roles y políticas
- 4.2 Trust policy vs. permission policy
- 4.3 Mínimo privilegio
- 4.4 Escribir políticas con `aws_iam_policy_document`
- 4.5 Ejercicio: rol para una Lambda de ETL y grupo de analistas

## Tema 5 — Ingesta batch con Lambda y eventos de S3
- 5.1 Qué es AWS Lambda
- 5.2 Notificaciones de S3
- 5.3 Permisos de invocación
- 5.4 Empaquetar código con `archive`
- 5.5 Calidad de datos: validar y separar filas rechazadas
- 5.6 Cómo evitar bucles infinitos
- 5.7 Ejercicio: validar CSV que llegan a raw

## Tema 6 — Mensajería con SNS y SQS
- 6.1 Colas (SQS) vs. tópicos (SNS)
- 6.2 Patrón fan-out
- 6.3 Reintentos y cola de errores (DLQ)
- 6.4 Lambda leyendo de SQS
- 6.5 Idempotencia
- 6.6 Ejercicio: pedidos repartidos a facturación y analítica

## Tema 7 — Streaming con Kinesis y Firehose
- 7.1 Kinesis Data Streams: shards y partition key
- 7.2 Consumir el stream con Lambda
- 7.3 Firehose: llevar el stream a S3
- 7.4 Cuándo usar cada uno
- 7.5 Ejercicio: clickstream de una tienda

## Tema 8 — Bases NoSQL con DynamoDB
- 8.1 Clave de partición y clave de ordenación
- 8.2 Modelar según los patrones de acceso
- 8.3 Índices secundarios (GSI)
- 8.4 TTL
- 8.5 DynamoDB Streams y captura de cambios (CDC)
- 8.6 Ejercicio: tabla de pedidos con CDC hacia S3

## Tema 9 — Orquestación con Step Functions y EventBridge
- 9.1 Máquinas de estado y tipos de estados
- 9.2 Reintentos y manejo de errores
- 9.3 Integraciones directas sin Lambda
- 9.4 EventBridge: ejecuciones programadas
- 9.5 Ejercicio: pipeline diario orquestado

## Tema 10 — Secretos y configuración
- 10.1 Secrets Manager
- 10.2 SSM Parameter Store
- 10.3 KMS: claves de cifrado
- 10.4 Por qué hay que proteger el estado de Terraform
- 10.5 Ejercicio: credenciales del data warehouse

## Tema 11 — Observabilidad con CloudWatch
- 11.1 Logs y retención
- 11.2 Métricas nativas y personalizadas
- 11.3 Filtros de métricas sobre logs
- 11.4 Alarmas y notificaciones
- 11.5 Ejercicio: alarmas sobre la Lambda de validación

## Tema 12 — Procesamiento con Spark (Glue simulado)
- 12.1 Qué es AWS Glue
- 12.2 Spark y DataFrames
- 12.3 Parquet y particionado al escribir
- 12.4 Leer y escribir S3 desde Spark
- 12.5 Ejercicio: de processed a curated en Parquet

## Tema 13 — Consultas SQL sobre el lago (Athena simulado)
- 13.1 Qué es Athena y el Glue Data Catalog
- 13.2 Cómo bajar costos con particiones y Parquet
- 13.3 DuckDB como sustituto local
- 13.4 Ejercicio: consultas sobre los Parquet de S3

## Tema 14 — Data warehouse (Redshift simulado)
- 14.1 Modelo dimensional: hechos y dimensiones
- 14.2 Capas staging y analytics
- 14.3 Carga desde S3
- 14.4 Roles de acceso para analistas
- 14.5 Ejercicio: modelo estrella en PostgreSQL administrado con Terraform

## Tema 15 — Terraform avanzado
- 15.1 Módulos reutilizables
- 15.2 Estado remoto en S3 con bloqueo
- 15.3 Entornos dev y prod
- 15.4 Importar y mover recursos (`import`, `moved`)
- 15.5 Ejercicio: reorganizar el código en módulos y entornos

## Tema 16 — Proyecto final
- 16.1 Enunciado y arquitectura
- 16.2 Hitos y criterios de aceptación
- 16.3 Extensiones opcionales

## Apéndices
- A. Equivalencias AWS real vs. entorno local
- B. Solución de problemas
- C. Glosario
