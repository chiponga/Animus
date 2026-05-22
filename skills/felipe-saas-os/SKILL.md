---
name: felipe-saas-os
description: "Padrao operacional para criar SaaS, dashboards, CRMs e admin panels no estilo tecnico/visual do Felipe. Use quando o usuario pedir criar SaaS, painel, dashboard, CRM, admin, backoffice, produto web operacional ou quando mencionar Lumina, NEW ADMIN, padrao visual do Felipe, cards, graficos, layout ou stack preferida."
---

# felipe-saas-os

Esta skill transforma os projetos de referencia do Felipe em um contrato operacional para agentes criarem SaaS reais sem improvisar visual, stack ou arquitetura.

## Fontes de verdade

Use estes projetos como referencia, nesta ordem:

1. `C:\Users\computador\Documents\JOGOS\NEW ADMIN`
   - Fonte principal para app SaaS/admin moderno.
   - Referencia de stack Bun + Elysia + React + Vite + TypeScript + Drizzle + MySQL.
   - Referencia principal de layout, sidebar, dashboard, cards, tabelas, graficos, tokens e responsividade.
2. `C:\Users\computador\Documents\LuminaFrontend-main`
   - Fonte secundaria de identidade visual Lumina premium.
   - Referencia de atmosfera dark, glass/premium, amarelo/lime, dashboards e motion.
3. `C:\Users\computador\Documents\Lumina\LuminaBank`
   - Fonte secundaria para backend operacional.
   - Referencia de Bun/Elysia, MySQL pool, Redis, filas, Socket.io, gateways, seguranca, webhooks e deploy real.

Nao copie codigo desses projetos sem necessidade. Extraia padroes, tokens, composicao visual e decisoes arquiteturais.

## Quando usar

Use obrigatoriamente quando o pedido envolver:

- "criar SaaS".
- "criar painel".
- "admin panel".
- "dashboard".
- "CRM".
- "backoffice".
- "sistema web".
- "produto operacional".
- "usar meu padrao".
- "igual Lumina".
- "igual NEW ADMIN".
- "mesmas cores/cards/graficos".
- "template SaaS".

Use junto com:

- `felipe-senior-dev-os` para engenharia, arquitetura, seguranca, banco, deploy e validacao.
- `animus-growth-os-agent-api` quando o SaaS criado for o Animus Growth OS ou quando o pedido envolver operar rotas, tokens, webhooks, CRM, Inbox, WhatsApp, Instagram, automacoes, campanhas, jobs ou analytics desse sistema.
- `gradsky-paas` quando houver deploy real Gradsky.
- Helena para UX/design.
- Atlas para codigo.
- Sentinel para QA.
- Titan para deploy/infra.

## Quando nao usar

Nao use como base principal quando:

- O pedido for apenas landing page, pagina de vendas ou captura. Nesse caso use `gerar-landing-page`.
- O pedido for blog, site institucional simples ou proposta comercial.
- O usuario pedir explicitamente outro design system.
- O projeto existente ja tiver design system proprio e a tarefa for apenas ajuste local.

## Regra absoluta

SaaS nao e landing page.

Quando o usuario pedir "criar SaaS", a primeira tela deve ser uma experiencia de produto utilizavel: app shell, sidebar, topbar, dashboard, tabela, filtros, estados e dados. Nao criar hero marketing como primeira tela.

## Resultado esperado

Todo SaaS criado no padrao Felipe deve ter:

- Stack coerente com Bun/Elysia/TypeScript/React/Vite/Tailwind/Drizzle/MySQL, salvo restricao real.
- App shell operacional com sidebar fixa no desktop e navegacao mobile.
- Dashboard denso, escaneavel, com KPIs, graficos, tabelas e filtros.
- Visual dark premium com acento lime `#AFFF00`.
- Componentes reutilizaveis: Card, Button, KpiCard, Table, RingKpi, LineChartSmooth, Badge/Pill, Layout.
- Estados reais: loading, empty, error, success, disabled, hover, active, mobile.
- Separacao clara entre frontend, backend, banco, services e validacoes.
- Sem dados sensiveis em logs, sem secrets hardcoded e sem placeholders enganosos.

## Fluxo obrigatorio

1. Entender o tipo de SaaS, publico, entidade central e workflow principal.
2. Mapear se existe repo atual ou se e projeto novo.
3. Identificar stack real. Se for novo, preferir o stack Felipe.
4. Ler esta skill e os arquivos auxiliares:
   - `TOKENS.md`
   - `COMPONENTS.md`
   - `PAGE_PATTERNS.md`
   - `BACKEND_STACK.md`
   - `GENERATION_PLAYBOOK.md`
   - `QA_CHECKLIST.md`
5. Definir telas minimas do MVP operacional.
6. Criar plano pequeno: primeiro shell + dashboard + entidades, depois features.
7. Implementar em blocos pequenos.
8. Validar build/typecheck/testes/smoke visual.
9. Auditar consistencia visual: tokens, spacing, cards, tabelas, graficos e mobile.
10. Entregar relatorio final com arquivos, validacoes, riscos e como testar.

## Regras de design

- Usar Gantari como fonte quando possivel.
- Dark mode e a experiencia primaria.
- Sidebar permanece escura mesmo no light mode.
- Usar lime `#AFFF00` como acento principal, nao verde generico.
- Layout de SaaS deve ser contido, denso e operacional.
- Cards nao devem parecer landing page.
- Evitar gradientes decorativos, blobs, orbs, hero exagerado e ilustracao sem funcao.
- Usar graficos com linhas suaves, grid discreto e hover tooltip.
- Usar cards para itens repetidos, KPIs e modulos. Nao empilhar card dentro de card sem motivo.
- Tabelas devem ser compactas, com cabecalho pequeno uppercase e linhas escaneaveis.
- Mobile deve ter navegacao propria, sem apenas encolher desktop.

## Regras de engenharia

- Preferir modular monolith antes de microservices.
- Separar server/client/shared quando o repo permitir.
- Backend deve expor healthcheck real.
- Banco deve ter schema claro, migrations, indices e tenant isolation quando aplicavel.
- Toda acao critica deve ter audit log.
- Filas/workers devem ser idempotentes.
- Deploy precisa ter rollback, env vars documentadas e smoke test.
- Nunca criar dependencia nova se o projeto ja tem equivalente local.

## Como responder ao usuario

Ao iniciar criacao de SaaS:

1. Informe que vai usar o padrao Felipe.
2. Diga quais referencias serao usadas: NEW ADMIN como base principal, Lumina como apoio visual/backend.
3. Separe entregas por:
   - UX/UI.
   - Frontend.
   - Backend.
   - Banco.
   - Deploy.
   - QA.
4. Nao diga que esta pronto sem validacao.

## Delegacao para agentes

Animus deve coordenar assim:

- Felipe: define padrao tecnico e limites de producao.
- Atlas: implementa arquitetura, backend, frontend e integracoes.
- Helena: aplica design system, layout, cards, responsividade e UX.
- Sentinel: valida build, regressao, UI states, edge cases e criterios de aceite.
- Titan: valida Docker/PM2/Gradsky/env/rollback quando houver deploy.
- Victor: entra apenas se houver copy comercial/onboarding/landing dentro do produto.

## Criterio de aceite

Um SaaS no padrao Felipe so esta aceitavel quando:

- Parece um produto operacional premium, nao uma landing.
- A primeira viewport ja mostra o produto funcionando.
- Tokens batem com `TOKENS.md`.
- Componentes batem com `COMPONENTS.md`.
- Layout bate com `PAGE_PATTERNS.md`.
- Stack bate com `BACKEND_STACK.md` ou existe justificativa.
- `QA_CHECKLIST.md` foi usado antes da entrega.
