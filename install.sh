<<<<<<< HEAD
﻿#!/bin/bash
# =============================================================
# install.sh â€” Wizard interativo de instalaÃ§Ã£o (Gradsky)
=======
#!/bin/bash
# =============================================================
# install.sh — Wizard interativo de instalação (Gradsky)
>>>>>>> e3f95ead324819de792d72b88e4ceac8037a42fb
# =============================================================
# Roda bootstrap.sh (deps), faz as 5-6 perguntas certas, escreve
# .env, configura PM2 pro bot Telegram, mostra status final.
#
<<<<<<< HEAD
# Idempotente: se .env jÃ¡ existir, oferece preservar ou refazer.
=======
# Idempotente: se .env já existir, oferece preservar ou refazer.
>>>>>>> e3f95ead324819de792d72b88e4ceac8037a42fb
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
<<<<<<< HEAD
ok()   { printf "${c_green}âœ“ %s${c_reset}\n" "$*"; }
warn() { printf "${c_yellow}! %s${c_reset}\n" "$*" >&2; }
fail() { printf "${c_red}âœ— %s${c_reset}\n" "$*" >&2; exit 1; }
=======
ok()   { printf "${c_green}✓ %s${c_reset}\n" "$*"; }
warn() { printf "${c_yellow}! %s${c_reset}\n" "$*" >&2; }
fail() { printf "${c_red}✗ %s${c_reset}\n" "$*" >&2; exit 1; }
>>>>>>> e3f95ead324819de792d72b88e4ceac8037a42fb

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
<<<<<<< HEAD
      warn "Esse campo Ã© obrigatÃ³rio."
=======
      warn "Esse campo é obrigatório."
>>>>>>> e3f95ead324819de792d72b88e4ceac8037a42fb
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
<<<<<<< HEAD
      warn "Esse campo Ã© obrigatÃ³rio."
=======
      warn "Esse campo é obrigatório."
>>>>>>> e3f95ead324819de792d72b88e4ceac8037a42fb
      continue
    fi
    break
  done
  printf -v "$varname" '%s' "$value"
}

# -------------------------------------------------------------
<<<<<<< HEAD
# 0. PrÃ©-flight
=======
# 0. Pré-flight
>>>>>>> e3f95ead324819de792d72b88e4ceac8037a42fb
# -------------------------------------------------------------
echo
printf "${c_bold}=== Instalador do agente Animus (Gradsky) ===${c_reset}\n"
echo

if [[ ! -f "$REPO_DIR/bootstrap.sh" ]]; then
<<<<<<< HEAD
  fail "bootstrap.sh nÃ£o encontrado em $REPO_DIR. Rode esse script da raiz do repo Animus."
fi

if [[ -f "$ENV_FILE" ]]; then
  warn "JÃ¡ existe um .env em $ENV_FILE."
  read -r -p "Sobrescrever? [y/N]: " resp
  if [[ ! "$resp" =~ ^[Yy]$ ]]; then
    say "Pulando configuraÃ§Ã£o â€” vou sÃ³ rodar bootstrap e PM2."
=======
  fail "bootstrap.sh não encontrado em $REPO_DIR. Rode esse script da raiz do repo Animus."
fi

if [[ -f "$ENV_FILE" ]]; then
  warn "Já existe um .env em $ENV_FILE."
  read -r -p "Sobrescrever? [y/N]: " resp
  if [[ ! "$resp" =~ ^[Yy]$ ]]; then
    say "Pulando configuração — vou só rodar bootstrap e PM2."
>>>>>>> e3f95ead324819de792d72b88e4ceac8037a42fb
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
<<<<<<< HEAD
  printf "${c_bold}Vou te fazer algumas perguntas. As marcadas (obrigatÃ³rio) precisam ser preenchidas.${c_reset}\n"
=======
  printf "${c_bold}Vou te fazer algumas perguntas. As marcadas (obrigatório) precisam ser preenchidas.${c_reset}\n"
>>>>>>> e3f95ead324819de792d72b88e4ceac8037a42fb
  echo

  ask "Nome do agente (ex: Animus, Atlas, Nexus)" "Animus" AGENT_NAME yes
  ask "Seu nome (como o agente vai te chamar internamente)" "Chefe" OWNER_NAME yes
  ask "Nome da empresa/produto (opcional)" "$AGENT_NAME IA" COMPANY_NAME no
  ask "Nome do produto (opcional)" "$AGENT_NAME Premium" PRODUCT_NAME no

  echo
<<<<<<< HEAD
  printf "${c_cyan}--- Telegram (obrigatÃ³rio) ---${c_reset}\n"
  printf "Crie o bot no @BotFather, copie o token e pegue seu user_id no @userinfobot.\n\n"

  ask_secret "Token do bot Telegram (BotFather)" TELEGRAM_BOT_TOKEN yes
  ask "Seu user_id do Telegram (numÃ©rico, do @userinfobot)" "" OWNER_TELEGRAM_ID yes
  ask "user_ids autorizados (CSV; deixa vazio pra usar sÃ³ o seu)" "$OWNER_TELEGRAM_ID" ALLOWED_USERS yes

  echo
  printf "${c_cyan}--- Banco (opcional) ---${c_reset}\n"
  printf "Se vocÃª usa Supabase/Postgres remoto pra memÃ³ria persistente, cole a DATABASE_URL.\n"
  printf "SenÃ£o deixe em branco â€” o agente roda sem memÃ³ria vetorial.\n\n"
  ask_secret "DATABASE_URL (postgres://...) [enter pra pular]" DATABASE_URL no

  echo
  printf "${c_cyan}--- Ãudio (opcional) ---${c_reset}\n"
  printf "OpenAI Whisper pra transcrever Ã¡udios do Telegram. ElevenLabs pra TTS feminino.\n"
  printf "Pule (enter) se nÃ£o vai usar Ã¡udio agora.\n\n"
=======
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
>>>>>>> e3f95ead324819de792d72b88e4ceac8037a42fb
  ask_secret "OPENAI_API_KEY [enter pra pular]" OPENAI_API_KEY no
  ask_secret "ELEVENLABS_API_KEY [enter pra pular]" ELEVENLABS_API_KEY no
  if [[ -n "$ELEVENLABS_API_KEY" ]]; then
    ask "ELEVENLABS_VOICE_ID (ID da voz no ElevenLabs)" "" ELEVENLABS_VOICE_ID no
  fi

  echo
  printf "${c_cyan}--- Anthropic API (opcional) ---${c_reset}\n"
<<<<<<< HEAD
  printf "SÃ³ preencha se for usar a API direta alÃ©m do Claude Pro/Max jÃ¡ logado.\n\n"
=======
  printf "Só preencha se for usar a API direta além do Claude Pro/Max já logado.\n\n"
>>>>>>> e3f95ead324819de792d72b88e4ceac8037a42fb
  ask_secret "ANTHROPIC_API_KEY [enter pra pular]" ANTHROPIC_API_KEY no

  echo
  printf "${c_cyan}--- Skills premium (todas opcionais) ---${c_reset}\n"
  printf "Cada key destrava 1+ skills. Pula tudo se quiser configurar depois.\n\n"
<<<<<<< HEAD
  ask_secret "MUAPI_API_KEY (imagem/vÃ­deo via Muapi.ai) [enter pra pular]" MUAPI_API_KEY no
  ask_secret "GEMINI_API_KEY (4 skills com Gemini, grÃ¡tis em aistudio.google.com) [enter pra pular]" GEMINI_API_KEY no
  ask_secret "VALIDEMAIL_API_KEY (cold-email-verifier) [enter pra pular]" VALIDEMAIL_API_KEY no
  ask_secret "TAVILY_API_KEY (meeting-brief-generator) [enter pra pular]" TAVILY_API_KEY no

  echo
  printf "${c_cyan}--- Deploy Gradsky/GitHub (opcional) ---${c_reset}\n"
  printf "Preencha se o Animus vai publicar landings, propostas ou dossies via Gradsky PAT.\n"
  printf "Scopes Gradsky minimos: read + deploy. Use secrets:write para atualizar env e domains:write para dominio.\n\n"
  ask_secret "GH_TOKEN (GitHub PAT para repos privados) [enter pra pular]" GH_TOKEN no
  ask "GH_USER (usuario/org GitHub para repos gerados)" "" GH_USER no
  ask "GH_EMAIL (email para commits gerados)" "" GH_EMAIL no
  ask_secret "GRADSKY_TOKEN (PAT Gradsky) [enter pra pular]" GRADSKY_TOKEN no
  ask "GRADSKY_PROJECT_ID (proj_..., recomendado se houver mais de um projeto)" "" GRADSKY_PROJECT_ID no
  ask "GRADSKY_PUBLIC_DOMAIN (true/false para gerar x.gradsky.com.br)" "true" GRADSKY_PUBLIC_DOMAIN no
  ask "GRADSKY_ATTACH_DOMAIN (true/false)" "false" GRADSKY_ATTACH_DOMAIN no
  ask "GRADSKY_VERIFY_DOMAIN (true/false para tentar verify custom domain)" "false" GRADSKY_VERIFY_DOMAIN no
  ask "GRADSKY_FORCE_DOMAIN (true/false para reconfigurar dominio de service existente)" "false" GRADSKY_FORCE_DOMAIN no
  ask "GRADSKY_GIT_AUTO_DEPLOY (true/false para usar push no GitHub como gatilho)" "true" GRADSKY_GIT_AUTO_DEPLOY no
  ask "GRADSKY_FORCE_DEPLOY (true/false para forcar POST /deploy via API)" "false" GRADSKY_FORCE_DEPLOY no
  ask "DOMINIO_BASE (ex: seudominio.com.br, opcional)" "" DOMINIO_BASE no

=======
  ask_secret "MUAPI_API_KEY (imagem/vídeo via Muapi.ai) [enter pra pular]" MUAPI_API_KEY no
  ask_secret "GEMINI_API_KEY (4 skills com Gemini, grátis em aistudio.google.com) [enter pra pular]" GEMINI_API_KEY no
  ask_secret "VALIDEMAIL_API_KEY (cold-email-verifier) [enter pra pular]" VALIDEMAIL_API_KEY no
  ask_secret "TAVILY_API_KEY (meeting-brief-generator) [enter pra pular]" TAVILY_API_KEY no

>>>>>>> e3f95ead324819de792d72b88e4ceac8037a42fb
  # -----------------------------------------------------------
  # 3. Escreve .env
  # -----------------------------------------------------------
  say "Escrevendo $ENV_FILE..."
  umask 077
  cat > "$ENV_FILE" <<EOF
# Gerado por install.sh em $(date -Iseconds)
<<<<<<< HEAD
# NÃ£o commitar â€” estÃ¡ no .gitignore.
=======
# Não commitar — está no .gitignore.
>>>>>>> e3f95ead324819de792d72b88e4ceac8037a42fb

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
ELEVENLABS_VOICE_ID=${ELEVENLABS_VOICE_ID:-}

ANTHROPIC_API_KEY=$ANTHROPIC_API_KEY

# ----- Skills premium -----
MUAPI_API_KEY=$MUAPI_API_KEY
GEMINI_API_KEY=$GEMINI_API_KEY
VALIDEMAIL_API_KEY=$VALIDEMAIL_API_KEY
TAVILY_API_KEY=$TAVILY_API_KEY

# Reddit OAuth (opcional pra reddit-icp-monitor)
REDDIT_CLIENT_ID=
REDDIT_CLIENT_SECRET=
REDDIT_USERNAME=
REDDIT_PASSWORD=

# Notion (opcional pra meeting-brief-generator)
NOTION_TOKEN=
NOTION_DATABASE_ID=

# Hacker News monitor (skill: hackernews-intel)
HN_KEYWORDS=
HN_MIN_POINTS=50
HN_INCLUDE_COMMENTS=false
HN_DB_PATH=
SLACK_WEBHOOK=
<<<<<<< HEAD

# Deploy GitHub + Gradsky (opcional)
GH_TOKEN=$GH_TOKEN
GH_USER=$GH_USER
GH_EMAIL=$GH_EMAIL
GRADSKY_TOKEN=$GRADSKY_TOKEN
GRADSKY_API=https://api.gradsky.com.br
GRADSKY_PROJECT_ID=$GRADSKY_PROJECT_ID
GRADSKY_PUBLIC_DOMAIN=$GRADSKY_PUBLIC_DOMAIN
GRADSKY_ATTACH_DOMAIN=$GRADSKY_ATTACH_DOMAIN
GRADSKY_VERIFY_DOMAIN=$GRADSKY_VERIFY_DOMAIN
GRADSKY_FORCE_DOMAIN=$GRADSKY_FORCE_DOMAIN
GRADSKY_GIT_AUTO_DEPLOY=$GRADSKY_GIT_AUTO_DEPLOY
GRADSKY_FORCE_DEPLOY=$GRADSKY_FORCE_DEPLOY
DOMINIO_BASE=$DOMINIO_BASE
=======
>>>>>>> e3f95ead324819de792d72b88e4ceac8037a42fb
EOF
  chmod 600 "$ENV_FILE"
  ok ".env escrito (modo 600)."
fi

# -------------------------------------------------------------
<<<<<<< HEAD
# 4. Garante diretÃ³rios do bot
=======
# 4. Garante diretórios do bot
>>>>>>> e3f95ead324819de792d72b88e4ceac8037a42fb
# -------------------------------------------------------------
mkdir -p "$BOT_DIR"/{inbox,sent,state,logs}

# -------------------------------------------------------------
# 5. Verifica auth do Claude
# -------------------------------------------------------------
echo
<<<<<<< HEAD
say "Verificando autenticaÃ§Ã£o do Claude Code..."
if claude --version >/dev/null 2>&1; then
  if ! claude --print "ping" --output-format text --max-turns 1 >/dev/null 2>&1; then
    warn "Claude CLI instalado mas nÃ£o consegui chamÃ¡-lo em modo headless."
    warn "Se vocÃª ainda nÃ£o logou, rode: claude /login"
    warn "(usa sua conta Pro/Max â€” abre URL pra colar no browser)"
=======
say "Verificando autenticação do Claude Code..."
if claude --version >/dev/null 2>&1; then
  if ! claude --print "ping" --output-format text --max-turns 1 >/dev/null 2>&1; then
    warn "Claude CLI instalado mas não consegui chamá-lo em modo headless."
    warn "Se você ainda não logou, rode: claude /login"
    warn "(usa sua conta Pro/Max — abre URL pra colar no browser)"
>>>>>>> e3f95ead324819de792d72b88e4ceac8037a42fb
  else
    ok "Claude CLI respondendo."
  fi
fi

# -------------------------------------------------------------
<<<<<<< HEAD
# 6. PM2 â€” sobe o bot
=======
# 6. PM2 — sobe o bot
>>>>>>> e3f95ead324819de792d72b88e4ceac8037a42fb
# -------------------------------------------------------------
echo
say "Configurando PM2 pro bot Telegram..."

BOT_NAME_LOWER="$(grep '^AGENT_NAME=' "$ENV_FILE" | head -1 | cut -d= -f2 | tr '[:upper:]' '[:lower:]')-bot"
BOT_NAME_LOWER="${BOT_NAME_LOWER:-animus-bot}"

<<<<<<< HEAD
# Remove instÃ¢ncia antiga se existir, pra comeÃ§ar limpo
=======
# Remove instância antiga se existir, pra começar limpo
>>>>>>> e3f95ead324819de792d72b88e4ceac8037a42fb
pm2 delete "$BOT_NAME_LOWER" 2>/dev/null || true

pm2 start "$BOT_DIR/bot.py" \
  --name "$BOT_NAME_LOWER" \
  --interpreter python3 \
  --time \
  --log "$BOT_DIR/logs/pm2.log" \
  --merge-logs

<<<<<<< HEAD
# Salva a lista de processos do PM2 para restauracao quando o container reiniciar
pm2 save >/dev/null || true
=======
pm2 save >/dev/null

# Tenta habilitar startup do PM2 (sem systemd, no Gradsky vai apenas imprimir o comando)
pm2 startup 2>/dev/null | tail -5 || true
>>>>>>> e3f95ead324819de792d72b88e4ceac8037a42fb

ok "Bot iniciado via PM2 como '$BOT_NAME_LOWER'."

# -------------------------------------------------------------
# 7. Resumo
# -------------------------------------------------------------
echo
printf "${c_green}===============================================${c_reset}\n"
<<<<<<< HEAD
printf "${c_green} InstalaÃ§Ã£o concluÃ­da.${c_reset}\n"
printf "${c_green}===============================================${c_reset}\n"
echo
echo "Comandos Ãºteis:"
echo "  pm2 status                        # status do bot"
echo "  pm2 logs $BOT_NAME_LOWER          # logs ao vivo"
echo "  pm2 restart $BOT_NAME_LOWER       # restart"
echo "  tail -f $BOT_DIR/logs/bot.log     # log da aplicaÃ§Ã£o"
echo
echo "Teste:"
echo "  Mande uma mensagem pro bot no Telegram. VocÃª deve receber o ack 'Anotado, chefe...'"
echo "  e em seguida a resposta gerada pelo Claude."
echo

=======
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
>>>>>>> e3f95ead324819de792d72b88e4ceac8037a42fb
