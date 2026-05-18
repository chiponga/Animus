#!/bin/bash
# =============================================================
# install.sh — Wizard interativo de instalação (Gradsky)
# =============================================================
# Roda bootstrap.sh (deps), faz as 5-6 perguntas certas, escreve
# .env, configura PM2 pro bot Telegram, mostra status final.
#
# Idempotente: se .env já existir, oferece preservar ou refazer.
#
# Uso:
#   bash install.sh
# =============================================================

set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ENV_FILE="$REPO_DIR/.env"
ENV_EXAMPLE="$REPO_DIR/.env.example"
BOT_DIR="$REPO_DIR/animus-bot"

c_bold='\033[1m'; c_cyan='\033[1;36m'; c_green='\033[1;32m'
c_yellow='\033[1;33m'; c_red='\033[1;31m'; c_reset='\033[0m'

say()  { printf "${c_cyan}>> %s${c_reset}\n" "$*"; }
ok()   { printf "${c_green}✓ %s${c_reset}\n" "$*"; }
warn() { printf "${c_yellow}! %s${c_reset}\n" "$*" >&2; }
fail() { printf "${c_red}✗ %s${c_reset}\n" "$*" >&2; exit 1; }

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
      warn "Esse campo é obrigatório."
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
      warn "Esse campo é obrigatório."
      continue
    fi
    break
  done
  printf -v "$varname" '%s' "$value"
}

# -------------------------------------------------------------
# 0. Pré-flight
# -------------------------------------------------------------
echo
printf "${c_bold}=== Instalador do agente Animus (Gradsky) ===${c_reset}\n"
echo

if [[ ! -f "$REPO_DIR/bootstrap.sh" ]]; then
  fail "bootstrap.sh não encontrado em $REPO_DIR. Rode esse script da raiz do repo Animus."
fi

if [[ -f "$ENV_FILE" ]]; then
  warn "Já existe um .env em $ENV_FILE."
  read -r -p "Sobrescrever? [y/N]: " resp
  if [[ ! "$resp" =~ ^[Yy]$ ]]; then
    say "Pulando configuração — vou só rodar bootstrap e PM2."
    SKIP_QUESTIONS=1
  fi
fi

# -------------------------------------------------------------
# 1. Bootstrap (deps)
# -------------------------------------------------------------
say "Rodando bootstrap.sh (instala Python, Node 22, PM2, Claude CLI, gh)..."
bash "$REPO_DIR/bootstrap.sh"
echo

# -------------------------------------------------------------
# 2. Perguntas
# -------------------------------------------------------------
if [[ -z "${SKIP_QUESTIONS:-}" ]]; then
  echo
  printf "${c_bold}Vou te fazer algumas perguntas. As marcadas (obrigatório) precisam ser preenchidas.${c_reset}\n"
  echo

  ask "Nome do agente (ex: Animus, Atlas, Nexus)" "Animus" AGENT_NAME yes
  ask "Seu nome (como o agente vai te chamar internamente)" "Chefe" OWNER_NAME yes
  ask "Nome da empresa/produto (opcional)" "$AGENT_NAME IA" COMPANY_NAME no
  ask "Nome do produto (opcional)" "$AGENT_NAME Premium" PRODUCT_NAME no

  echo
  printf "${c_cyan}--- Telegram (obrigatório) ---${c_reset}\n"
  printf "Crie o bot no @BotFather, copie o token e pegue seu user_id no @userinfobot.\n\n"

  ask_secret "Token do bot Telegram (BotFather)" TELEGRAM_BOT_TOKEN yes
  ask "Seu user_id do Telegram (numérico, do @userinfobot)" "" OWNER_TELEGRAM_ID yes
  ask "user_ids autorizados (CSV; deixa vazio pra usar só o seu)" "$OWNER_TELEGRAM_ID" ALLOWED_USERS yes

  echo
  printf "${c_cyan}--- Banco (opcional) ---${c_reset}\n"
  printf "Se você usa Supabase/Postgres remoto pra memória persistente, cole a DATABASE_URL.\n"
  printf "Senão deixe em branco — o agente roda sem memória vetorial.\n\n"
  ask_secret "DATABASE_URL (postgres://...) [enter pra pular]" DATABASE_URL no

  echo
  printf "${c_cyan}--- Áudio (opcional) ---${c_reset}\n"
  printf "OpenAI Whisper pra transcrever áudios do Telegram. ElevenLabs pra TTS feminino.\n"
  printf "Pule (enter) se não vai usar áudio agora.\n\n"
  ask_secret "OPENAI_API_KEY [enter pra pular]" OPENAI_API_KEY no
  ask_secret "ELEVENLABS_API_KEY [enter pra pular]" ELEVENLABS_API_KEY no
  if [[ -n "$ELEVENLABS_API_KEY" ]]; then
    ask "ELEVENLABS_VOICE_ID (ID da voz no ElevenLabs)" "" ELEVENLABS_VOICE_ID no
  fi

  echo
  printf "${c_cyan}--- Anthropic API (opcional) ---${c_reset}\n"
  printf "Só preencha se for usar a API direta além do Claude Pro/Max já logado.\n\n"
  ask_secret "ANTHROPIC_API_KEY [enter pra pular]" ANTHROPIC_API_KEY no

  # -----------------------------------------------------------
  # 3. Escreve .env
  # -----------------------------------------------------------
  say "Escrevendo $ENV_FILE..."
  umask 077
  cat > "$ENV_FILE" <<EOF
# Gerado por install.sh em $(date -Iseconds)
# Não commitar — está no .gitignore.

AGENT_NAME=$AGENT_NAME
OWNER_NAME=$OWNER_NAME
OWNER_TELEGRAM_ID=$OWNER_TELEGRAM_ID
COMPANY_NAME=$COMPANY_NAME
PRODUCT_NAME=$PRODUCT_NAME

TELEGRAM_BOT_TOKEN=$TELEGRAM_BOT_TOKEN
ALLOWED_USERS=$ALLOWED_USERS

CLAUDE_TIMEOUT=180

DATABASE_URL=$DATABASE_URL

OPENAI_API_KEY=$OPENAI_API_KEY
ELEVENLABS_API_KEY=$ELEVENLABS_API_KEY
ELEVENLABS_VOICE_ID=${ELEVENLABS_VOICE_ID:-}

ANTHROPIC_API_KEY=$ANTHROPIC_API_KEY
EOF
  chmod 600 "$ENV_FILE"
  ok ".env escrito (modo 600)."
fi

# -------------------------------------------------------------
# 4. Garante diretórios do bot
# -------------------------------------------------------------
mkdir -p "$BOT_DIR"/{inbox,sent,state,logs}

# -------------------------------------------------------------
# 5. Verifica auth do Claude
# -------------------------------------------------------------
echo
say "Verificando autenticação do Claude Code..."
if claude --version >/dev/null 2>&1; then
  if ! claude --print "ping" --output-format text --max-turns 1 >/dev/null 2>&1; then
    warn "Claude CLI instalado mas não consegui chamá-lo em modo headless."
    warn "Se você ainda não logou, rode: claude /login"
    warn "(usa sua conta Pro/Max — abre URL pra colar no browser)"
  else
    ok "Claude CLI respondendo."
  fi
fi

# -------------------------------------------------------------
# 6. PM2 — sobe o bot
# -------------------------------------------------------------
echo
say "Configurando PM2 pro bot Telegram..."

BOT_NAME_LOWER="$(grep '^AGENT_NAME=' "$ENV_FILE" | head -1 | cut -d= -f2 | tr '[:upper:]' '[:lower:]')-bot"
BOT_NAME_LOWER="${BOT_NAME_LOWER:-animus-bot}"

# Remove instância antiga se existir, pra começar limpo
pm2 delete "$BOT_NAME_LOWER" 2>/dev/null || true

pm2 start "$BOT_DIR/bot.py" \
  --name "$BOT_NAME_LOWER" \
  --interpreter python3 \
  --time \
  --log "$BOT_DIR/logs/pm2.log" \
  --merge-logs

pm2 save >/dev/null

# Tenta habilitar startup do PM2 (sem systemd, no Gradsky vai apenas imprimir o comando)
pm2 startup 2>/dev/null | tail -5 || true

ok "Bot iniciado via PM2 como '$BOT_NAME_LOWER'."

# -------------------------------------------------------------
# 7. Resumo
# -------------------------------------------------------------
echo
printf "${c_green}===============================================${c_reset}\n"
printf "${c_green} Instalação concluída.${c_reset}\n"
printf "${c_green}===============================================${c_reset}\n"
echo
echo "Comandos úteis:"
echo "  pm2 status                        # status do bot"
echo "  pm2 logs $BOT_NAME_LOWER          # logs ao vivo"
echo "  pm2 restart $BOT_NAME_LOWER       # restart"
echo "  tail -f $BOT_DIR/logs/bot.log     # log da aplicação"
echo
echo "Teste:"
echo "  Mande uma mensagem pro bot no Telegram. Você deve receber o ack 'Anotado, chefe...'"
echo "  e em seguida a resposta gerada pelo Claude."
echo
