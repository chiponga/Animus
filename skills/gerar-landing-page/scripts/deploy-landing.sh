#!/usr/bin/env bash
# deploy-landing.sh
# Deploy automatizado de landing page via Gradsky PAT.
#
# Fluxo:
#   1. valida index.html renderizado
#   2. cria/atualiza repo privado no GitHub do aluno
#   3. cria ou atualiza service Gradsky usando nginx:alpine
#   4. opcionalmente registra dominio customizado na Gradsky
#
# Requisitos:
#   GH_TOKEN, GH_USER
#   GRADSKY_TOKEN
#   GRADSKY_PROJECT_ID ou unico projeto acessivel no token
#   DOMINIO_BASE opcional se GRADSKY_ATTACH_DOMAIN=true

set -Eeuo pipefail

log() { echo "[deploy-landing] $*"; }
fail() { echo "[deploy-landing] ERRO: $*" >&2; exit 1; }

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../../.." && pwd)"

ENV_LOADED=0
for ENV_FILE in "$REPO_ROOT/.env" "./.env" "$SCRIPT_DIR/../../.env"; do
  if [[ -f "$ENV_FILE" ]]; then
    set -a
    # shellcheck disable=SC1090
    . "$ENV_FILE"
    set +a
    ENV_LOADED=1
    log ".env carregado de $ENV_FILE"
    break
  fi
done

[[ "$ENV_LOADED" -eq 0 ]] && log "AVISO: nenhum .env encontrado; usando variaveis do ambiente"

require_var() {
  local name="$1"
  [[ -n "${!name:-}" ]] || fail "Variavel $name vazia. Configure no .env."
}

need_cmd() {
  command -v "$1" >/dev/null 2>&1 || fail "Comando '$1' nao encontrado"
}

SLUG=""
REPO=""
DIR=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --slug|--domain|--nome) SLUG="$2"; shift 2 ;;
    --repo) REPO="$2"; shift 2 ;;
    --dir) DIR="$2"; shift 2 ;;
    *) fail "arg desconhecido: $1" ;;
  esac
done

[[ -z "$SLUG" ]] && fail "--slug e obrigatorio"
[[ -z "$REPO" ]] && REPO="lp-${SLUG}"
[[ -z "$DIR" ]] && DIR="/tmp/${SLUG}"

[[ -d "$DIR" ]] || fail "Diretorio $DIR nao existe"
[[ -f "$DIR/index.html" ]] || fail "$DIR/index.html nao existe"

if grep -qE '\{\{[A-Z_][A-Z0-9_]*\}\}' "$DIR/index.html"; then
  grep -oE '\{\{[A-Z_][A-Z0-9_]*\}\}' "$DIR/index.html" | sort -u | sed 's/^/[deploy-landing] placeholder pendente: /'
  fail "index.html ainda tem placeholders nao resolvidos"
fi

require_var GH_TOKEN
require_var GH_USER
require_var GRADSKY_TOKEN

need_cmd git
need_cmd gh
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
if [[ -n "${DOMINIO_BASE:-}" ]]; then
  SUBDOMAIN="${SLUG}.${DOMINIO_BASE}"
fi

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

  if ! curl "${args[@]}" -o "$tmp"; then
    rm -f "$tmp"
    fail "Falha de rede chamando Gradsky $method $path"
  fi

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

  if [[ "$code" == "PAT_INSUFFICIENT_SCOPE" && -n "$required" ]]; then
    fail "Gradsky sem scope necessario: $required"
  fi

  if [[ "$code" == "DOMAIN_VERIFICATION_PENDING" ]]; then
    log "Gradsky $code: $message"
    return 2
  fi

  fail "Gradsky $code: $message"
}

discover_project_id() {
  if [[ -n "${GRADSKY_PROJECT_ID:-}" ]]; then
    echo "$GRADSKY_PROJECT_ID"
    return
  fi

  local resp count
  resp="$(gradsky_request GET "/projects")"
  count="$(echo "$resp" | jq '.data.items | length')"

  [[ "$count" -eq 1 ]] || fail "Defina GRADSKY_PROJECT_ID no .env. Projetos acessiveis: $count"
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
      log "service Gradsky existente: $service_id. Atualizando HTML via API porque GRADSKY_GIT_AUTO_DEPLOY=false."
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
    [[ -n "$service_id" ]] || fail "Gradsky nao retornou serviceId no import-docker-app"
    created=1
    needs_deploy=1
  fi

  if [[ "$created" -eq 0 && "$GRADSKY_FORCE_DOMAIN" != "true" ]]; then
    log "service existente: mantendo dominios atuais. Use GRADSKY_FORCE_DOMAIN=true para reconfigurar dominio."
  elif [[ "$GRADSKY_ATTACH_DOMAIN" == "true" ]]; then
    [[ -n "$SUBDOMAIN" ]] || fail "GRADSKY_ATTACH_DOMAIN=true exige DOMINIO_BASE"
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

log "subdominio desejado: ${SUBDOMAIN:-sem DOMINIO_BASE}"

cd "$DIR"

if [[ ! -d ".git" ]]; then
  git init -b main
fi

git add .
git -c user.email="${GH_EMAIL:-deploy@local}" -c user.name="${GH_USER}" commit -m "Landing page ${SLUG}" >/dev/null 2>&1 || log "nada novo para commitar"

if ! gh repo view "${GH_USER}/${REPO}" >/dev/null 2>&1; then
  log "criando repo privado ${GH_USER}/${REPO}"
  GH_TOKEN="$GH_TOKEN" gh repo create "${GH_USER}/${REPO}" --private --source=. --push >/dev/null
else
  log "repo ja existe, fazendo push"
  git remote remove origin 2>/dev/null || true
  git remote add origin "https://${GH_TOKEN}@github.com/${GH_USER}/${REPO}.git"
  git push -u origin main >/dev/null
fi

PROJECT_ID="$(discover_project_id)"
RESULT="$(deploy_gradsky_static "$PROJECT_ID" "$REPO" "$DIR/index.html")"
SERVICE_ID="${RESULT%%|*}"
PUBLIC_URL="${RESULT#*|}"

cat <<RESUMO

[deploy-landing] CONCLUIDO

  Slug:       ${SLUG}
  Repo:       https://github.com/${GH_USER}/${REPO}
  Gradsky:    ${SERVICE_ID}
  URL API:    ${PUBLIC_URL:-nao retornada pela API}
  Dominio:    ${SUBDOMAIN:-nao configurado}

RESUMO
