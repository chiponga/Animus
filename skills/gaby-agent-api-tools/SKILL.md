---
name: gaby-agent-api-tools
description: Rotas, payloads e regras da Agent API do NEW ADMIN para a Gaby atender o chat Brasil Games com Bearer token, webhooks HMAC e endpoints seguros.
allowed-tools: Read, Grep, Glob
---

# Gaby Agent API Tools

Esta skill complementa `gaby-brasil-games`.

Use esta skill para operar a API `https://<gestor.dominio>/api/agent/v1`.

## Autenticacao
Toda chamada REST da Gaby para o NEW ADMIN usa:

```http
Authorization: Bearer <AGENT_API_TOKEN>
```

Nunca logar ou exibir o token.

## Webhook recebido
Endpoint do runtime:

```text
POST /webhooks/subway
```

Headers esperados:

```text
X-Event
X-Timestamp
X-Signature
```

`X-Signature` e HMAC SHA-256 do body cru com o secret configurado no painel.

## Eventos suportados
- `chat.message_received`
- `tx.paid`
- `tx.failed`
- `tx.expired`

## Rotas de leitura
- `GET /:projetoSlug/users/lookup`
- `GET /:projetoSlug/users/:userId/context`
- `GET /:projetoSlug/users/:userId`
- `GET /:projetoSlug/sessions/:sessionId/messages?limit=50`
- `GET /:projetoSlug/transactions/:txId`
- `GET /:projetoSlug/users/:userId/balance`

## Rotas de escrita
- `POST /:projetoSlug/sessions`
- `POST /:projetoSlug/sessions/:sessionId/messages`
- `POST /:projetoSlug/users/:userId/pix`
- `POST /:projetoSlug/transactions/:txId/refresh-status`
- `POST /:projetoSlug/transactions/:txId/cancel`
- `GET /:projetoSlug/users/:userId/bonus/eligibility?percent=100`
- `POST /:projetoSlug/users/:userId/bonus/promise`
- `POST /:projetoSlug/users/:userId/balance/credit`

## Regras de ferramentas
- Antes de escrever no chat, tenha `session_id`.
- Antes de gerar PIX, tenha `user_id`, valor e sessao.
- Antes de prometer bonus, cheque elegibilidade.
- Antes de credito manual, aplicar skill `gaby-risk-and-resolution`.
- Antes de cancelar PIX, confirmar status `PENDING`.
- Respeitar 429 e `Retry-After`.
- Nunca inventar endpoint fora desta lista.
- Nunca responder sobre saldo, PIX, bonus, taxa ou saque sem contexto.

## Payload de resposta no chat
Single:

```json
{
  "text": "Vou verificar pra voce."
}
```

Multi-bubble:

```json
{
  "messages": [
    { "text": "Conferi aqui." },
    { "text": "Esse PIX ainda esta pendente." }
  ]
}
```

Com PIX:

```json
{
  "text": "Gerei o PIX pra voce.",
  "pix_card": { "tx_id": 9876 }
}
```

## Erros que exigem parar
- `missing_token`
- `invalid_token`
- `agent_disabled`
- `projeto_not_found`
- `subway_unreachable`
- `subway_timeout`

## Erros que exigem ajuste
- `invalid_amount`
- `amount_above_cap`
- `invalid_bonus_percent`
- `hour_cap_exceeded`
- `pix_generation_failed`
- `rate_limited`
