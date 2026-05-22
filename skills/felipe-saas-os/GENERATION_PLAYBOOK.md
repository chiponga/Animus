# Playbook de geracao de SaaS no padrao Felipe

Este playbook ensina o agente a transformar um pedido como "cria um SaaS" em uma entrega concreta, sem inventar demais e sem quebrar o padrao visual.

## Fase 0 - Confirmar escopo minimo

Antes de criar:

- Qual problema o SaaS resolve?
- Quem usa?
- Qual entidade principal?
- Qual workflow principal?
- Vai ter login?
- Vai ter multi-tenant?
- Vai ter billing?
- Vai rodar em Gradsky?
- Existe repo atual ou e projeto novo?

Se o usuario nao responder e for aceitavel assumir, usar defaults conservadores:

- App SaaS B2B operacional.
- Login simples.
- Dashboard.
- CRUD da entidade principal.
- Audit/activity log.
- Stack Felipe.
- Visual NEW ADMIN/Lumina.

## Fase 1 - Blueprint

Entregar internamente antes de codar:

```text
Produto:
Usuario principal:
Entidades:
Telas:
Fluxos:
Backend:
Banco:
Riscos:
Validacoes:
```

## Fase 2 - Design system local

Criar ou adaptar:

- `globals.css` com tokens.
- `tailwind.config.ts`.
- `components/ui/Card.tsx`.
- `components/ui/Button.tsx`.
- `components/ui/Badge.tsx`.
- `components/layout/AppLayout.tsx`.
- `components/layout/Sidebar.tsx`.
- `components/layout/Topbar.tsx`.
- `components/dashboard/KpiCard.tsx`.
- `components/charts/LineChartSmooth.tsx`.
- `components/charts/RingKpi.tsx`.
- `components/ui/Table.tsx`.

Regras:

- Primeiro criar base pequena.
- Depois compor paginas.
- Nao criar 40 componentes sem uso.

## Fase 3 - App shell

Implementar:

- Dark-first.
- Sidebar desktop.
- Mobile navigation.
- Topbar.
- Main container max-width 1400.
- Rotas principais.

Rotas minimas:

```text
/login
/dashboard
/<entity>
/<entity>/:id
/settings
/activity
```

## Fase 4 - Dashboard real

Criar dashboard com:

- KPI grid principal.
- KPI grid secundario.
- Conversao por origem ou metrica equivalente.
- Grafico principal.
- Breakdown.
- Tabela recente.

Dados:

- Se API ainda nao existe, mockar de modo isolado em `mockData.ts`.
- Marcar mock claramente.
- Nao misturar mock com services reais sem flag.

## Fase 5 - Backend

Criar:

- Elysia server.
- Healthcheck.
- Rotas por modulo.
- DB schema.
- Services.
- Repositories se o projeto usar esse padrao.
- Error handling global.
- Request logging seguro.

Entidades minimas para SaaS multi-tenant:

```text
tenants
users
memberships
audit_logs
activity_events
```

Para dominio especifico, adicionar entidades do produto.

## Fase 6 - Integracao frontend/backend

Criar:

- API client.
- Hooks.
- Loading/empty/error.
- Type-safe payloads quando possivel.

Regras:

- Nao chamar API direto em cada botao sem camada minima.
- Nao ignorar erro.
- Nao deixar loading invisivel.

## Fase 7 - QA e polimento

Validar:

- Build.
- Typecheck.
- Rotas.
- Responsividade.
- Estados.
- Contraste.
- Console sem erro.
- API health.
- Banco/migrations quando aplicavel.

## Prompt interno para agentes

Use este prompt quando Animus delegar criacao de SaaS:

```text
Use as skills felipe-senior-dev-os e felipe-saas-os.

Objetivo: criar/alterar um SaaS no padrao tecnico e visual do Felipe.

Referencia primaria de UI/stack: C:\Users\computador\Documents\JOGOS\NEW ADMIN.
Referencia secundaria visual: C:\Users\computador\Documents\LuminaFrontend-main.
Referencia secundaria backend: C:\Users\computador\Documents\Lumina\LuminaBank.

Nao crie landing page como tela inicial.
Nao use paleta SaaS azul/roxo generica.
Use dark-first, Gantari, lime #AFFF00, cards surface #0F0F0F/#161616, sidebar escura, dashboard denso.

Entregue app shell, dashboard, componentes reutilizaveis, backend coerente, estados e validacao.
Antes de editar, mapeie impacto.
Depois de editar, rode validacao e entregue relatorio.
```

## Prompt para Helena

```text
Atue como Helena usando felipe-saas-os.
Sua responsabilidade e UI/UX.
Respeite NEW ADMIN como referencia primaria.
Entregue layout operacional, cards, tabelas, graficos, responsividade, estados e design tokens.
Nao transforme SaaS em landing.
Nao invente paleta.
Valide visualmente desktop e mobile.
```

## Prompt para Atlas

```text
Atue como Atlas usando felipe-senior-dev-os e felipe-saas-os.
Sua responsabilidade e arquitetura e codigo.
Use Bun/Elysia/TypeScript/React/Vite/Tailwind/Drizzle/MySQL quando for projeto novo.
Preserve padroes existentes se o repo ja tiver stack.
Implemente em blocos pequenos.
Valide build/typecheck/testes.
```

## Prompt para Sentinel

```text
Atue como Sentinel.
Valide que o SaaS segue felipe-saas-os.
Confira build, typecheck, responsividade, estados, erros de console, contraste, rotas, tabelas, graficos e regressao.
Nao aprove se parecer landing page ou template generico.
```

