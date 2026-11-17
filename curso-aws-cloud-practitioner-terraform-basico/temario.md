# Temario — AWS Cloud Practitioner práctico con Terraform

> Curso práctico para quien ya estudió la teoría de Cloud Practitioner (CLF-C02) y quiere tocar AWS de verdad. Se trabaja en una **cuenta real de AWS** con Terraform, desde un contenedor Docker que trae todas las herramientas.
>
> El avance de cada persona está en `alumnos/<nombre>/PROGRESO.md`.

## Reglas del curso

1. **Teoría breve y puntual.** Lo justo para entender qué vas a crear. El resto es práctica.
2. **Siempre a la consola.** Cada tema tiene un *recorrido por la consola*: después del `terraform apply`, entras a AWS a ver lo que se creó, sus pestañas y sus botones.
3. **Siempre `terraform destroy` al terminar.** Y después compruebas en la consola que no quedó nada. Única excepción: la alarma de precios del Tema 3, que vive todo el curso.
4. **⚠️ = cuesta dinero.** Ese recurso cobra aunque no lo uses. Se crea, se mira y se destruye el mismo día.

---

## Tema 0 — Preparar el entorno → [desarrollo](temas/tema-00-preparar-entorno.md)
- 0.1 Por qué todo dentro de Docker
- 0.2 El contenedor `herramientas`: Terraform y AWS CLI
- 0.3 El `Dockerfile` y el `docker-compose.yml`
- 0.4 Levantar el entorno y entrar al contenedor
- 0.5 Comprobar versiones (`terraform version`, `aws --version`)

## Tema 1 — Tu cuenta de AWS y primeros pasos en la consola
- 1.1 Crear la cuenta de AWS
- 1.2 Plan gratuito vs. plan de pago, y los créditos de cuenta nueva
- 1.3 El usuario root: qué es y por qué no se usa en el día a día
- 1.4 Activar MFA en el root
- 1.5 Crear un usuario IAM administrador con MFA
- 1.6 Access keys: para qué sirven y sus riesgos (nunca a git)
- 1.7 Recorrido por la consola: buscador, selector de región, CloudShell, Billing
- 1.8 Activar las alertas de uso del Free Tier
- 1.9 Ejercicio: configurar la AWS CLI en el contenedor y probar `aws sts get-caller-identity`

## Tema 2 — Terraform desde cero
- 2.1 Qué es Infraestructura como Código y por qué importa
- 2.2 El lenguaje HCL: bloques, argumentos y tipos
- 2.3 Providers y resources
- 2.4 El ciclo: `init`, `plan`, `apply`, `destroy`
- 2.5 El estado (`terraform.tfstate`) y por qué no se sube a git
- 2.6 Variables, outputs y locals
- 2.7 Data sources
- 2.8 `count` y `for_each`
- 2.9 `terraform fmt` y `terraform validate`
- 2.10 Ejercicio: crear archivos con los providers `local` y `random` (sin tocar AWS, costo cero)

## Tema 3 — Alarma de precios: tu red de seguridad
- 3.1 Cómo cobra AWS: pago por uso y Free Tier
- 3.2 Recorrido por la consola: Billing, Cost Explorer y uso del Free Tier
- 3.3 AWS Budgets vs. alarma de facturación de CloudWatch
- 3.4 SNS y la suscripción por email
- 3.5 El provider `aws`: región y credenciales
- 3.6 Ejercicio: presupuesto mensual con aviso por gasto real y por gasto previsto
- 3.7 Recorrido por la consola: ver el presupuesto y confirmar el email
- 3.8 Por qué este recurso **no** se destruye

## Tema 4 — Identidad y acceso con IAM
- 4.1 Modelo de responsabilidad compartida
- 4.2 Usuarios, grupos, roles y políticas
- 4.3 Principio de mínimo privilegio
- 4.4 Ejercicio: grupo de solo lectura, usuario de prueba y un rol
- 4.5 Recorrido por la consola: IAM, simulador de políticas y Access Analyzer
- 4.6 Limpieza: `terraform destroy` y verificar en IAM

## Tema 5 — Almacenamiento con S3
- 5.1 Buckets y objetos
- 5.2 Clases de almacenamiento (Standard, IA, Glacier)
- 5.3 Versionado
- 5.4 Bloqueo de acceso público
- 5.5 Cifrado
- 5.6 Reglas de ciclo de vida
- 5.7 Otros almacenamientos en 1 minuto: EBS, EFS, Instance Store
- 5.8 Ejercicio: bucket con versionado, cifrado y ciclo de vida
- 5.9 Recorrido por la consola: subir archivos, ver versiones y propiedades
- 5.10 Limpieza: vaciar el bucket, `terraform destroy` y verificar

## Tema 6 — Infraestructura global y redes (VPC)
- 6.1 Regiones, zonas de disponibilidad y edge locations
- 6.2 VPC y subnets públicas y privadas
- 6.3 Internet Gateway y tablas de rutas
- 6.4 Security Group vs. Network ACL
- 6.5 ⚠️ NAT Gateway: qué es y por qué no lo crearemos
- 6.6 Ejercicio: VPC con una subnet pública y una privada en dos AZ
- 6.7 Recorrido por la consola: el mapa de recursos de la VPC
- 6.8 Limpieza: `terraform destroy` y verificar

## Tema 7 — Cómputo con EC2
- 7.1 AMI y tipos de instancia
- 7.2 User data: configurar la máquina al arrancar
- 7.3 Volúmenes EBS
- 7.4 Modelos de compra: On-Demand, Spot, Reserved y Savings Plans
- 7.5 ⚠️ Lo que cobra aunque apagues la instancia: Elastic IP y EBS huérfanos
- 7.6 Ejercicio: servidor web en una instancia pequeña dentro de tu VPC
- 7.7 Recorrido por la consola: conectarte con EC2 Instance Connect, ver el volumen y el Security Group
- 7.8 Limpieza: `terraform destroy` y verificar que no quedaron volúmenes ni IPs

## Tema 8 — Alta disponibilidad y escalado
- 8.1 Elasticidad, escalabilidad y alta disponibilidad
- 8.2 ⚠️ Elastic Load Balancing (ALB): cobra por hora
- 8.3 Auto Scaling Groups
- 8.4 Ejercicio corto: dos instancias detrás de un ALB
- 8.5 Recorrido por la consola: target groups, health checks y ver instancias entrar y salir
- 8.6 Limpieza: `terraform destroy` en el mismo día

## Tema 9 — Bases de datos
- 9.1 Relacional vs. NoSQL
- 9.2 RDS, Aurora, DynamoDB, Redshift, ElastiCache: cuándo cada una
- 9.3 ⚠️ RDS y los límites del Free Tier
- 9.4 Ejercicio: tabla DynamoDB en modo on-demand con datos de ejemplo
- 9.5 Ejercicio opcional: RDS pequeño (crear, mirar, destruir)
- 9.6 Recorrido por la consola: explorar ítems y ver métricas
- 9.7 Limpieza: `terraform destroy` y verificar (incluye snapshots)

## Tema 10 — Serverless e integración
- 10.1 AWS Lambda: código sin servidores
- 10.2 SNS vs. SQS
- 10.3 EventBridge
- 10.4 Ejercicio: Lambda que se dispara al subir un archivo a S3
- 10.5 Recorrido por la consola: probar la Lambda y leer sus logs
- 10.6 Limpieza: `terraform destroy` y verificar

## Tema 11 — Monitoreo y auditoría
- 11.1 CloudWatch: métricas, logs y alarmas
- 11.2 CloudTrail: quién hizo qué y cuándo
- 11.3 ⚠️ AWS Config
- 11.4 Trusted Advisor
- 11.5 Ejercicio: alarma de CloudWatch que avisa por email
- 11.6 Recorrido por la consola: buscar en CloudTrail tus propios `terraform apply`
- 11.7 Limpieza: `terraform destroy` y verificar

## Tema 12 — Seguridad y cumplimiento
- 12.1 Cifrado con KMS
- 12.2 ⚠️ Secrets Manager vs. Parameter Store
- 12.3 Shield, WAF, GuardDuty e Inspector (solo teoría)
- 12.4 AWS Artifact y cumplimiento
- 12.5 Ejercicio: bucket cifrado con una llave KMS propia y un parámetro en Parameter Store
- 12.6 Recorrido por la consola: la llave KMS y AWS Artifact
- 12.7 Limpieza: `terraform destroy` y el periodo de espera de KMS

## Tema 13 — DNS y entrega de contenido
- 13.1 ⚠️ Route 53: zonas hospedadas y registros
- 13.2 CloudFront y las edge locations
- 13.3 Ejercicio: web estática en S3 servida por CloudFront
- 13.4 Recorrido por la consola: la distribución, sus orígenes y la caché
- 13.5 Limpieza: `terraform destroy` y verificar

## Tema 14 — Proyecto final y cierre
- 14.1 AWS Well-Architected: los 6 pilares
- 14.2 AWS Pricing Calculator: estimar antes de crear
- 14.3 Planes de soporte
- 14.4 Proyecto integrador: armar una pequeña arquitectura con lo aprendido
- 14.5 Limpieza total: Tag Editor, Cost Explorer y revisar región por región
- 14.6 Qué hacer con la alarma de precios: dejarla o destruirla
- 14.7 Cómo cerrar la cuenta (si ya no la vas a usar)
