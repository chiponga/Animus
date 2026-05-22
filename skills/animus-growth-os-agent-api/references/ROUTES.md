# Rotas Oficiais do Animus Growth OS

Base local padrao:

- Painel: `http://localhost:5177`
- API: `http://localhost:8787`

Todas as respostas seguem o envelope:

```json
{ "ok": true, "data": {} }
```

Erros seguem:

```json
{ "ok": false, "error": { "code": "CODE", "message": "Mensagem" } }
```

## Rotas publicas

| Metodo | Rota | Para que serve |
|---|---|---|
| GET | `/api/health` | Verifica se API esta viva e se storage e `mysql_configured` ou `memory`. |
| GET | `/api/db/status` | Testa conexao real com MySQL. Use antes de operacoes persistentes. |

## Autenticacao humana

| Metodo | Rota | Body | Para que serve |
|---|---|---|---|
| POST | `/api/auth/login` | `{ "email": "...", "password": "..." }` | Login do painel humano. Retorna bearer com scopes de dashboard/admin. |

## Autenticacao de agente

| Metodo | Rota | Body | Para que serve |
|---|---|---|---|
| POST | `/api/agent/v1/connect` | `{ "login": "...", "password": "...", "token": "..." }` | Login do agente. Exige login, senha e token. Retorna bearer. |
| GET | `/api/agent/v1/me` | - | Confirma sessao, sujeito, scopes e expiracao. |

Header apos autenticar:

```http
Authorization: Bearer <session_token>
```

## Credenciais de agente

Exigem sessao humana com `agent:read` ou `agent:write`.

| Metodo | Rota | Para que serve |
|---|---|---|
| GET | `/api/admin/agent-credentials` | Lista credenciais de agentes sem vazar hash/secret. |
| POST | `/api/admin/agent-credentials` | Cria credencial persistente de agente. Body: `login`, `password`, `token`, `scopes?`. |
| POST | `/api/admin/agent-credentials/:credentialId/revoke` | Revoga credencial de agente. |

## Meta API e webhooks

| Metodo | Rota | Auth | Para que serve |
|---|---|---|---|
| GET | `/api/meta/status` | human/agent com `dashboard:read` | Mostra se Meta App, webhook e WhatsApp estao configurados. |
| GET | `/api/meta/oauth/start` | human com `agent:write` | Gera URL OAuth da Meta. Query opcional: `scopes`, `state`. |
| GET | `/api/meta/oauth/callback` | publico via Meta | Recebe `code` OAuth e troca por token. Token e redigido na resposta. |
| GET | `/api/meta/webhook` | Meta verify token | Valida webhook da Meta com `hub.challenge`. |
| POST | `/api/meta/webhook` | assinatura `x-hub-signature-256` | Recebe eventos reais da Meta, normaliza, grava evento, roda automacoes e cria job. |

Variaveis de ambiente relevantes:

- `PUBLIC_BASE_URL`
- `META_GRAPH_VERSION`
- `META_APP_ID`
- `META_APP_SECRET`
- `META_REDIRECT_URI`
- `META_WEBHOOK_VERIFY_TOKEN`
- `META_ACCESS_TOKEN`
- `META_WHATSAPP_PHONE_NUMBER_ID`

## Dashboard humano

Aceita sessao humana ou agente com scope de dashboard quando indicado.

| Metodo | Rota | Scope | Para que serve |
|---|---|---|---|
| GET | `/api/dashboard/summary` | `dashboard:read` | KPIs do dashboard: leads, conversas, ROI e resumo operacional. |
| GET | `/api/dashboard/overview` | `dashboard:read` | Series e visao geral de crescimento. |
| GET | `/api/dashboard/leads` | `dashboard:read` | Lista leads. Query opcional: `stage`. |
| PATCH | `/api/dashboard/leads/:leadId/stage` | `dashboard:write` | Move lead no Kanban. Body: `stage`, `reason?`. |
| GET | `/api/dashboard/conversations` | `dashboard:read` | Lista conversas do Inbox. |
| POST | `/api/dashboard/messages/send` | `dashboard:write` | Enfileira envio manual de mensagem. Body precisa `text`. |
| GET | `/api/dashboard/automations` | `dashboard:read` | Lista automacoes, automacoes de comentario e runs. |
| GET | `/api/dashboard/campaigns` | `dashboard:read` | Lista campaign jobs. |
| GET | `/api/dashboard/jobs` | `dashboard:read` | Lista jobs. Query opcional: `status`. |
| GET | `/api/dashboard/channel-accounts` | `dashboard:read` | Lista contas/canais conectados. |
| GET | `/api/dashboard/prospecting/jobs` | `dashboard:read` | Lista buscas de prospeccao. |
| GET | `/api/dashboard/audit` | `audit:read` | Audit log do painel. |
| GET | `/api/audit-log` | `audit:read` | Audit log geral. |

## Agent API: comandos e fila

| Metodo | Rota | Scope | Para que serve |
|---|---|---|---|
| POST | `/api/agent/v1/commands` | `commands:write` | Recebe comando livre auditado e cria job `agent_command`. |
| GET | `/api/agent/v1/jobs` | `jobs:read` | Lista jobs. Query opcional: `status`. |
| GET | `/api/agent/v1/jobs/:jobId` | `jobs:read` | Consulta status de um job especifico. |

## Agent API: leads e CRM

| Metodo | Rota | Scope | Body/Query | Para que serve |
|---|---|---|---|---|
| GET | `/api/agent/v1/tools/leads` | `leads:read` | query `stage?` | Lista leads, opcionalmente por etapa. |
| POST | `/api/agent/v1/tools/leads` | `leads:write` | `name`, `channel` obrigatorios | Cria lead. Pode incluir handle, avatarUrl, profile data. |
| PATCH | `/api/agent/v1/tools/leads/:leadId/stage` | `crm:move` | `stage`, `reason?` | Move lead no Kanban. |
| POST | `/api/agent/v1/tools/leads/:leadId/enrich-profile` | `leads:write` | `force?`, `avatarUrl?`, `externalProfileId?` | Cria job de enrichment de perfil/avatar. |

Stages aceitos devem ser os usados pelo sistema: nova mensagem, DM enviada,
lead respondeu, lead qualificado e demais stages definidos no schema/store.
Nao inventar stage. Se houver duvida, listar leads e observar stages existentes.

## Agent API: conversas e mensagens

| Metodo | Rota | Scope | Body | Para que serve |
|---|---|---|---|---|
| GET | `/api/agent/v1/tools/conversations` | `messages:read` | - | Lista conversas com canal, contato, avatar, ultima mensagem e status. |
| POST | `/api/agent/v1/tools/messages/send` | `messages:send` | `text` obrigatorio; `to`, `recipient` ou `externalRecipientId` recomendado | Enfileira mensagem e cria job `message_delivery`. |

Se a mensagem for para WhatsApp real, validar antes `GET /api/meta/status` e
confirmar `whatsappConfigured=true`.

## Agent API: automacoes

| Metodo | Rota | Scope | Body | Para que serve |
|---|---|---|---|---|
| GET | `/api/agent/v1/tools/automations` | `automations:read` | - | Lista automacoes gerais. |
| POST | `/api/agent/v1/tools/automations` | `automations:write` | `name`, `trigger`, `actions[]` | Cria automacao baseada em evento. |
| GET | `/api/agent/v1/automation-runs` | `automations:read` | - | Lista execucoes de automacoes. |
| GET | `/api/agent/v1/tools/comment-automations` | `comment_automations:read` | - | Lista automacoes de comentario. |
| POST | `/api/agent/v1/tools/comment-automations` | `comment_automations:write` | `name`, `postRef`, `triggerKeywords[]`, `responseMode?` | Cria automacao comentario -> reply/DM/both. |
| GET | `/api/agent/v1/tools/comment-automations/:automationId/results` | `comment_automations:read` | - | Le resultado de automacao de comentario. |

`responseMode` pode ser `comment_reply`, `direct_message` ou `both`.

## Agent API: canais

| Metodo | Rota | Scope | Body | Para que serve |
|---|---|---|---|---|
| GET | `/api/agent/v1/tools/channel-accounts` | `channels:read` | - | Lista contas conectadas. |
| POST | `/api/agent/v1/tools/channel-accounts` | `channels:write` | `provider`, `label`, `handle` | Registra conta/canal. |

Providers aceitos: `instagram`, `whatsapp`, `google_business`.

## Agent API: prospeccao

| Metodo | Rota | Scope | Body | Para que serve |
|---|---|---|---|---|
| POST | `/api/agent/v1/tools/prospecting/search` | `prospecting:write` | `query`, `source` | Cria busca de prospeccao e job de enrichment. |
| GET | `/api/agent/v1/tools/prospecting/jobs` | `prospecting:read` | - | Lista buscas de prospeccao. |

Sources aceitos: `instagram_followers`, `instagram_comments`, `google_business`.

## Agent API: analytics e inteligencia

| Metodo | Rota | Scope | Para que serve |
|---|---|---|---|
| GET | `/api/agent/v1/tools/analytics/summary` | `analytics:read` | KPIs resumidos. |
| GET | `/api/agent/v1/tools/analytics/overview` | `analytics:read` | Visao geral de crescimento. |
| GET | `/api/agent/v1/tools/analytics/channels` | `analytics:read` | Analytics por canal. Query opcional `channel`. |
| GET | `/api/agent/v1/tools/analytics/roi` | `analytics:read` | ROI e tracking de vendas. |
| GET | `/api/agent/v1/tools/instagram/anamnesis` | `instagram:read` | Analise completa do Instagram. |
| GET | `/api/agent/v1/tools/sales-tracking/summary` | `sales_tracking:read` | Resumo de traqueamento de vendas. |

## Agent API: campanhas

| Metodo | Rota | Scope | Body | Para que serve |
|---|---|---|---|---|
| POST | `/api/agent/v1/tools/campaign-jobs/carousel-with-automation` | `campaign_jobs:write` | `command` | Cria job de carrossel + automacao comentario/DM. |
| GET | `/api/agent/v1/tools/campaign-jobs` | `campaign_jobs:read` | - | Lista campaign jobs. |

Enquanto Meta publish real nao estiver conectado, a rota pode retornar
`providerStatus: mocked_until_meta_api_connected`. Nao tratar isso como post
publicado real.

## Agent API: webhooks internos

| Metodo | Rota | Scope | Body | Para que serve |
|---|---|---|---|---|
| POST | `/api/agent/v1/webhooks/inbound` | `webhooks:write` | `event`, `payload`, `channel?` | Injeta evento de canal no sistema, roda automacoes e cria job. |
| GET | `/api/agent/v1/webhooks/events` | `webhooks:read` | - | Lista eventos recebidos. |

Use esta rota para testes controlados ou canais externos que ainda nao usam
`/api/meta/webhook`.

## Scopes comuns

- `*`
- `dashboard:read`
- `dashboard:write`
- `audit:read`
- `agent:read`
- `agent:write`
- `commands:write`
- `jobs:read`
- `leads:read`
- `leads:write`
- `crm:move`
- `messages:read`
- `messages:send`
- `automations:read`
- `automations:write`
- `comment_automations:read`
- `comment_automations:write`
- `channels:read`
- `channels:write`
- `prospecting:read`
- `prospecting:write`
- `analytics:read`
- `instagram:read`
- `sales_tracking:read`
- `campaign_jobs:read`
- `campaign_jobs:write`
- `webhooks:read`
- `webhooks:write`

