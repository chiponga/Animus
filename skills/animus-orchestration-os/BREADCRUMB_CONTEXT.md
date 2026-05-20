# Breadcrumb Context

Breadcrumb Context e a tecnica de enviar contexto em fatias pequenas, direcionadas e verificaveis.

## Por que usar

Erros de IA geralmente sao falhas de distribuicao de contexto:
- contexto demais.
- contexto errado.
- contexto sem criterio de aceite.
- contexto sem restricao.

## Formato

```text
Contexto para <agente>:
Objetivo global:
Sua responsabilidade:
Insumos que importam:
Restricoes:
Nao fazer:
Output esperado:
Como sera validado:
```

## Exemplo: criar SaaS

Atlas recebe:
- stack.
- entidades.
- API.
- restricoes tecnicas.
- criterio de aceite tecnico.

Helena recebe:
- publico.
- fluxo de usuario.
- design system.
- telas esperadas.

Victor recebe:
- ICP.
- promessa.
- oferta.
- tom.

Sentinel recebe:
- criterios de aceite.
- riscos.
- comandos/testes esperados.

Titan recebe:
- ambiente.
- deploy target.
- env vars.
- rollback.

## Regras

- Uma fatia por agente.
- Output esperado sempre explicito.
- Se o agente precisar de mais contexto, ele deve pedir.
- Animus consolida, nao terceiriza a decisao final.
