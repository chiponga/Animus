#!/bin/bash
# =============================================================
# bootstrap.sh - install Animus dependencies for Gradsky
# =============================================================

set -euo pipefail

log() { printf '\033[1;36m>> %s\033[0m\n' "$*"; }
ok()  { printf '\033[1;32mOK %s\033[0m\n' "$*"; }
warn() { printf '\033[1;33m! %s\033[0m\n' "$*" >&2; }

if ! command -v apt-get >/dev/null 2>&1; then
  warn "This bootstrap expects a Debian/Ubuntu Gradsky container."
  exit 1
fi

export DEBIAN_FRONTEND=noninteractive

log "Updating package list..."
apt-get update -qq

log "Installing base packages..."
apt-get install -y -qq \
  curl git ca-certificates build-essential unzip \
  python3 python3-pip python3-venv \
  ffmpeg lsof jq >/dev/null

log "Installing Python dependencies..."
pip3 install --quiet --break-system-packages requests pandas 2>/dev/null \
  || pip3 install --quiet requests pandas
ok "Python dependencies ready."

NODE_OK=0
if command -v node >/dev/null 2>&1; then
  NODE_MAJOR="$(node -v | sed 's/v\([0-9]*\).*/\1/')"
  if [[ "$NODE_MAJOR" -ge 22 ]]; then
    NODE_OK=1
  fi
fi

if [[ "$NODE_OK" -eq 0 ]]; then
  log "Installing Node 22..."
  curl -fsSL https://deb.nodesource.com/setup_22.x | bash - >/dev/null
  apt-get install -y -qq nodejs >/dev/null
fi
ok "Node $(node -v) / npm $(npm -v)"

if ! command -v pm2 >/dev/null 2>&1; then
  log "Installing PM2..."
  npm install -g --silent pm2 >/dev/null
fi
ok "PM2 $(pm2 -v)"

if ! command -v bun >/dev/null 2>&1; then
  log "Installing Bun..."
  curl -fsSL https://bun.sh/install | bash >/dev/null
  export BUN_INSTALL="${BUN_INSTALL:-$HOME/.bun}"
  export PATH="$BUN_INSTALL/bin:$PATH"
fi
command -v bun >/dev/null 2>&1 && ok "Bun $(bun --version)" || warn "Bun not available after install."

if ! command -v claude >/dev/null 2>&1; then
  log "Installing Claude Code CLI..."
  npm install -g --silent @anthropic-ai/claude-code >/dev/null
fi
ok "Claude CLI: $(claude --version 2>/dev/null || echo installed)"

if ! command -v gh >/dev/null 2>&1; then
  log "Installing GitHub CLI..."
  curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg \
    | gpg --dearmor -o /usr/share/keyrings/githubcli-archive-keyring.gpg 2>/dev/null || true
  chmod go+r /usr/share/keyrings/githubcli-archive-keyring.gpg 2>/dev/null || true
  echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" \
    > /etc/apt/sources.list.d/github-cli.list
  apt-get update -qq
  apt-get install -y -qq gh >/dev/null || warn "Could not install gh; continuing."
fi
command -v gh >/dev/null 2>&1 && ok "gh $(gh --version | head -1 | awk '{print $3}')"

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

if [[ -d "$REPO_DIR/apps/gaby-agent-runtime" && -f "$REPO_DIR/apps/gaby-agent-runtime/package.json" ]]; then
  log "Installing gaby-agent-runtime dependencies..."
  if command -v bun >/dev/null 2>&1; then
    (cd "$REPO_DIR/apps/gaby-agent-runtime" && bun install) || warn "gaby-agent-runtime bun install failed."
  else
    (cd "$REPO_DIR/apps/gaby-agent-runtime" && npm install --silent --no-audit --no-fund) || warn "gaby-agent-runtime npm install failed."
  fi
fi

if [[ -d "$REPO_DIR/skills" && ! -e "$REPO_DIR/.claude/skills" ]]; then
  log "Creating .claude/skills symlink..."
  mkdir -p "$REPO_DIR/.claude"
  (cd "$REPO_DIR/.claude" && ln -sfn ../skills skills)
fi

echo
ok "Bootstrap complete."
echo "Next: run 'bash install.sh'."
