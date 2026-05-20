#!/usr/bin/env bash
# deploy-proposta.sh
# Deploy completo de proposta comercial via GitHub privado + Gradsky PAT.

set -Eeuo pipefail

log() { printf "\n[deploy-proposta] %s\n" "$1"; }
die() { printf "\n[ERRO] %s\n" "$1" >&2; exit 1; }

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../../.." && pwd)"

for ENV_FILE in "$REPO_ROOT/.env" "./.env" "$SCRIPT_DIR/../../.env"; do
  if [[ -f "$ENV_FILE" ]]; then
    set -a
    # shellcheck disable=SC1090
    . "$ENV_FILE"
    set +a
    log ".env carregado de $ENV_FILE"
    break
  fi
done

require_env() {
  local var="$1"
  [[ -n "${!var:-}" ]] || die "Variavel de ambiente $var nao definida."
}

need_cmd() {
  command -v "$1" >/dev/null 2>&1 || die "Comando '$1' nao encontrado."
}

NOME=""
REPO=""
DOMAIN=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --nome) NOME="$2"; shift 2 ;;
    --repo) REPO="$2"; shift 2 ;;
    --domain) DOMAIN="$2"; shift 2 ;;
    *) die "Argumento desconhecido: $1" ;;
  esac
done

[[ -n "$NOME" ]] || die "Faltou --nome"
[[ -n "$REPO" ]] || die "Faltou --repo"
[[ -n "$DOMAIN" ]] || die "Faltou --domain"
[[ -f "index.html" ]] || die "index.html nao encontrado no diretorio atual"

require_env GH_TOKEN
require_env GH_USER
require_env GRADSKY_TOKEN

need_cmd git
need_cmd curl
need_cmd jq
need_cmd base64

GRADSKY_API="${GRADSKY_API:-https://api.gradsky.com.br}"
GRADSKY_PUBLIC_DOMAIN="${GRADSKY_PUBLIC_DOMAIN:-true}"
GRADSKY_ATTACH_DOMAIN="${GRADSKY_ATTACH_DOMAIN:-false}"
GRADSKY_VERIFY_DOMAIN="${GRADSKY_VERIFY_DOMAIN:-false}"
GRADSKY_FORCE_DOMAIN="${GRADSKY_FORCE_DOMAIN:-false}"
GRADSKY_GIT_AUTO_DEPLOY="${GRADSKY_GIT_AUTO_DEPLOY:-true}"
GRADSKY_FORCE_DEPLOY="${GRADSKY_FORCE_DEPLOY:-false}"
SUBDOMAIN=""
[[ -n "${DOMINIO_BASE:-}" ]] && SUBDOMAIN="${DOMAIN}.${DOMINIO_BASE}"

gradsky_request() {
  local method="$1"
  local path="$2"
  local payload="${3:-}"
  local tmp
  tmp="$(mktemp)"

  local args=(-sS -X "$method" "${GRADSKY_API}${path}" -H "Authorization: Bearer ${GRADSKY_TOKEN}")
  if [[ -n "$payload" ]]; then
    args+=(-H "Content-Type: application/json" --data "$payload")
  fi

  curl "${args[@]}" -o "$tmp" || { rm -f "$tmp"; die "Falha de rede chamando Gradsky $method $path"; }

  if jq -e '.ok == true' "$tmp" >/dev/null 2>&1; then
    cat "$tmp"
    rm -f "$tmp"
    return 0
  fi

  local code message required retry
  code="$(jq -r '.error.code // "UNKNOWN"' "$tmp" 2>/dev/null)"
  message="$(jq -r '.error.message // "Erro Gradsky"' "$tmp" 2>/dev/null)"
  required="$(jq -r '.error.details.requiredScope // empty' "$tmp" 2>/dev/null)"
  retry="$(jq -r '.error.details.retryAfterSeconds // empty' "$tmp" 2>/dev/null)"
  rm -f "$tmp"

  if [[ "$code" == "PAT_RATE_LIMIT_EXCEEDED" && -n "$retry" ]]; then
    log "Rate limit Gradsky. Aguardando ${retry}s."
    sleep "$retry"
    gradsky_request "$method" "$path" "$payload"
    return
  fi

  [[ "$code" == "PAT_INSUFFICIENT_SCOPE" && -n "$required" ]] && die "Gradsky sem scope necessario: $required"
  if [[ "$code" == "DOMAIN_VERIFICATION_PENDING" ]]; then
    log "Gradsky $code: $message"
    return 2
  fi
  die "Gradsky $code: $message"
}

discover_project_id() {
  if [[ -n "${GRADSKY_PROJECT_ID:-}" ]]; then
    echo "$GRADSKY_PROJECT_ID"
    return
  fi
  local resp count
  resp="$(gradsky_request GET "/projects")"
  count="$(echo "$resp" | jq '.data.items | length')"
  [[ "$count" -eq 1 ]] || die "Defina GRADSKY_PROJECT_ID no .env. Projetos acessiveis: $count"
  echo "$resp" | jq -r '.data.items[0].id'
}

find_service_id() {
  local project_id="$1"
  local app_name="$2"
  gradsky_request GET "/services?projectId=${project_id}" \
    | jq -r --arg name "$app_name" '.data.items[]? | select(.name == $name or .slug == $name) | .id' \
    | head -1
}

sanitize_domain_label() {
  echo "$1" \
    | tr '[:upper:]' '[:lower:]' \
    | sed -E 's/[^a-z0-9-]+/-/g; s/^-+//; s/-+$//' \
    | cut -c1-63
}

make_compose() {
  local html_b64="$1"
  cat <<YAML
services:
  app:
    image: nginx:alpine
    ports:
      - "80:80"
    environment:
      SITE_HTML_B64: "${html_b64}"
    command: >
      sh -c 'printf "%s" "\$SITE_HTML_B64" | base64 -d > /usr/share/nginx/html/index.html && nginx -g "daemon off;"'
YAML
}

deploy_gradsky_static() {
  local project_id="$1"
  local app_name="$2"
  local html_file="$3"
  local html_b64 service_id payload compose resp public_url public_label domain_id ownership_name ownership_token created needs_deploy

  html_b64="$(base64 < "$html_file" | tr -d '\n')"
  service_id="$(find_service_id "$project_id" "$app_name")"
  created=0
  needs_deploy=0

  if [[ -n "$service_id" ]]; then
    if [[ "$GRADSKY_GIT_AUTO_DEPLOY" == "true" ]]; then
      log "service Gradsky existente: $service_id. Commit/push no GitHub deve disparar redeploy automatico."
    else
      log "service Gradsky existente: $service_id. Atualizando proposta via API porque GRADSKY_GIT_AUTO_DEPLOY=false."
      payload="$(jq -n --arg key "SITE_HTML_B64" --arg value "$html_b64" '{key:$key,value:$value,isSecret:false,environment:"production"}')"
      gradsky_request POST "/services/${service_id}/env" "$payload" >/dev/null
      gradsky_request POST "/services/${service_id}/restart" >/dev/null
    fi
  else
    log "criando service Gradsky via import-docker-app"
    compose="$(make_compose "$html_b64")"
    payload="$(jq -n --arg yaml "$compose" --arg app "$app_name" '{composeYaml:$yaml,appName:$app,options:{autoDeploy:true,continueOnError:false,defaultVolumeSizeGb:5}}')"
    resp="$(gradsky_request POST "/projects/${project_id}/import-docker-app" "$payload")"
    service_id="$(echo "$resp" | jq -r '.data.services[0].serviceId // .data.services[0].id // empty')"
    [[ -n "$service_id" ]] || die "Gradsky nao retornou serviceId"
    created=1
    needs_deploy=1
  fi

  if [[ "$created" -eq 0 && "$GRADSKY_FORCE_DOMAIN" != "true" ]]; then
    log "service existente: mantendo dominios atuais. Use GRADSKY_FORCE_DOMAIN=true para reconfigurar dominio."
  elif [[ "$GRADSKY_ATTACH_DOMAIN" == "true" ]]; then
    [[ -n "$SUBDOMAIN" ]] || die "GRADSKY_ATTACH_DOMAIN=true exige DOMINIO_BASE"
    log "registrando dominio customizado Gradsky: $SUBDOMAIN"
    payload="$(jq -n --arg hostname "$SUBDOMAIN" '{hostname:$hostname}')"
    resp="$(gradsky_request POST "/services/${service_id}/domains" "$payload")"
    domain_id="$(echo "$resp" | jq -r '.data.id // .data.domain.id // .data.domainId // empty')"
    ownership_name="$(echo "$resp" | jq -r '.data.ownershipTxtName // .data.domain.ownershipTxtName // empty')"
    ownership_token="$(echo "$resp" | jq -r '.data.ownershipTxtToken // .data.domain.ownershipTxtToken // empty')"
    if [[ -n "$ownership_name" || -n "$ownership_token" ]]; then
      log "DNS necessario: CNAME ${SUBDOMAIN} -> $(sanitize_domain_label "$app_name").gradsky.com.br"
      log "DNS ownership TXT: ${ownership_name:-<nome retornado pela API>} -> ${ownership_token:-<token retornado pela API>}"
      log "Se usar Cloudflare, deixe o proxy cinza/DNS only ate o SSL responder."
    fi
    needs_deploy=1
    if [[ "$GRADSKY_VERIFY_DOMAIN" == "true" && -n "$domain_id" ]]; then
      for delay in 30 60 90 120 150; do
        if gradsky_request POST "/services/${service_id}/domains/${domain_id}/verify" >/dev/null; then
          log "dominio customizado verificado"
          break
        fi
        log "dominio ainda pendente; aguardando ${delay}s antes de nova tentativa"
        sleep "$delay"
      done
    fi
  elif [[ "$GRADSKY_PUBLIC_DOMAIN" == "true" ]]; then
    public_label="$(sanitize_domain_label "$app_name")"
    log "criando dominio publico Gradsky: ${public_label}.gradsky.com.br"
    payload="$(jq -n --arg label "$public_label" '{label:$label}')"
    gradsky_request POST "/services/${service_id}/public-domain" "$payload" >/dev/null
    needs_deploy=1
  fi

  if [[ "$needs_deploy" -eq 1 || "$GRADSKY_FORCE_DEPLOY" == "true" ]]; then
    gradsky_request POST "/services/${service_id}/deploy" >/dev/null
  else
    log "sem redeploy via API; aguardando auto redeploy do GitHub quando aplicavel"
  fi
  resp="$(gradsky_request GET "/services/${service_id}")"
  public_url="$(echo "$resp" | jq -r '.data.publicUrl // .data.url // .data.defaultDomain // .data.publicDomain // empty')"
  echo "$service_id|$public_url"
}

log "Iniciando deploy da proposta $NOME"

if [[ ! -d ".git" ]]; then
  git init -b main
fi

git add .
git -c user.email="${GH_EMAIL:-deploy@local}" -c user.name="${GH_USER}" commit -m "Proposta $NOME" >/dev/null 2>&1 || log "Nada novo para commitar"

REMOTE_URL="https://${GH_USER}:${GH_TOKEN}@github.com/${GH_USER}/${REPO}.git"
HTTP_STATUS="$(curl -s -o /tmp/gh_create.json -w "%{http_code}" \
  -X POST "https://api.github.com/user/repos" \
  -H "Authorization: token ${GH_TOKEN}" \
  -H "Accept: application/vnd.github.v3+json" \
  -d "{\"name\":\"${REPO}\",\"private\":true,\"description\":\"Proposta comercial para ${NOME}\"}")"

if [[ "$HTTP_STATUS" == "201" ]]; then
  log "Repo criado"
elif [[ "$HTTP_STATUS" == "422" ]]; then
  log "Repo ja existia"
else
  cat /tmp/gh_create.json
  die "Falha ao criar repo no GitHub (HTTP $HTTP_STATUS)"
fi

git remote remove origin 2>/dev/null || true
git remote add origin "$REMOTE_URL"
git push -u origin main --force >/dev/null

PROJECT_ID="$(discover_project_id)"
RESULT="$(deploy_gradsky_static "$PROJECT_ID" "$REPO" "index.html")"
SERVICE_ID="${RESULT%%|*}"
PUBLIC_URL="${RESULT#*|}"

log "DEPLOY COMPLETO"
log "Repo: https://github.com/${GH_USER}/${REPO}"
log "Gradsky service: ${SERVICE_ID}"
log "URL API: ${PUBLIC_URL:-nao retornada pela API}"
[[ -n "$SUBDOMAIN" ]] && log "Dominio solicitado: https://${SUBDOMAIN}"
