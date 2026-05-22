# Playbook Operacional

## Fluxo A: conectar e validar o SaaS

1. `GET /api/health`.
2. `GET /api/db/status`.
3. `POST /api/agent/v1/connect`.
4. `GET /api/agent/v1/me`.
5. `GET /api/meta/status`.
6. `GET /api/agent/v1/tools/channel-accounts`.
7. `GET /api/agent/v1/jobs`.
8. Relatar pronto, parcial ou bloqueado.

## Fluxo B: registrar canal

Use quando o usuario quer registrar Instagram, WhatsApp ou Google Business no
sistema.

1. Rodar Discovery.
2. Confirmar provider permitido: `instagram`, `whatsapp`, `google_business`.
3. Criar canal:

```http
POST /api/agent/v1/tools/channel-accounts
{
  "provider": "instagram",
  "label": "Conta principal",
  "handle": "@perfil"
}
```

4. Validar com `GET /api/agent/v1/tools/channel-accounts`.
5. Se for envio real, validar tambem `/api/meta/status`.

## Fluxo C: criar automacao comentario -> DM

1. Rodar Discovery.
2. Confirmar que Instagram esta registrado.
3. Se a automacao for real, confirmar Meta webhook funcionando.
4. Criar automacao:

```http
POST /api/agent/v1/tools/comment-automations
{
  "name": "Comentou quero",
  "postRef": "instagram_post_id",
  "triggerKeywords": ["quero", "cadastro"],
  "responseMode": "both"
}
```

5. Validar:

```http
GET /api/agent/v1/tools/comment-automations
GET /api/agent/v1/tools/comment-automations/:automationId/results
```

6. Testar com evento controlado se webhook real ainda nao estiver conectado:

```http
POST /api/agent/v1/webhooks/inbound
{
  "event": "instagram.comment.created",
  "channel": "instagram",
  "payload": {
    "postRef": "instagram_post_id",
    "text": "quero",
    "author": { "handle": "@lead" }
  }
}
```

## Fluxo D: enviar mensagem

1. Rodar Discovery.
2. Confirmar canal e destinatario.
3. Se WhatsApp real, `whatsappConfigured` precisa ser true.
4. Enviar:

```http
POST /api/agent/v1/tools/messages/send
{
  "channel": "whatsapp",
  "to": "5511999999999",
  "text": "Mensagem aprovada"
}
```

5. Validar `deliveryJob`.
6. Consultar `GET /api/agent/v1/jobs/:jobId`.
7. Consultar conversas.

Se providerStatus for `meta_whatsapp_not_configured`, pedir `META_ACCESS_TOKEN`
e `META_WHATSAPP_PHONE_NUMBER_ID`.

## Fluxo E: mover lead no CRM

1. Listar leads:

```http
GET /api/agent/v1/tools/leads
```

2. Identificar stage real existente.
3. Mover:

```http
PATCH /api/agent/v1/tools/leads/:leadId/stage
{
  "stage": "qualified",
  "reason": "Lead respondeu e demonstrou interesse"
}
```

4. Validar com listagem de leads e audit log.

Nunca inventar stage. Se o stage exato nao estiver claro, usar o painel ou o
schema do projeto para confirmar.

## Fluxo F: enriquecer perfil e foto

Use quando o usuario pedir perfis ricos, fotos de WhatsApp/Instagram ou dados
de perfil.

1. Verificar se lead tem `externalProfileId` ou avatar conhecido.
2. Se tiver avatar direto, chamar:

```http
POST /api/agent/v1/tools/leads/:leadId/enrich-profile
{
  "avatarUrl": "https://...",
  "externalProfileId": "..."
}
```

3. Se precisar buscar na Meta, confirmar `META_ACCESS_TOKEN`.
4. Validar job:

```http
GET /api/agent/v1/jobs/:jobId
GET /api/agent/v1/tools/leads
```

5. Conferir se `avatarUrl` ou `contactAvatarUrl` aparece no dashboard.

## Fluxo G: prospeccao ativa

1. Rodar Discovery.
2. Confirmar fonte:
   - `instagram_followers`
   - `instagram_comments`
   - `google_business`
3. Criar busca:

```http
POST /api/agent/v1/tools/prospecting/search
{
  "source": "instagram_comments",
  "query": "pessoas que comentaram em posts de concorrente X"
}
```

4. Consultar jobs:

```http
GET /api/agent/v1/tools/prospecting/jobs
GET /api/agent/v1/jobs/:jobId
```

5. Separar leads com WhatsApp, sem WhatsApp e alta prioridade.

## Fluxo H: campanha carrossel + automacao

1. Rodar Discovery.
2. Confirmar se publicacao Meta real esta conectada ou se sera mock/teste.
3. Criar job:

```http
POST /api/agent/v1/tools/campaign-jobs/carousel-with-automation
{
  "command": "Criar carrossel sobre X e automacao para quem comentar quero"
}
```

4. Validar:

```http
GET /api/agent/v1/tools/campaign-jobs
GET /api/agent/v1/tools/comment-automations
GET /api/agent/v1/jobs/:jobId
```

5. Se resposta contiver `providerStatus: mocked_until_meta_api_connected`,
informar que a publicacao real ainda depende de integracao Meta.

## Fluxo I: analytics e ROI

1. Chamar rotas:

```http
GET /api/agent/v1/tools/analytics/summary
GET /api/agent/v1/tools/analytics/overview
GET /api/agent/v1/tools/analytics/channels
GET /api/agent/v1/tools/analytics/roi
GET /api/agent/v1/tools/instagram/anamnesis
GET /api/agent/v1/tools/sales-tracking/summary
```

2. Separar dados reais de dados mockados.
3. Entregar leitura acionavel:
   - melhor canal.
   - gargalo.
   - campanha com maior ROI.
   - proxima automacao recomendada.

## Fluxo J: diagnosticar falha

Ordem:

1. Health.
2. DB status.
3. Auth agent.
4. Scopes.
5. Meta status.
6. Channel accounts.
7. Jobs failed.
8. Webhook events.
9. Audit log.
10. Readback da entidade afetada.

Relatorio minimo:

- Sintoma.
- Evidencia.
- Rota que falhou.
- Codigo de erro.
- Causa provavel.
- Correcao recomendada.
- Token/env var necessario, se houver.

