# Mazo de Anki — AWS CLF-C02

## Montarlo (10 minutos, una sola vez)

1. Instala **Anki** (escritorio, gratis) desde apps.ankiweb.net. La app de Android
   es gratis; la de iPhone es de pago.
2. Crea el mazo padre `AWS CLF` y submazos `AWS CLF::01 Fundamentos`, etc.
3. Importa `mazo-base.csv`: *Archivo → Importar*, separador **punto y coma**,
   tipo de nota **Básico**, campo 1 = Anverso, campo 2 = Reverso, campo 3 = mazo/etiqueta.
4. Ajustes del mazo: **20 tarjetas nuevas/día**, 200 repasos máximo.

## Cómo escribir buenas tarjetas

| Mala | Buena |
|------|-------|
| "Explica S3" | "¿Qué clase de S3 usarías para datos con acceso impredecible?" |
| "Tipos de ELB" | "¿ALB o NLB para tráfico TCP de altísimo rendimiento?" |
| Tarjeta con 6 puntos | 6 tarjetas de un punto cada una |

Reglas:
- **Una idea por tarjeta.** Si la respuesta tiene más de 2 líneas, pártela.
- **Tarjetas de contraste en los dos sentidos**: "SG vs NACL: ¿cuál es stateless?"
  y también "¿Qué es stateless, SG o NACL?".
- **Escenario, no definición.** El examen pregunta por escenarios.
- Si fallas una tarjeta 3 veces, está mal escrita. Reescríbela, no la repitas.

## Rutina diaria

Anki **primero**, antes de estudiar material nuevo. 10 minutos. Todos los días,
incluidos los que no estudias nada más. La racha vale más que la sesión larga.

## Etiquetas útiles

- `contraste` — los 12 pares del mapa. Repásalos aparte antes de cada simulacro.
- `fallo-simulacro` — nacidas de un error real. Son las más valiosas.
- `dominio-2` — para repasar por peso del examen.
