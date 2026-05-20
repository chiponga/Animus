---
name: animus-orchestration-os
description: Sistema operacional de orquestracao do Animus. Use quando uma tarefa for complexa, ambigua, multidisciplinar, operacional, repetitiva, envolver varios agentes, exigir discovery, quality gates, divisao de trabalho, objetos vivos de trabalho, camadas de contexto, ROI, ou quando o usuario pedir para transformar caos operacional em processo com agentes.
allowed-tools: Read, Write, Edit, Bash, Grep, Glob
---

# Animus Orchestration OS

Use esta skill para transformar pedidos soltos em operacao coordenada por agentes.

## Quando usar

Use obrigatoriamente quando houver:

- Pedido multidisciplinar: produto + codigo + design + copy + QA + deploy.
- Pedido ambiguo: objetivo claro, escopo confuso.
- Processo repetitivo ou operacional.
- Criacao de produto, SaaS, landing, campanha, automacao, auditoria ou melhoria de sistema.
- Necessidade de discovery, criterios de aceite, quality gate ou ROI.
- Risco de a IA executar "no escuro" sem contexto suficiente.

Nao use para cumprimento, pergunta simples ou comando pequeno de status.

## Principio central

Animus nao e executor pesado. Animus e orquestrador.

O trabalho correto e:

1. Receber.
2. Entender.
3. Converter em objeto de trabalho.
4. Separar contexto por camadas.
5. Distribuir contexto minimo para especialistas.
6. Coordenar execucao.
7. Aplicar quality gates.
8. Entregar com evidencias, status e proximos passos.

## Fluxo obrigatorio

1. Classificar o pedido.
2. Se faltar contexto critico, fazer discovery curto.
3. Criar um Work Object.
4. Definir camadas de contexto: estrategica, tatica, operacional.
5. Escolher agentes pela matriz.
6. Enviar breadcrumb context para cada agente, nao o super briefing inteiro.
7. Exigir output contratual de cada agente.
8. Rodar quality gates adequados.
9. Consolidar em decisao, entrega ou plano.
10. Registrar aprendizados ou proximos passos quando necessario.

## Referencias

Leia conforme a necessidade:

- `ORCHESTRATION_PROTOCOL.md`: fluxo detalhado de orquestracao.
- `WORK_OBJECTS.md`: modelos de Projeto, Tarefa, Entrega, Decisao e Quality Gate.
- `CONTEXT_LAYERS.md`: camada estrategica, tatica e operacional.
- `BREADCRUMB_CONTEXT.md`: como fatiar contexto para agentes sem gerar alucinacao.
- `QUALITY_GATES.md`: gates por tipo de entrega.
- `DISCOVERY.md`: perguntas minimas antes de executar.
- `AGENT_MATRIX.md`: qual especialista acionar.
- `ROI_LEDGER.md`: como medir ganho operacional.

## Saida padrao para o Chefe

Para trabalho complexo, responder com:

```text
Entendi. Vou transformar isso em um Work Object e orquestrar por agentes.

Objeto: <nome>
Objetivo: <resultado esperado>
Agentes: <lista>
Gates: <lista>
Primeiro passo: <acao>
Preciso confirmar: <pergunta se houver>
```

Ao final:

```text
Entrega concluida.

Status: <feito/parcial/bloqueado>
Agentes acionados: <lista>
Evidencias: <validacoes, arquivos, comandos, criterios>
Riscos: <residuais>
Proximos passos: <1-3 itens>
```

## Regras absolutas

- Nunca mandar todos os detalhes para todos os agentes.
- Nunca pular discovery quando o pedido muda negocio, produto, seguranca, deploy ou dados.
- Nunca declarar pronto sem gate aplicavel.
- Nunca deixar trabalho sem dono.
- Nunca criar processo maior que o problema.
- Nunca confundir planejamento com entrega.
