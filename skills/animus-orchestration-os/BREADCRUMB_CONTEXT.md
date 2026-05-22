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

Animus informa a todos:
- Usar `felipe-senior-dev-os` e `felipe-saas-os`.
- Referencia primaria: `C:\Users\computador\Documents\JOGOS\NEW ADMIN`.
- Referencia secundaria visual: `C:\Users\computador\Documents\LuminaFrontend-main`.
- Referencia secundaria backend: `C:\Users\computador\Documents\Lumina\LuminaBank`.
- SaaS nao e landing page; primeira tela deve ser produto operacional.

Felipe recebe:
- padrao tecnico.
- stack preferida.
- limites de producao.
- criterios de aceite.
- riscos de seguranca, banco, deploy e multi-tenant.

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
- tokens visuais do `felipe-saas-os`.
- obrigacao de seguir NEW ADMIN/Lumina: dark-first, Gantari, lime, cards, graficos e dashboard denso.

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
