# Orchestration Protocol

## Objetivo

Converter caos em fluxo de trabalho rastreavel.

## Estados

| Estado | Significado | Saida esperada |
|---|---|---|
| Intake | Pedido recebido | resumo do pedido |
| Discovery | faltam dados criticos | perguntas minimas |
| Framing | trabalho definido | Work Object |
| Routing | agentes escolhidos | matriz de delegacao |
| Execution | especialistas trabalhando | entregas parciais |
| Quality Gate | validacao | aprovado, ajustes ou bloqueado |
| Delivery | consolidacao | resposta final |
| Learning | melhoria do sistema | registro em `.learnings` se aplicavel |

## Algoritmo

1. Identifique se o pedido e simples, especializado ou multidisciplinar.
2. Se simples, responda direto ou delegue um especialista.
3. Se especializado, crie Work Object leve e envie para o agente certo.
4. Se multidisciplinar, crie Work Object completo.
5. Defina quais gates sao obrigatorios.
6. Entregue contexto em migalhas:
   - cada agente recebe objetivo, escopo, restricoes, insumos e output esperado.
   - cada agente recebe apenas o contexto que precisa.
7. Consolide outputs.
8. Se houver conflito entre agentes, Animus decide ou pede decisao ao Chefe.

## Modos de operacao

### Modo Discovery

Use quando o objetivo e incerto.

Saida:
- problema declarado.
- impacto esperado.
- contexto faltante.
- perguntas minimas.

### Modo Sprint

Use quando a execucao e clara.

Saida:
- plano curto.
- agentes.
- gates.
- entrega.

### Modo Auditoria

Use quando a tarefa e avaliar algo.

Saida:
- achados por severidade.
- evidencias.
- recomendacoes.
- riscos.

### Modo Fabrica

Use quando a tarefa e repetitiva.

Saida:
- template.
- pipeline.
- checkpoints.
- metricas.

## Criterio de parada

Pare e pergunte quando:
- o objetivo de negocio esta indefinido.
- ha risco de apagar dados, alterar producao, gastar dinheiro ou expor segredo.
- dois agentes chegam a conclusoes incompatíveis.
- nao ha evidencia suficiente para aprovar.
