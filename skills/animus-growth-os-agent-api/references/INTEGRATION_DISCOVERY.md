# Discovery de Integracoes

Este e o primeiro passo de qualquer operacao do Animus Growth OS.

Objetivo: descobrir o que esta conectado, o que falta, quais tokens existem,
quais rotas respondem e qual risco existe antes de executar automacoes.

## 1. Identificar ambiente

Coletar:

- Base URL da API.
- URL do painel.
- Ambiente: local, staging, Gradsky ou producao.
- Se ha MySQL real ou fallback memory.
- Se ha worker/queue rodando.
- Se o pedido envolve envio real ou somente simulacao.

Se o usuario nao informou a base URL, usar local apenas se o contexto indicar
que o servidor esta rodando:

- API: `http://localhost:8787`
- Painel: `http://localhost:5177`

## 2. Health e banco

Chamar:

```http
GET /api/health
GET /api/db/status
```

Interpretacao:

- `storage=mysql_configured`: persistencia real configurada.
- `storage=memory`: bom para mock/teste, insuficiente para producao.
- `/api/db/status` com erro: nao criar credenciais persistentes nem prometer dados duraveis.

## 3. Autenticar agente

Chamar:

```http
POST /api/agent/v1/connect
Content-Type: application/json

{
  "login": "<AGENT_LOGIN>",
  "password": "<AGENT_PASSWORD>",
  "token": "<AGENT_TOKEN>"
}
```

Depois chamar:

```http
GET /api/agent/v1/me
Authorization: Bearer <session_token>
```

Validar:

- subject correto.
- scopes suficientes.
- expiracao da sessao.

Se falhar, pedir login/senha/token do agente. Nao continuar por tentativa
aleatoria.

## 4. Status Meta

Se envolver Instagram, WhatsApp, comentarios, DM, perfil/avatar, campanha ou
automacao social, chamar:

```http
GET /api/meta/status
Authorization: Bearer <session_token>
```

Campos:

- `appConfigured`: `META_APP_ID` e `META_APP_SECRET`.
- `webhookVerifyConfigured`: `META_WEBHOOK_VERIFY_TOKEN`.
- `webhookSignatureConfigured`: `META_APP_SECRET`.
- `whatsappConfigured`: `META_ACCESS_TOKEN` e `META_WHATSAPP_PHONE_NUMBER_ID`.
- `redirectUri`: URL de callback OAuth.
- `webhookUrl`: URL para configurar no app da Meta.

Se algo estiver falso, pedir somente o segredo necessario.

## 5. Canais conectados

Chamar:

```http
GET /api/agent/v1/tools/channel-accounts
```

Validar por canal:

- Instagram: handle, id externo, status, avatar se existir.
- WhatsApp: numero/phone number id, label, status.
- Google Business: handle/local id.

Se o canal nao existir, criar somente se o usuario pediu e forneceu dados:

```http
POST /api/agent/v1/tools/channel-accounts
{
  "provider": "instagram|whatsapp|google_business",
  "label": "Nome exibido",
  "handle": "@perfil ou numero"
}
```

Registrar canal nao substitui token real da Meta. Canal sem token e apenas
registro operacional.

## 6. Jobs, webhooks e auditoria

Chamar:

```http
GET /api/agent/v1/jobs
GET /api/agent/v1/webhooks/events
GET /api/dashboard/audit
```

Validar:

- Jobs presos em failed/running.
- Eventos chegando duplicados.
- Audit recente de mensagens, automacoes, campanhas ou login.
- Erros por scope insuficiente.

## 7. Automacoes

Chamar:

```http
GET /api/agent/v1/tools/automations
GET /api/agent/v1/tools/comment-automations
GET /api/agent/v1/automation-runs
```

Verificar:

- trigger.
- actions.
- responseMode.
- postRef.
- quantidade de runs.
- ultimo erro.

## 8. Dados de CRM e Inbox

Chamar:

```http
GET /api/agent/v1/tools/leads
GET /api/agent/v1/tools/conversations
```

Validar:

- Leads tem canal correto.
- Conversas tem avatar/contactAvatarUrl quando provider forneceu foto.
- Etapas do Kanban batem com o fluxo.
- Nao ha duplicacao obvia de lead/conversa.

## 9. Analytics

Chamar quando o pedido envolver resultados:

```http
GET /api/agent/v1/tools/analytics/summary
GET /api/agent/v1/tools/analytics/overview
GET /api/agent/v1/tools/analytics/channels
GET /api/agent/v1/tools/analytics/roi
GET /api/agent/v1/tools/instagram/anamnesis
GET /api/agent/v1/tools/sales-tracking/summary
```

Se os dados forem mockados ou insuficientes, declarar isso. Nao apresentar como
resultado real.

## 10. Pedido de credenciais faltantes

Modelos:

### WhatsApp real

```text
Falta configurar WhatsApp real.
Preciso destes itens:
- META_ACCESS_TOKEN
- META_WHATSAPP_PHONE_NUMBER_ID

Depois eu valido com GET /api/meta/status e so considero pronto quando
whatsappConfigured=true.
```

### OAuth Meta

```text
Falta configurar OAuth Meta.
Preciso destes itens:
- META_APP_ID
- META_APP_SECRET
- META_REDIRECT_URI ou PUBLIC_BASE_URL correto

Depois gero a URL em GET /api/meta/oauth/start.
```

### Webhook Meta

```text
Falta configurar webhook Meta.
Preciso destes itens:
- META_WEBHOOK_VERIFY_TOKEN
- META_APP_SECRET para assinatura HMAC da Meta
- PUBLIC_BASE_URL publico apontando para este servidor

Webhook esperado: <PUBLIC_BASE_URL>/api/meta/webhook
```

### Agente API

```text
Falta credencial do agente.
Preciso de:
- AGENT_LOGIN
- AGENT_PASSWORD
- AGENT_TOKEN

Ou crie uma credencial pelo painel/admin usando /api/admin/agent-credentials.
```

## 11. Regra de conclusao

So dizer "integracao pronta" quando:

- Health ok.
- Banco ok quando producao.
- Agent auth ok.
- `GET /api/agent/v1/me` ok.
- Meta status condizente com a integracao pedida.
- Canal aparece em channel accounts.
- Rota de teste executou.
- Readback confirmou o efeito.
- Audit ou job confirmou a execucao.

