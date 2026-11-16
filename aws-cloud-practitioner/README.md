# AWS Certified Cloud Practitioner (CLF-C02)

Plan de estudio construido con el [motor de estudio](../_plantilla/README.md).

## El examen

| Dato | Valor |
|------|-------|
| Código | CLF-C02 |
| Preguntas | 65 (50 puntúan, 15 son de prueba) |
| Tiempo | 90 min |
| Puntaje | 100–1000 · **corte: 700** |
| Tipo | Opción múltiple y respuesta múltiple |
| Costo | ~100 USD |
| Idioma | Disponible en español |
| Modalidad | Centro de examen u online desde casa |

**Dominios y peso:**

| Dominio | Peso | Módulos |
|---------|------|---------|
| 1. Conceptos de nube | 24% | 01, 02 |
| 2. Seguridad y cumplimiento | 30% | 03, 04 |
| 3. Tecnología y servicios | 34% | 05–10 |
| 4. Facturación, precios y soporte | 12% | 11 |

Ojo: seguridad pesa 30%. Es el dominio que más gente subestima.

## Calendario — 8 semanas, 1 h/día, 6 días/semana

Ajusta a tu ritmo real: si tienes 30 min/día, son 16 semanas. El orden no cambia.

| Semana | Módulos | Hitos |
|--------|---------|-------|
| 1 | 01, 02 | Cuenta AWS creada · Anki arrancado |
| 2 | 03, 04 | Simulacro dominio 2 |
| 3 | 05, 06 | Primera EC2 y primer bucket S3 a mano |
| 4 | 07 | Diagrama de una VPC dibujado por ti |
| 5 | 08, 09 | Simulacro dominio 3 (parcial) |
| 6 | 10, 11 | Simulacro dominio 3 y 4 |
| 7 | — | 2 simulacros completos + bitácora |
| 8 | — | Repaso solo de bitácora + 1 simulacro · **agendar examen** |

**No agendes el examen hasta tener 2 simulacros completos ≥ 800.**

## Fuente principal (elige UNA)

- **AWS Skill Builder** — "AWS Cloud Practitioner Essentials", gratis, oficial.
- Curso de Stephane Maarek o Andrew Brown (freeCodeCamp) si prefieres vídeo largo.
- Guía oficial del examen (PDF) — obligatoria de leer, sea cual sea tu fuente.

**Simulacros:** el oficial de Skill Builder (gratis) + Tutorials Dojo (de pago, el
más parecido al real).

## Estado

| # | Módulo | Horas | Estado |
|---|--------|-------|--------|
| 01 | [Fundamentos de la nube](modulos/01-fundamentos-nube.md) | 3 | ⬜ |
| 02 | [Infraestructura global y Well-Architected](modulos/02-infraestructura-well-architected.md) | 3 | ⬜ |
| 03 | [IAM e identidad](modulos/03-iam-identidad.md) | 4 | ⬜ |
| 04 | [Seguridad y cumplimiento](modulos/04-seguridad-cumplimiento.md) | 5 | ⬜ |
| 05 | [Cómputo](modulos/05-computo.md) | 5 | ⬜ |
| 06 | [Almacenamiento](modulos/06-almacenamiento.md) | 4 | ⬜ |
| 07 | [Redes y entrega de contenido](modulos/07-redes.md) | 5 | ⬜ |
| 08 | [Bases de datos y analítica](modulos/08-bases-datos-analitica.md) | 4 | ⬜ |
| 09 | [Integración, IA/ML y otros](modulos/09-integracion-ia.md) | 3 | ⬜ |
| 10 | [Monitoreo, gobierno y migración](modulos/10-monitoreo-gobierno.md) | 4 | ⬜ |
| 11 | [Facturación, precios y soporte](modulos/11-facturacion-soporte.md) | 4 | ⬜ |

⬜ pendiente · 🟡 en curso · ✅ cerrado (simulacro ≥80%)

## Archivos vivos

- [`bitacora.md`](bitacora.md) — tus fallos y por qué. **Ábrelo cada día.**
- [`simulacros.md`](simulacros.md) — resultados
- [`anki/`](anki/README.md) — cómo montar el mazo

## Regla de oro de este examen

CLF-C02 pregunta **"¿qué servicio uso para esto?"**, no "¿cómo se configura?".
Estudia para *distinguir servicios parecidos*, no para memorizar pantallas.
Por eso casi todas las tarjetas útiles son de contraste: EBS vs EFS vs S3,
Security Group vs NACL, CloudWatch vs CloudTrail.
