#!/bin/bash
# Atualiza uma instalacao Animus existente.

set -euo pipefail

REPO_DIR="${ANIMUS_REPO_DIR:-/workspace/Animus}"
BRANCH="${ANIMUS_UPGRADE_BRANCH:-main}"
DO_BACKUP=1

while [ $# -gt 0 ]; do
  case "$1" in
    --branch) BRANCH="$2"; shift 2 ;;
    --no-backup) DO_BACKUP=0; shift ;;
    *) echo "Uso: bash scripts/upgrade.sh [--branch main] [--no-backup]" >&2; exit 1 ;;
  esac
done

log() { echo "[upgrade] $*"; }
warn() { echo "[upgrade] WARN: $*" >&2; }
err() { echo "[upgrade] ERROR: $*" >&2; exit 1; }

[ -d "$REPO_DIR/.git" ] || err "$REPO_DIR nao e um repo git"

log "Animus upgrade - $(date)"

if [ "$DO_BACKUP" = "1" ] && [ -f "$REPO_DIR/scripts/backup.sh" ]; then
  bash "$REPO_DIR/scripts/backup.sh" >/dev/null || warn "backup falhou"
fi

cd "$REPO_DIR"

CURRENT_SHA="$(git rev-parse --short HEAD 2>/dev/null || echo unknown)"
log "Versao atual: $CURRENT_SHA"

git fetch origin "$BRANCH"

STASHED=0
if ! git diff --quiet || ! git diff --cached --quiet; then
  warn "Mudancas locais detectadas, fazendo stash"
  git stash push -u -m "animus-upgrade-$(date +%Y%m%d-%H%M%S)" >/dev/null
  STASHED=1
fi

git checkout "$BRANCH"
git pull --ff-only origin "$BRANCH"

if [ "$STASHED" = "1" ]; then
  git stash pop || warn "Stash com conflito. Verifique git status"
fi

bash "$REPO_DIR/bootstrap.sh" || warn "bootstrap reportou problemas"

mkdir -p "$REPO_DIR/.claude"
ln -sfn ../skills "$REPO_DIR/.claude/skills"

if command -v pm2 >/dev/null 2>&1; then
  pm2 restart animus-bot 2>/dev/null || warn "animus-bot nao estava no PM2"
fi

bash "$REPO_DIR/scripts/validate.sh" || warn "validacao reportou problemas"

log "Upgrade concluido: $(git rev-parse --short HEAD)"
