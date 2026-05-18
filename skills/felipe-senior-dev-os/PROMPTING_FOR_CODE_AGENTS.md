# Prompting for Code Agents

## Principio

Prompt bom para agente de codigo define contexto, escopo, restricoes, validacao e formato de entrega. Prompt ruim pede "melhore tudo".

## Template base

```text
Contexto:
- Projeto:
- Stack observada:
- Objetivo:
- Arquivos ou areas suspeitas:

Tarefa:
- Faca:
- Nao faca:

Regras:
- Leia antes de alterar.
- Preserve comportamento existente.
- Nao toque em secrets.
- Mantenha escopo pequeno.

Validacao:
- Rode:
- Se nao puder rodar, explique.

Entrega:
- Arquivos alterados.
- Validacoes.
- Riscos.
- Como testar.
```

## Claude Code

Use quando:
- Precisa navegar repo, editar multiplos arquivos e rodar comandos.

Prompt:
```text
Use a skill felipe-senior-dev-os. Mapeie o fluxo antes de editar. Corrija a causa raiz de <bug>. Nao altere auth, deploy ou banco sem justificar. Rode validacao equivalente e entregue relatorio tecnico.
```

## Codex

Use quando:
- Precisa implementacao cuidadosa no workspace e validacao local.

Prompt:
```text
Atue como Principal Engineer. Leia o codigo, identifique stack real, proponha menor patch seguro, aplique e valide. Nao invente arquivos nem comandos. Relate riscos.
```

## Agente QA

```text
Atue como Sentinel. Valide a entrega com foco em regressao, edge cases, build, testes e smoke. Nao aprove se teste critico falhar. Liste evidencias.
```

## Agente de seguranca

```text
Atue como Aegis. Faca threat modeling e security review de auth, tenant isolation, secrets, logs e OWASP. Priorize achados exploraveis e recomende correcao.
```

## Agente frontend

```text
Atue como Helena. Preserve design system existente, melhore UX e responsividade, valide estados e nao crie layout decorativo sem funcao.
```

## Agente backend

```text
Atue como Atlas/Felipe. Revise contratos, services, repositories, transacoes, filas, idempotencia e observabilidade. Mantenha mudanca pequena.
```

## Agente DevOps

```text
Atue como Titan. Verifique deploy, systemd/Docker, logs, healthcheck, env vars e rollback. Nao altere producao sem plano de reversao.
```

## Bugfix

```text
Use felipe-senior-dev-os. Reproduza ou localize evidencia do bug, isole causa raiz, corrija com menor mudanca, adicione/rode teste de regressao e entregue relatorio.
```

## Feature

```text
Use felipe-senior-dev-os. Mapeie fluxo atual, identifique contratos e riscos, implemente a feature em blocos pequenos, preserve compatibilidade e valide.
```

## Refactor

```text
Use felipe-senior-dev-os. Refatore somente o escopo necessario, sem mudar comportamento. Antes/depois devem ser validados com testes ou smoke test.
```

## Security audit

```text
Use felipe-senior-dev-os e Aegis. Audite auth, autorizacao, tenant isolation, secrets, logs, input validation, rate limit e OWASP. Entregue achados por severidade.
```

## Deploy

```text
Use felipe-senior-dev-os e Titan. Revise build, env vars, migrations, healthcheck, readiness, rollback e logs. Nao declare sucesso sem smoke test.
```

## Code review

```text
Use felipe-senior-dev-os. Faca review com foco em bugs, regressao, seguranca, performance, testes, observabilidade e manutencao. Liste findings por severidade.
```

## Arquitetura

```text
Use felipe-senior-dev-os. Compare opcoes, tradeoffs, custo operacional, evolucao e rollback. Prefira monolito modular ate microservice ser justificado.
```
