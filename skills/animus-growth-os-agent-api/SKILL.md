---
name: animus-growth-os-agent-api
description: Use quando Animus ou um subagente precisar operar, auditar, configurar ou integrar o SaaS Animus Growth OS via API, incluindo CRM, Inbox, WhatsApp, Instagram, Meta API, automacoes, campanhas, analytics, jobs, webhooks, tokens e rotas oficiais.
---

# Animus Growth OS Agent API

Esta skill e a memoria operacional do subagente oficial do Animus Growth OS.
Ela documenta como um agente deve operar o SaaS por API sem inventar rota,
sem pular preflight e sem executar acao cega.

## Subagente responsavel

O subagente oficial e `animus-growth-operator`.

Apollo continua responsavel por estrategia comercial, prospeccao e growth.
Quando o pedido envolver operar o SaaS, conectar contas, usar rotas, validar
tokens, criar automacoes, disparar campanhas ou ler analytics reais, Apollo
deve delegar para `animus-growth-operator` ou usar esta skill como base.

## Quando usar

Use esta skill quando o pedido envolver:

- Animus Growth OS.
- SaaS de CRM, Instagram, WhatsApp, Meta API, Google Business ou automacao.
- Conectar rede social, canal, numero, perfil, webhook ou token.
- Criar automacao de comentario, DM, WhatsApp, campanha, carrossel ou fluxo.
- Consultar leads, conversas, mensagens, jobs, analytics, ROI ou auditoria.
- Fazer o agente operar o SaaS por API.
- Diagnosticar por que uma integracao nao esta funcionando.
- Pedir "rotas", "API", "webhook", "tokens", "subagente oficial" ou "memoria".

## Quando nao usar

Nao use como skill principal para:

- Atendimento Brasil Games da Gaby. Use `gaby-brasil-games` e
  `gaby-agent-api-tools`.
- Criar um SaaS do zero. Use `felipe-saas-os` e `felipe-senior-dev-os`.
- Deploy Gradsky. Use `gradsky-paas` com Titan/Felipe.
- Copy, criativo ou oferta isolada. Use Victor e skills de marketing.

## Regra absoluta

Antes de qualquer acao operacional, execute o Discovery de Integracoes.

O agente nunca deve assumir que Instagram, WhatsApp, Meta App, webhook,
token, banco, worker ou credencial de agente estao configurados. Primeiro
validar, depois agir.

Leia sempre:

1. `references/INTEGRATION_DISCOVERY.md`
2. `references/ROUTES.md`
3. `references/OPERATION_PLAYBOOK.md`

## Processo obrigatorio

1. Entender o pedido e classificar o tipo de operacao.
2. Identificar ambiente: local, Gradsky, staging ou producao.
3. Confirmar base URL da API e URL do painel.
4. Chamar `GET /api/health`.
5. Se houver banco, chamar `GET /api/db/status`.
6. Autenticar como agente em `POST /api/agent/v1/connect`.
7. Chamar `GET /api/agent/v1/me` e confirmar sessao.
8. Rodar Discovery de Integracoes.
9. Listar canais, automacoes, jobs e audit log relevantes.
10. Se faltar token, app, webhook ou escopo, pedir exatamente o item faltante.
11. Executar a menor acao possivel.
12. Validar por leitura de volta: job, lead, conversa, automation run ou audit.
13. Entregar relatorio tecnico com o que foi feito, evidencias e pendencias.

## Regras absolutas

- Nunca inventar endpoint, payload, scope, token, provider ou status.
- Nunca expor token, senha, bearer, app secret ou webhook secret em resposta.
- Nunca registrar secret em log, audit body, print, commit ou markdown publico.
- Nunca criar automacao real sem confirmar quais canais estao conectados.
- Nunca enviar mensagem real sem confirmar destinatario, canal e objetivo.
- Nunca chamar API da Meta se `META_ACCESS_TOKEN` ou phone/page id faltar.
- Nunca tratar provider mock como envio real.
- Nunca mascarar erro de API. Relatar codigo, rota, causa provavel e proximo passo.
- Nunca dizer que esta 100% se health, auth, route readback ou job status falhar.
- Nunca alterar `.env` ou secrets de producao sem autorizacao explicita.

## Checklist antes de operar

- [ ] Sei qual ambiente estou operando.
- [ ] Tenho `BASE_URL`.
- [ ] Tenho login, senha e token do agente ou uma sessao bearer valida.
- [ ] `GET /api/health` retornou `ok: true`.
- [ ] Se aplicavel, `GET /api/db/status` retornou conexao ativa.
- [ ] `POST /api/agent/v1/connect` retornou bearer de agente.
- [ ] `GET /api/agent/v1/me` confirmou scopes.
- [ ] `GET /api/meta/status` foi consultado se o pedido envolve Meta.
- [ ] `GET /api/agent/v1/tools/channel-accounts` foi consultado.
- [ ] Sei quais tokens/env vars faltam, se faltarem.
- [ ] A acao planejada tem rota oficial em `ROUTES.md`.

## Checklist depois de operar

- [ ] Fiz readback na rota correta.
- [ ] Verifiquei job em `GET /api/agent/v1/jobs/:jobId` quando houve fila.
- [ ] Conferi `GET /api/dashboard/audit` ou `GET /api/audit-log` quando aplicavel.
- [ ] Conferi se lead/conversa/automacao mudou de fato.
- [ ] Reportei rotas usadas sem vazar bearer.
- [ ] Listei riscos, pendencias e proximas configuracoes.

## Como pedir tokens faltantes

Se faltar algo, seja especifico. Nao pedir "manda os tokens" de forma vaga.

Formato:

```text
Para concluir esta integracao preciso de:
- ENV VAR: META_ACCESS_TOKEN
- Onde usar: envio WhatsApp/Graph API
- Origem: Meta Business App com permissao whatsapp_business_messaging
- Como validar depois: GET /api/meta/status deve mostrar whatsappConfigured=true
```

Se o usuario passar secret no chat, responda sem repetir o valor. Oriente a
colocar em `.env`, Gradsky secrets ou painel de ambiente.

## Como responder ao usuario

Use relatorio operacional curto:

- Ambiente.
- Integracoes encontradas.
- Integracoes faltando.
- Rotas usadas.
- Acoes executadas.
- Evidencias de validacao.
- Riscos ou pendencias.

## Fases conhecidas do SaaS

1. Shell visual e dashboard no padrao NEW ADMIN.
2. Login humano e Agent API auth.
3. Mapa de features do concorrente.
4. Schema MySQL/Drizzle.
5. Store DB com fallback memory.
6. Sessoes persistentes e audit log.
7. Credenciais de agente persistentes.
8. Jobs/workers.
9. Base Meta API, OAuth, status e webhook.
10. CRM automations e automation runs.
11. Analytics, perfil e avatar enrichment.
12. Dashboard conectado a dados reais.
13. Inbox e CRM operacional.
14. Paginas de operacao: prospeccao, automacoes, campanhas, analytics, seguranca.
15. Theme dark/light.

## Credenciais locais de desenvolvimento

Somente para teste local, nunca para producao:

- Painel: `http://localhost:5177`
- API: `http://localhost:8787`
- Admin: `admin@animus.local`
- Senha admin: `admin123`
- Agent login: `animus`
- Agent password: `agent123`
- Agent token: `agt_dev_animus_master`

Em producao, usar credenciais criadas em `/api/admin/agent-credentials` ou
secrets do ambiente.

