#!/bin/bash
# =============================================================
# upgrade.sh — Atualiza Animus existente para versão mais nova
# =============================================================
# Idempotente: pode rodar várias vezes sem quebrar.
# Faz backup automático antes de aplicar.
# Detecta o que mudou no repo (git pull) e re-aplica:
#   1) bootstrap (idempotente)
#   2) symlink .claude/skills
#   3) deps Python/Node novas
#   4) pm2 restart
#   5) validação
#
# Uso:
#   bash scripts/upgrade.sh                 # upgrade da branch atual
#   bash scripts/upgrade.sh --branch main   # força branch específica
#   bash scripts/upgrade.sh --no-backup     # pula backup (não recomendado)
# =============================================================

set -euo pipefail

GREEN='\033[0;32m'; YELLOW='\033[1;33m'; RED='\033[0;31m'; CYAN='\033[1;36m'; NC='\033[0m'

log()  { echo -e "${GREEN}[$(date +'%H:%M:%S')]${NC} $1"; }
warn() { echo -e "${YELLOW}[AVISO]${NC} $1" >&2; }
err()  { echo -e "${RED}[ERRO]${NC} $1" >&2; }
step() { echo -e "${CYAN}>> $1${NC}"; }

REPO_DIR="${ANIMUS_REPO_DIR:-/workspace/Animus}"
DO_BACKUP=1
BRANCH=""

while [ $# -gt 0 ]; do
  case "$1" in
    --no-backup) DO_BACKUP=0; shift ;;
    --branch) BRANCH="$2"; shift 2 ;;
    *) err "Flag desconhecida: $1"; exit 1 ;;
  esac
done

if [ ! -d "$REPO_DIR/.git" ]; then
  err "$REPO_DIR não é um repo git. Esse script é só pra upgrades de instalação git-cloned."
  exit 1
fi

step "Animus upgrade — $(date)"
log "Repo: $REPO_DIR"

cd "$REPO_DIR"

# 1. Versão atual
CURRENT_SHA=$(git rev-parse --short HEAD)
CURRENT_MSG=$(git log -1 --format='%s')
log "Versão atual: $CURRENT_SHA — $CURRENT_MSG"

# 2. Backup
if [ "$DO_BACKUP" = "1" ]; then
  step "1/5 Backup..."
  bash "$REPO_DIR/scripts/backup.sh" >/dev/null
  log "  ✓ Backup salvo em $(cat /root/.animus-last-backup)"
else
  warn "Pulando backup (--no-backup). Risco seu."
fi

# 3. Pull
step "2/5 Atualizando código..."
git fetch origin --quiet
if [ -n "$BRANCH" ]; then
  git checkout "$BRANCH"
fi
CURRENT_BRANCH=$(git rev-parse --abbrev-ref HEAD)
log "  Branch: $CURRENT_BRANCH"

# Stash mudanças locais não-commitadas (preserva .env etc)
if ! git diff --quiet || ! git diff --cached --quiet; then
  warn "  Mudanças locais detectadas, fazendo stash..."
  git stash push -m "animus-upgrade-$(date +%s)" --include-untracked
  STASHED=1
else
  STASHED=0
fi

# Pull
git pull --ff-only origin "$CURRENT_BRANCH" 2>&1 | tail -3 || {
  err "git pull falhou — pode ser conflito ou fast-forward não possível."
  err "Resolva manualmente e rode upgrade.sh de novo."
  [ "$STASHED" = "1" ] && git stash pop
  exit 1
}

# Recupera stash se houve
if [ "$STASHED" = "1" ]; then
  git stash pop 2>&1 | tail -3 || warn "Stash com conflito — verifique \`git stash list\`"
fi

NEW_SHA=$(git rev-parse --short HEAD)
NEW_MSG=$(git log -1 --format='%s')
if [ "$CURRENT_SHA" = "$NEW_SHA" ]; then
  log "Já estava na versão mais recente. Continuando pra reaplicar setup..."
else
  log "Atualizado: $CURRENT_SHA → $NEW_SHA — $NEW_MSG"
fi

# 4. Reaplica setup (idempotente)
step "3/5 Reaplicando bootstrap..."
bash "$REPO_DIR/bootstrap.sh" 2>&1 | tail -5

# 5. Garante symlink .claude/skills
if [ -d "$REPO_DIR/skills" ] && [ ! -e "$REPO_DIR/.claude/skills" ]; then
  mkdir -p "$REPO_DIR/.claude"
  (cd "$REPO_DIR/.claude" && ln -sfn ../skills skills)
  log "  ✓ Symlink .claude/skills recriado"
fi

# 6. Restart bot
step "4/5 Reiniciando bot..."
if command -v pm2 >/dev/null 2>&1; then
  pm2 restart animus-bot --update-env 2>/dev/null \
    || warn "Bot não estava no PM2 — rode bash install.sh"
  sleep 2
fi

# 7. Valida
step "5/5 Validando..."
if [ -x "$REPO_DIR/scripts/validate.sh" ]; then
  bash "$REPO_DIR/scripts/validate.sh" || warn "Validação reportou problemas — veja acima"
fi

step "✓ Upgrade concluído"
log "Versão atual: $(git rev-parse --short HEAD) — $(git log -1 --format='%s')"
log "Backup pra rollback: $(cat /root/.animus-last-backup 2>/dev/null || echo 'sem backup')"
echo
log "Se algo quebrou: bash $REPO_DIR/scripts/rollback.sh"
