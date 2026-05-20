# Static HTML Deploy

Padrao usado pelas skills de landing/proposta.

## Ideia

Usar `nginx:alpine` e publicar `index.html` via env var nao secreta `SITE_HTML_B64`.

Isso evita depender de plataforma externa de deploy estatico ou de endpoint de upload inexistente.

## Compose

```yaml
services:
  app:
    image: nginx:alpine
    ports:
      - "80:80"
    environment:
      SITE_HTML_B64: "<base64>"
    command: >
      sh -c 'printf "%s" "$SITE_HTML_B64" | base64 -d > /usr/share/nginx/html/index.html && nginx -g "daemon off;"'
```

## Atualizacao idempotente

1. Listar services do projeto.
2. Se service existe:
   - fazer commit/push no GitHub.
   - nao chamar redeploy pela API por padrao; a Gradsky dispara auto redeploy a partir do push.
   - usar env/restart somente com `GRADSKY_GIT_AUTO_DEPLOY=false`.
3. Se nao existe:
   - `POST /projects/{projectId}/import-docker-app`.
4. Para URL publica simples:
   - `POST /services/{serviceId}/public-domain` com `{ "label": "<slug>" }`.
   - `POST /services/{serviceId}/deploy`.
   - Aguardar 30-60s para SSL.
5. Para dominio customizado:
   - `POST /services/{serviceId}/domains` com `{ "hostname": "<host>" }`.
   - Orientar CNAME para `<slug>.gradsky.com.br` e TXT de ownership quando retornado pela API.
   - `POST /services/{serviceId}/domains/{domainId}/verify` com backoff.
   - `POST /services/{serviceId}/deploy`.

## Cloudflare

Se o dominio customizado usa Cloudflare, o proxy precisa ficar cinza/DNS only durante a verificacao e emissao inicial do SSL.
Depois que `curl -I https://hostname` responder com SSL valido, o usuario pode ligar proxy laranja usando SSL mode `Full (strict)`.

## Limites

- Nao usar para HTML enorme demais.
- Nao colocar secrets no HTML.
- Para apps dinamicos, usar imagem Docker real.
