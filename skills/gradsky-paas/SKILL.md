---
name: gradsky-paas
description: Deploy, gerenciamento e operacao de services containerizados na Gradsky via PAT. Use quando o usuario pedir deploy na Gradsky, listar projetos/services, criar service, importar docker-compose, atualizar env vars, reiniciar/parar service, configurar dominio customizado, migrar deploy antigo para Gradsky, ou operar a API https://api.gradsky.com.br com GRADSKY_TOKEN.
allowed-tools: Read, Write, Edit, Bash, Grep, Glob
---

# Gradsky PaaS

Use esta skill para operar a Gradsky via PAT com seguranca.

## Regras absolutas

- Nunca exponha `GRADSKY_TOKEN`.
- Nunca logue token, env sensivel ou valor revelado por `secrets:read`.
- Nunca invente endpoint fora da lista em `API_ROUTES.md`.
- Antes de criar service, liste services do projeto e procure por `name` ou `slug`.
- Confirme com o usuario antes de parar service, deletar env var ou remover dominio.
- Se faltar scope, pare e informe o scope requerido.
- Se houver rate limit, respeite `retryAfterSeconds`.

## Env vars

Obrigatorias para operacao:

```text
GRADSKY_TOKEN=gsky_pat_...
GRADSKY_API=https://api.gradsky.com.br
```

Recomendadas:

```text
GRADSKY_PROJECT_ID=proj_...
GRADSKY_PUBLIC_DOMAIN=true
GRADSKY_ATTACH_DOMAIN=false
GRADSKY_VERIFY_DOMAIN=false
GRADSKY_FORCE_DOMAIN=false
GRADSKY_GIT_AUTO_DEPLOY=true
GRADSKY_FORCE_DEPLOY=false
DOMINIO_BASE=seudominio.com.br
```

## Fluxo seguro

1. Verificar se `GRADSKY_TOKEN` existe.
2. `GET /account/profile` para validar identidade quando necessario.
3. Descobrir projeto com `GET /projects` se `GRADSKY_PROJECT_ID` nao estiver definido.
4. Listar services antes de criar.
5. Usar `POST /projects/{projectId}/import-docker-app` para deploy novo.
6. Se o service ja existe e esta conectado ao GitHub, fazer apenas commit/push; a Gradsky dispara redeploy automatico.
7. Usar env vars + restart somente como fallback legado quando `GRADSKY_GIT_AUTO_DEPLOY=false`.
8. Para demo/MVP, criar subdominio gerenciado com `POST /services/{serviceId}/public-domain` e `{ "label": "<slug>" }`.
9. Para dominio customizado, usar `POST /services/{serviceId}/domains` com `{ "hostname": "<host>" }`, orientar DNS, verificar com `/verify` e so entao redeployar.
10. Reportar IDs, status, URL conhecida e proximos passos.

## Dominios

- Dominio gerenciado: `POST /services/{serviceId}/public-domain` com `{ "label": "x" }`, gerando `x.gradsky.com.br`.
- Dominio customizado: `POST /services/{serviceId}/domains` com `{ "hostname": "x.cliente.com" }`.
- Verificacao customizada: `POST /services/{serviceId}/domains/{domainId}/verify`.
- Se o DNS for Cloudflare, avisar que o proxy deve ficar cinza/DNS only ate o SSL responder; depois pode ligar laranja com SSL `Full (strict)`.

## Referencias

- `API_ROUTES.md`: rotas permitidas e scopes.
- `ERROR_HANDLING.md`: codigos de erro e resposta.
- `STATIC_HTML_DEPLOY.md`: padrao usado por landing/proposta.

## Saida padrao

```text
Gradsky:
- Projeto: <id/nome>
- Service: <id/nome>
- Operacao: <criado/atualizado/restartado>
- Status: <status>
- URL: <url se disponivel>
- Proximo passo: <validar DNS/testar endpoint/etc>
```
