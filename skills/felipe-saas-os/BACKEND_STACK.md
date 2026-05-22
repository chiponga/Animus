# Stack backend/frontend do padrao Felipe SaaS

Este arquivo define a stack preferida para novos SaaS no padrao Felipe e como decidir excecoes.

## Stack padrao para projeto novo

Frontend:

- React 18+.
- Vite.
- TypeScript strict.
- Tailwind.
- Lucide React.
- Framer Motion quando houver motion de pagina/componentes.
- Recharts ou SVG custom para graficos.
- React Query/TanStack Query para dados remotos.
- React Hook Form + Zod quando houver forms relevantes.

Backend:

- Bun.
- Elysia.
- TypeScript strict.
- Drizzle ORM.
- MySQL.
- Redis para cache, rate limit, filas simples ou locks.
- RabbitMQ quando houver filas duraveis/workers importantes.
- Docker.
- PM2 ou runtime Gradsky conforme ambiente.

Infra/deploy:

- Gradsky como alvo preferido quando o projeto for hospedado la.
- PM2 dentro de ambiente persistente quando definido.
- Docker para runtime reproduzivel.
- GitHub Actions para CI/CD quando repositorio remoto estiver configurado.

## Estrutura recomendada

```text
src/
  client/
    components/
      ui/
      layout/
      charts/
      dashboard/
    pages/
    hooks/
    lib/
    styles/
  server/
    routes/
    modules/
    services/
    db/
      schema.ts
      migrations/
    lib/
      auth/
      security/
      observability/
      queues/
  shared/
    schemas/
    types/
```

Alternativa para repos pequenos:

```text
src/
  components/
  pages/
  server/
  db/
  shared/
```

## Elysia

Padroes:

- Rotas agrupadas por dominio.
- Validacao de body/query/params.
- Error handler global.
- Request ID/correlation ID.
- Logger estruturado.
- CORS restrito por env.
- Healthcheck real.

Rotas base:

```text
GET /health
GET /api/me
POST /api/auth/login
POST /api/auth/logout
POST /api/auth/refresh
GET /api/<entity>
POST /api/<entity>
GET /api/<entity>/:id
PATCH /api/<entity>/:id
DELETE /api/<entity>/:id
```

Formato de resposta:

```json
{
  "ok": true,
  "data": {}
}
```

Erro:

```json
{
  "ok": false,
  "error": {
    "code": "VALIDATION_ERROR",
    "message": "Mensagem legivel",
    "details": {}
  }
}
```

## Banco MySQL + Drizzle

Regras:

- Toda tabela tem `id`, `created_at`, `updated_at`.
- Multi-tenant: toda tabela de negocio tem `tenant_id`.
- Indices nos campos de filtro e joins.
- Constraints quando possivel.
- Soft delete quando houver recuperacao/auditoria.
- Audit log para alteracoes sensiveis.
- Migrations seguras e reversiveis quando possivel.

Campos padrao:

```ts
id
tenantId
createdAt
updatedAt
deletedAt // se soft delete fizer sentido
createdBy
updatedBy
```

## Redis

Usar para:

- Cache de curto prazo.
- Rate limit.
- Locks distribuidos leves.
- Session store quando necessario.
- Pub/sub simples.

Nao usar para:

- Fonte primaria de verdade.
- Fila critica sem durabilidade.
- Dados financeiros definitivos.

## RabbitMQ

Usar quando:

- Job precisa sobreviver a restart.
- Existe processamento assincrono importante.
- Precisa DLQ.
- Precisa retry/backoff.
- Precisa backpressure.

Padroes:

- Mensagem com idempotency key.
- Retry com backoff.
- DLQ.
- Consumer com graceful shutdown.
- Audit log de job critico.

## Auth e seguranca

Padroes:

- Senha com hash forte.
- Refresh token rotacionavel.
- Cookies httpOnly quando app web proprio permitir.
- CSRF quando usar cookie auth.
- RBAC/ABAC para permissoes.
- Tenant isolation em toda query.
- Rate limit em auth e rotas sensiveis.
- Logs sem senha/token/API key/CPF completo.

Nunca:

- Logar token.
- Retornar stack trace em producao.
- Confiar em tenant_id vindo do cliente sem validar permissao.
- Montar SQL manual quando ORM/query builder resolve.

## Observabilidade

Obrigatorio:

- Request ID.
- Logs estruturados.
- Error codes estaveis.
- Healthcheck.
- Readiness quando houver banco/cache/fila.
- Audit log de operacoes criticas.

Desejavel:

- Metrics.
- Tracing.
- Dashboard de erros.
- Alertas.

## Frontend data layer

Preferir:

- TanStack Query para chamadas API.
- Hooks por dominio: `useCustomers`, `useTransactions`, etc.
- Schemas compartilhados com Zod quando possivel.
- Estados loading/empty/error por componente.

Nao fazer:

- `fetch` espalhado em componentes grandes.
- Mock data misturada com producao sem flag.
- Estado global para tudo.

## Deploy

Para Gradsky:

- Repo GitHub como fonte.
- Commit dispara redeploy automaticamente quando configurado no Gradsky.
- Nao rodar redeploy manual apos cada commit se auto-deploy ja estiver ativo.
- Manter env vars no painel/secret manager, nao no repo.
- Healthcheck precisa refletir app real.

Para PM2:

- `pm2.config` ou comando documentado.
- Logs separados.
- Restart policy.
- Variaveis via `.env` seguro.

## Checklist de projeto novo

- `package.json` com scripts claros:
  - `dev`
  - `build`
  - `start`
  - `typecheck`
  - `lint` quando configurado
  - `db:generate`
  - `db:push` ou migration equivalente
- `.env.example` sem secrets reais.
- `README.md` com setup local.
- Healthcheck.
- Estrutura de logs.
- Tabelas basicas e migrations.
- UI shell e dashboard.
- Validacao antes da entrega.
