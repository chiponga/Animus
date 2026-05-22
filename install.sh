#!/bin/bash
# =============================================================
# install.sh - interactive Animus installer for Gradsky
# =============================================================

set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ENV_FILE="$REPO_DIR/.env"
BOT_DIR="$REPO_DIR/animus-bot"

c_bold='\033[1m'; c_cyan='\033[1;36m'; c_green='\033[1;32m'
c_yellow='\033[1;33m'; c_red='\033[1;31m'; c_reset='\033[0m'

say()  { printf "${c_cyan}>> %s${c_reset}\n" "$*"; }
ok()   { printf "${c_green}OK %s${c_reset}\n" "$*"; }
warn() { printf "${c_yellow}! %s${c_reset}\n" "$*" >&2; }
fail() { printf "${c_red}ERROR %s${c_reset}\n" "$*" >&2; exit 1; }

ask() {
  local prompt="$1" default="${2:-}" varname="$3" required="${4:-no}"
  local value=""
  while true; do
    if [[ -n "$default" ]]; then
      read -r -p "$(printf "${c_bold}%s${c_reset} [%s]: " "$prompt" "$default")" value
      value="${value:-$default}"
    else
      read -r -p "$(printf "${c_bold}%s${c_reset}: " "$prompt")" value
    fi
    if [[ "$required" == "yes" && -z "$value" ]]; then
      warn "Campo obrigatorio."
      continue
    fi
    break
  done
  printf -v "$varname" '%s' "$value"
}

ask_secret() {
  local prompt="$1" varname="$2" required="${3:-no}"
  local value=""
  while true; do
    read -r -s -p "$(printf "${c_bold}%s${c_reset} (oculto): " "$prompt")" value
    echo
    if [[ "$required" == "yes" && -z "$value" ]]; then
      warn "Campo obrigatorio."
      continue
    fi
    break
  done
  printf -v "$varname" '%s' "$value"
}

echo
printf "${c_bold}=== Instalador Animus (Gradsky) ===${c_reset}\n"
echo

[[ -f "$REPO_DIR/bootstrap.sh" ]] || fail "bootstrap.sh nao encontrado em $REPO_DIR"

if [[ -f "$ENV_FILE" ]]; then
  warn "Ja existe .env em $ENV_FILE."
  read -r -p "Sobrescrever? [y/N]: " resp
  if [[ ! "$resp" =~ ^[Yy]$ ]]; then
    SKIP_QUESTIONS=1
  fi
fi

say "Rodando bootstrap.sh..."
bash "$REPO_DIR/bootstrap.sh"

if [[ -z "${SKIP_QUESTIONS:-}" ]]; then
  echo
  ask "Nome do agente" "Animus" AGENT_NAME yes
  ask "Como o agente deve te chamar" "Chefe" OWNER_NAME yes
  ask "Nome da empresa/produto" "$AGENT_NAME IA" COMPANY_NAME no
  ask "Nome do produto" "$AGENT_NAME Premium" PRODUCT_NAME no

  echo
  printf "${c_cyan}--- Telegram ---${c_reset}\n"
  ask_secret "Token do bot Telegram" TELEGRAM_BOT_TOKEN yes
  ask "Seu user_id Telegram" "" OWNER_TELEGRAM_ID yes
  ask "User IDs autorizados CSV" "$OWNER_TELEGRAM_ID" ALLOWED_USERS yes

  echo
  printf "${c_cyan}--- Opcionais ---${c_reset}\n"
  ask_secret "DATABASE_URL [enter para pular]" DATABASE_URL no
  ask_secret "OPENAI_API_KEY [enter para pular]" OPENAI_API_KEY no
  ask_secret "ELEVENLABS_API_KEY [enter para pular]" ELEVENLABS_API_KEY no
  ask "ELEVENLABS_VOICE_ID [enter para pular]" "" ELEVENLABS_VOICE_ID no
  ask_secret "ANTHROPIC_API_KEY [enter para pular]" ANTHROPIC_API_KEY no

  echo
  printf "${c_cyan}--- Skills premium ---${c_reset}\n"
  ask_secret "MUAPI_API_KEY [enter para pular]" MUAPI_API_KEY no
  ask_secret "GEMINI_API_KEY [enter para pular]" GEMINI_API_KEY no
  ask_secret "VALIDEMAIL_API_KEY [enter para pular]" VALIDEMAIL_API_KEY no
  ask_secret "TAVILY_API_KEY [enter para pular]" TAVILY_API_KEY no

  echo
  printf "${c_cyan}--- GitHub + Gradsky ---${c_reset}\n"
  ask_secret "GH_TOKEN [enter para pular]" GH_TOKEN no
  ask "GH_USER [enter para pular]" "" GH_USER no
  ask "GH_EMAIL [enter para pular]" "" GH_EMAIL no
  ask_secret "GRADSKY_TOKEN [enter para pular]" GRADSKY_TOKEN no
  ask "GRADSKY_PROJECT_ID [enter para pular]" "" GRADSKY_PROJECT_ID no
  ask "DOMINIO_BASE [enter para pular]" "" DOMINIO_BASE no

  echo
  printf "${c_cyan}--- Gaby Agent Runtime ---${c_reset}\n"
  ask_secret "GABY_AGENT_API_TOKEN [enter para pular]" GABY_AGENT_API_TOKEN no
  ask_secret "GABY_WEBHOOK_SECRET [enter para pular]" GABY_WEBHOOK_SECRET no
  ask "GABY_ADMIN_BASE_URL" "https://gestor.dominio/api/agent/v1" GABY_ADMIN_BASE_URL no
  ask "GABY_DEFAULT_PROJECT_SLUG [enter para pular]" "" GABY_DEFAULT_PROJECT_SLUG no
  ask "GABY_QUEUE_MODE" "memory" GABY_QUEUE_MODE no
  ask "REDIS_URL [enter para pular]" "" REDIS_URL no

  say "Escrevendo $ENV_FILE..."
  umask 077
  cat > "$ENV_FILE" <<EOF
AGENT_NAME=$AGENT_NAME
OWNER_NAME=$OWNER_NAME
OWNER_TELEGRAM_ID=$OWNER_TELEGRAM_ID
COMPANY_NAME=$COMPANY_NAME
PRODUCT_NAME=$PRODUCT_NAME

TELEGRAM_BOT_TOKEN=$TELEGRAM_BOT_TOKEN
ALLOWED_USERS=$ALLOWED_USERS
CLAUDE_TIMEOUT=300

DATABASE_URL=$DATABASE_URL
OPENAI_API_KEY=$OPENAI_API_KEY
ELEVENLABS_API_KEY=$ELEVENLABS_API_KEY
ELEVENLABS_VOICE_ID=$ELEVENLABS_VOICE_ID
ANTHROPIC_API_KEY=$ANTHROPIC_API_KEY

MUAPI_API_KEY=$MUAPI_API_KEY
GEMINI_API_KEY=$GEMINI_API_KEY
VALIDEMAIL_API_KEY=$VALIDEMAIL_API_KEY
TAVILY_API_KEY=$TAVILY_API_KEY

GH_TOKEN=$GH_TOKEN
GH_USER=$GH_USER
GH_EMAIL=$GH_EMAIL
GRADSKY_TOKEN=$GRADSKY_TOKEN
GRADSKY_API=https://api.gradsky.com.br
GRADSKY_PROJECT_ID=$GRADSKY_PROJECT_ID
GRADSKY_PUBLIC_DOMAIN=true
GRADSKY_ATTACH_DOMAIN=false
GRADSKY_VERIFY_DOMAIN=false
GRADSKY_FORCE_DOMAIN=false
GRADSKY_GIT_AUTO_DEPLOY=true
GRADSKY_FORCE_DEPLOY=false
DOMINIO_BASE=$DOMINIO_BASE

GABY_AGENT_PORT=3333
GABY_AGENT_API_TOKEN=$GABY_AGENT_API_TOKEN
GABY_WEBHOOK_SECRET=$GABY_WEBHOOK_SECRET
GABY_ADMIN_BASE_URL=$GABY_ADMIN_BASE_URL
GABY_DEFAULT_PROJECT_SLUG=$GABY_DEFAULT_PROJECT_SLUG
GABY_QUEUE_MODE=$GABY_QUEUE_MODE
REDIS_URL=$REDIS_URL
GABY_MAX_CONCURRENCY=5
GABY_MODEL_PROVIDER=mock
OPENAI_MODEL=gpt-4.1-mini
EOF
  chmod 600 "$ENV_FILE"
  ok ".env escrito."
fi

mkdir -p "$BOT_DIR"/{inbox,sent,state,logs}

say "Verificando Claude Code..."
if claude --version >/dev/null 2>&1; then
  if ! claude --print "ping" --output-format text --max-turns 1 >/dev/null 2>&1; then
    warn "Claude CLI instalado, mas login/headless ainda pode precisar de ajuste. Rode: claude /login"
  else
    ok "Claude CLI respondendo."
  fi
fi

say "Subindo bot via PM2..."
BOT_NAME_LOWER="$(grep '^AGENT_NAME=' "$ENV_FILE" | head -1 | cut -d= -f2 | tr '[:upper:]' '[:lower:]')-bot"
BOT_NAME_LOWER="${BOT_NAME_LOWER:-animus-bot}"

pm2 delete "$BOT_NAME_LOWER" 2>/dev/null || true
pm2 start "$BOT_DIR/bot.py" \
  --name "$BOT_NAME_LOWER" \
  --interpreter python3 \
  --time \
  --log "$BOT_DIR/logs/pm2.log" \
  --merge-logs
pm2 save >/dev/null || true

ok "Bot iniciado via PM2 como '$BOT_NAME_LOWER'."

if [ -d "$REPO_DIR/apps/gaby-agent-runtime" ] && [ -f "$REPO_DIR/apps/gaby-agent-runtime/ecosystem.config.cjs" ]; then
  GABY_TOKEN_VALUE="$(grep '^GABY_AGENT_API_TOKEN=' "$ENV_FILE" | cut -d= -f2-)"
  if [ -n "$GABY_TOKEN_VALUE" ]; then
    say "Subindo Gaby Agent Runtime via PM2..."
    pm2 delete gaby-agent-runtime 2>/dev/null || true
    pm2 start "$REPO_DIR/apps/gaby-agent-runtime/ecosystem.config.cjs"
    pm2 save >/dev/null || true
    ok "Gaby Agent Runtime iniciado via PM2."
  else
    warn "GABY_AGENT_API_TOKEN vazio. Runtime Gaby nao foi iniciado."
  fi
fi

echo
echo "Comandos:"
echo "  pm2 status"
echo "  pm2 logs $BOT_NAME_LOWER"
echo "  pm2 restart $BOT_NAME_LOWER"
echo "  pm2 logs gaby-agent-runtime"
