# Gradsky PAT para Agentes

Este projeto usa Gradsky como plataforma de deploy para agentes e entregas publicas.

## Variaveis

```text
GRADSKY_TOKEN=gsky_pat_...
GRADSKY_API=https://api.gradsky.com.br
GRADSKY_PROJECT_ID=proj_...
GRADSKY_PUBLIC_DOMAIN=true
GRADSKY_ATTACH_DOMAIN=false
GRADSKY_VERIFY_DOMAIN=false
GRADSKY_FORCE_DOMAIN=false
GRADSKY_GIT_AUTO_DEPLOY=true
GRADSKY_FORCE_DEPLOY=false
DOMINIO_BASE=seudominio.com.br
```

## Seguranca

- Nunca commitar `GRADSKY_TOKEN`.
- Nunca imprimir token em logs.
- Usar menor escopo possivel.
- Confirmar acoes destrutivas antes de executar.

## Rotas permitidas

Ver `skills/gradsky-paas/API_ROUTES.md`.

## Deploy estatico

Landing pages e propostas usam:

```text
POST /projects/{projectId}/import-docker-app
```

com `nginx:alpine` e HTML em `SITE_HTML_B64`.

Se o service ja existir e estiver conectado ao GitHub, o script apenas faz commit/push. A Gradsky inicia o redeploy automaticamente a partir do push.

Use `GRADSKY_FORCE_DEPLOY=true` somente quando precisar forcar `POST /services/{serviceId}/deploy` pela API. Use `GRADSKY_GIT_AUTO_DEPLOY=false` apenas para fallback legado via env/restart.

Para publicar uma URL simples de demo/MVP, use:

```text
POST /services/{serviceId}/public-domain
{ "label": "minha-landing" }
POST /services/{serviceId}/deploy
```

Para dominio customizado:

```text
POST /services/{serviceId}/domains
{ "hostname": "landing.cliente.com.br" }
POST /services/{serviceId}/domains/{domainId}/verify
POST /services/{serviceId}/deploy
```

Se o DNS estiver em Cloudflare, orientar o usuario a deixar proxy cinza/DNS only ate o SSL responder. So depois ligar proxy laranja com SSL `Full (strict)`.

## Teste rapido

```bash
curl -sS -H "Authorization: Bearer $GRADSKY_TOKEN" \
  "${GRADSKY_API:-https://api.gradsky.com.br}/projects"
```
