#!/bin/bash
# Backup completo do Animus antes de upgrade/restore.

set -euo pipefail

REPO_DIR="${ANIMUS_REPO_DIR:-/workspace/Animus}"
BACKUP_ROOT="${ANIMUS_BACKUP_ROOT:-/workspace/backups/animus}"
TIMESTAMP="$(date +%Y%m%d-%H%M%S)"
BACKUP_DIR="$BACKUP_ROOT/$TIMESTAMP"

log() { echo "[backup] $*"; }
err() { echo "[backup] ERROR: $*" >&2; exit 1; }

[ -d "$REPO_DIR" ] || err "ANIMUS_REPO_DIR nao existe: $REPO_DIR"

mkdir -p "$BACKUP_DIR"

log "Salvando em $BACKUP_DIR"

[ -f "$REPO_DIR/.env" ] && cp "$REPO_DIR/.env" "$BACKUP_DIR/.env" && chmod 600 "$BACKUP_DIR/.env"
[ -d "$REPO_DIR/.claude/agents" ] && cp -a "$REPO_DIR/.claude/agents" "$BACKUP_DIR/agents"
[ -d "$REPO_DIR/animus-bot/state" ] && cp -a "$REPO_DIR/animus-bot/state" "$BACKUP_DIR/bot-state"
[ -d "$REPO_DIR/memory" ] && cp -a "$REPO_DIR/memory" "$BACKUP_DIR/memory"
[ -d "$REPO_DIR/.learnings" ] && cp -a "$REPO_DIR/.learnings" "$BACKUP_DIR/learnings"

if [ -d "$REPO_DIR/skills" ]; then
  {
    echo "# Skills snapshot - $TIMESTAMP"
    find "$REPO_DIR/skills" -maxdepth 2 -name SKILL.md -print | sort
  } > "$BACKUP_DIR/skills-snapshot.txt"
fi

if command -v pm2 >/dev/null 2>&1; then
  pm2 jlist > "$BACKUP_DIR/pm2-jlist.json" 2>/dev/null || true
fi

if [ -d "$REPO_DIR/.git" ]; then
  git -C "$REPO_DIR" status --short > "$BACKUP_DIR/git-status.txt" 2>/dev/null || true
  git -C "$REPO_DIR" rev-parse HEAD > "$BACKUP_DIR/git-head.txt" 2>/dev/null || true
fi

cat > "$BACKUP_DIR/metadata.txt" <<EOF
timestamp=$TIMESTAMP
repo_dir=$REPO_DIR
backup_dir=$BACKUP_DIR
EOF

echo "$BACKUP_DIR" > /root/.animus-last-backup 2>/dev/null || true
log "Backup concluido"
echo "$BACKUP_DIR"
