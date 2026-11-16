# Módulo 09 — Integración, IA/ML y herramientas de desarrollo

**Dominio 3 (34%)** · **Horas:** 3 · **Estado:** ⬜

> Módulo de reconocimiento: no necesitas dominar estos servicios, necesitas
> **saber para qué sirve cada nombre**. Tarjetas cortas, muchas.

## 1. Saber hacer

- [ ] Explicar cómo SQS y SNS desacoplan una aplicación, y en qué se diferencian
- [ ] Emparejar cada servicio de IA con su tarea (imagen, voz, texto, traducción...)
- [ ] Nombrar la cadena de despliegue de AWS (Code*)

## 2. Fuente

**Principal:** AWS Cloud Practitioner Essentials — Módulo 6 + hoja de servicios
Truco: estudia este módulo **solo con tarjetas de emparejar** servicio ↔ función.

## 3. Preguntas

### A. Integración de aplicaciones

1. **P:** **Contraste:** SQS vs SNS
   **R:** SQS = **cola**: un mensaje, un consumidor que lo procesa cuando puede. SNS = **pub/sub**: un mensaje se envía a muchos suscriptores a la vez.
2. **P:** ¿Por qué desacoplar con colas?
   **R:** Si el consumidor cae o se satura, los mensajes esperan en la cola en lugar de perderse. El fallo no se propaga.
3. **P:** ¿Qué orquesta flujos de trabajo con pasos y estados visuales?
   **R:** AWS Step Functions.
4. **P:** ¿Qué enruta eventos entre servicios AWS y apps SaaS?
   **R:** Amazon EventBridge.
5. **P:** ¿Qué crea, publica y protege APIs REST/WebSocket?
   **R:** Amazon API Gateway.

### B. IA y machine learning

6. **P:** ¿Qué hace Amazon SageMaker?
   **R:** Plataforma completa para construir, entrenar y desplegar modelos de ML propios.
7. **P:** Empareja: imágenes y vídeo · texto a voz · voz a texto · traducción
   **R:** Rekognition · Polly · Transcribe · Translate.
8. **P:** Empareja: análisis de texto/sentimiento · extraer texto de documentos escaneados · chatbots
   **R:** Comprehend · Textract · Lex.
9. **P:** ¿Qué da búsqueda inteligente en documentos internos?
   **R:** Amazon Kendra.
10. **P:** ¿Qué da recomendaciones personalizadas y qué detecta fraude?
    **R:** Amazon Personalize · Amazon Fraud Detector.
11. **P:** ¿Qué da acceso a modelos fundacionales de IA generativa?
    **R:** Amazon Bedrock. El asistente de IA para trabajo y desarrollo es Amazon Q.

### C. Herramientas de desarrollo

12. **P:** La cadena Code*: ¿qué hace cada uno?
    **R:** CodeCommit = repositorio Git · CodeBuild = compila y prueba · CodeDeploy = despliega · CodePipeline = orquesta todo el CI/CD.
13. **P:** ¿Qué depura y traza peticiones entre microservicios?
    **R:** AWS X-Ray.
14. **P:** ¿Qué despliega apps web y móviles full-stack rápidamente?
    **R:** AWS Amplify.

### D. Usuario final

15. **P:** **Contraste:** WorkSpaces vs AppStream 2.0
    **R:** WorkSpaces = escritorio virtual completo en la nube. AppStream = transmite **una aplicación** concreta, sin escritorio.
16. **P:** ¿Qué es Amazon Connect?
    **R:** Centro de contacto (call center) en la nube.

## 4. Mazo

- [ ] Preguntas en Anki (mazo: `AWS CLF::09 Integración e IA`)

## 5. Feynman

> Sin mirar, escribe la lista de servicios de IA de AWS y al lado, en 3 palabras,
> qué hace cada uno. Luego compara con la fuente y marca los que fallaste.

**Dónde me trabé:**

## 6. Simulacro

| Intento | Fecha | Nota | ¿Cerrado? |
|---------|-------|------|-----------|
| 1 | | / | |

## 7. Bitácora del módulo

| Fallo | Causa real | Acción |
|-------|-----------|--------|
| | | |
