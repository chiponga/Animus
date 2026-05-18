#!/bin/bash
# =============================================================
# bootstrap.sh — instala dependências do agente Animus (Gradsky)
# =============================================================
# Container Gradsky:
#   - sem systemd, sem sudo (já é root no container)
#   - PM2 como process manager
#   - Postgres remoto (Supabase) — NÃO instala postgres local
#   - HTTPS quem cuida é o provedor — NÃO instala Caddy
#
# Idempotente: pode rodar várias vezes sem quebrar nada.
#
# Uso:
#   bash bootstrap.sh
# =============================================================

set -euo pipefail

log() { printf '\033[1;36m>> %s\033[0m\n' "$*"; }
ok()  { printf '\033[1;32m✓ %s\033[0m\n' "$*"; }
warn() { printf '\033[1;33m! %s\033[0m\n' "$*" >&2; }

# Detecta SO; container Gradsky é Debian/Ubuntu
if ! command -v apt-get >/dev/null 2>&1; then
  warn "Esse bootstrap foi escrito pra container Gradsky (Debian/Ubuntu)."
  warn "Detectado SO sem apt-get — abortando."
  exit 1
fi

export DEBIAN_FRONTEND=noninteractive

# -------------------------------------------------------------
# Sistema base
# -------------------------------------------------------------
log "Atualizando lista de pacotes..."
apt-get update -qq

log "Instalando pacotes base (python, ffmpeg, git, curl, tmux, build tools)..."
apt-get install -y -qq \
  curl git ca-certificates build-essential unzip \
  python3 python3-pip python3-venv \
  ffmpeg tmux lsof jq >/dev/null

# -------------------------------------------------------------
# Python — libs do bot
# -------------------------------------------------------------
log "Instalando libs Python (requests)..."
pip3 install --quiet --break-system-packages requests 2>/dev/null \
  || pip3 install --quiet requests
ok "Python deps prontas."

# -------------------------------------------------------------
# Node 22 via NodeSource (mais previsível que nvm pra PM2 global)
# -------------------------------------------------------------
NODE_OK=0
if command -v node >/dev/null 2>&1; then
  NODE_MAJOR="$(node -v | sed 's/v\([0-9]*\).*/\1/')"
  if [[ "$NODE_MAJOR" -ge 22 ]]; then
    NODE_OK=1
  fi
fi

if [[ "$NODE_OK" -eq 0 ]]; then
  log "Instalando Node 22 via NodeSource..."
  curl -fsSL https://deb.nodesource.com/setup_22.x | bash - >/dev/null
  apt-get install -y -qq nodejs >/dev/null
fi
ok "Node $(node -v) / npm $(npm -v)"

# -------------------------------------------------------------
# PM2
# -------------------------------------------------------------
if ! command -v pm2 >/dev/null 2>&1; then
  log "Instalando PM2 globalmente..."
  npm install -g --silent pm2 >/dev/null
fi
ok "PM2 $(pm2 -v)"

# -------------------------------------------------------------
# Claude Code CLI
# -------------------------------------------------------------
if ! command -v claude >/dev/null 2>&1; then
  log "Instalando Claude Code CLI (@anthropic-ai/claude-code)..."
  npm install -g --silent @anthropic-ai/claude-code >/dev/null
fi
ok "Claude CLI: $(claude --version 2>/dev/null || echo 'instalado')"

# -------------------------------------------------------------
# GitHub CLI (opcional, mas útil pro agente entregar projetos)
# -------------------------------------------------------------
if ! command -v gh >/dev/null 2>&1; then
  log "Instalando GitHub CLI..."
  curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg \
    | gpg --dearmor -o /usr/share/keyrings/githubcli-archive-keyring.gpg 2>/dev/null
  chmod go+r /usr/share/keyrings/githubcli-archive-keyring.gpg
  echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" \
    > /etc/apt/sources.list.d/github-cli.list
  apt-get update -qq
  apt-get install -y -qq gh >/dev/null || warn "Falha ao instalar gh — segue sem ele."
fi
command -v gh >/dev/null 2>&1 && ok "gh $(gh --version | head -1 | awk '{print $3}')"

echo
ok "Bootstrap concluído."
echo
echo "Versões instaladas:"
printf '  Node     '; node --version
printf '  npm      v%s\n' "$(npm --version)"
printf '  Python   '; python3 --version
printf '  ffmpeg   '; ffmpeg -version 2>/dev/null | head -1 | awk '{print $3}'
printf '  Claude   '; claude --version 2>/dev/null || echo '(checar com `claude --version`)'
printf '  PM2      v%s\n' "$(pm2 -v)"
command -v gh >/dev/null 2>&1 && printf '  gh       %s\n' "$(gh --version | head -1 | awk '{print $3}')"
echo
echo "Próximo: rode 'bash install.sh' pra configurar o agente."
