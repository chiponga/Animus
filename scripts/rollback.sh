#!/bin/bash
# Restaura backup do Animus.

set -euo pipefail

REPO_DIR="${ANIMUS_REPO_DIR:-/workspace/Animus}"
BACKUP_DIR="${1:-$(cat /root/.animus-last-backup 2>/dev/null || true)}"

log() { echo "[rollback] $*"; }
warn() { echo "[rollback] WARN: $*" >&2; }
err() { echo "[rollback] ERROR: $*" >&2; exit 1; }

[ -n "$BACKUP_DIR" ] || err "Informe o backup: bash scripts/rollback.sh /caminho/backup"
[ -d "$BACKUP_DIR" ] || err "Backup nao encontrado: $BACKUP_DIR"
[ -d "$REPO_DIR" ] || err "Repo nao encontrado: $REPO_DIR"

log "Backup: $BACKUP_DIR"
log "Repo: $REPO_DIR"

if [ "${ANIMUS_FORCE_ROLLBACK:-0}" != "1" ]; then
  read -r -p "Confirmar rollback? digite YES: " ANSWER
  [ "$ANSWER" = "YES" ] || err "Cancelado"
fi

if command -v pm2 >/dev/null 2>&1; then
  pm2 stop animus-bot 2>/dev/null || warn "animus-bot nao estava rodando"
fi

[ -f "$BACKUP_DIR/.env" ] && cp "$BACKUP_DIR/.env" "$REPO_DIR/.env" && chmod 600 "$REPO_DIR/.env"

if [ -d "$BACKUP_DIR/agents" ]; then
  mkdir -p "$REPO_DIR/.claude"
  rm -rf "$REPO_DIR/.claude/agents"
  cp -a "$BACKUP_DIR/agents" "$REPO_DIR/.claude/agents"
fi

[ -d "$BACKUP_DIR/bot-state" ] && mkdir -p "$REPO_DIR/animus-bot/state" && cp -a "$BACKUP_DIR/bot-state/." "$REPO_DIR/animus-bot/state/"
[ -d "$BACKUP_DIR/memory" ] && rm -rf "$REPO_DIR/memory" && cp -a "$BACKUP_DIR/memory" "$REPO_DIR/memory"
[ -d "$BACKUP_DIR/learnings" ] && rm -rf "$REPO_DIR/.learnings" && cp -a "$BACKUP_DIR/learnings" "$REPO_DIR/.learnings"

if command -v pm2 >/dev/null 2>&1; then
  pm2 restart animus-bot 2>/dev/null || warn "PM2 sem instancia. Rode bash install.sh"
fi

log "Rollback concluido"
