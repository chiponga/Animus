#!/bin/bash
# =============================================================
# backup.sh — Backup completo do Animus antes de upgrade/restore
# =============================================================
# Cria backup com timestamp em /root/animus-backup-<ts>/
# Inclui: .env, .claude/agents/, skills/ (só metadados), animus-bot/{state,logs}/,
#         memory/, .learnings/, lista de pacotes PM2
#
# Saída: imprime path do backup no stdout, salva em /root/.animus-last-backup
# =============================================================

set -euo pipefail

GREEN='\033[0;32m'; YELLOW='\033[1;33m'; RED='\033[0;31m'; NC='\033[0m'

log()  { echo -e "${GREEN}[$(date +'%H:%M:%S')]${NC} $1"; }
warn() { echo -e "${YELLOW}[AVISO]${NC} $1" >&2; }
err()  { echo -e "${RED}[ERRO]${NC} $1" >&2; }

REPO_DIR="${ANIMUS_REPO_DIR:-/workspace/Animus}"
if [ ! -d "$REPO_DIR" ]; then
  err "ANIMUS_REPO_DIR não existe: $REPO_DIR"
  exit 1
fi

TIMESTAMP=$(date +'%Y%m%d-%H%M%S')
BACKUP_DIR="/root/animus-backup-$TIMESTAMP"
mkdir -p "$BACKUP_DIR"

log "Backup em $BACKUP_DIR"

# 1. .env (somente se existir; preservar permissão 600)
if [ -f "$REPO_DIR/.env" ]; then
  cp -a "$REPO_DIR/.env" "$BACKUP_DIR/env.bak"
  log "  ✓ .env"
fi

# 2. Agents (.claude/agents/)
if [ -d "$REPO_DIR/.claude/agents" ]; then
  cp -a "$REPO_DIR/.claude/agents" "$BACKUP_DIR/agents"
  log "  ✓ .claude/agents ($(ls "$BACKUP_DIR/agents" | wc -l) arquivos)"
fi

# 3. Lista de skills (só nome + frontmatter, não conteúdo todo)
if [ -d "$REPO_DIR/skills" ]; then
  {
    echo "# Skills snapshot — $TIMESTAMP"
    echo
    for d in "$REPO_DIR/skills"/*/; do
      name=$(basename "$d")
      desc=$(awk '/^---$/{c++; if(c==2) exit} c==1 && /^description:/ {sub(/^description: */,""); print}' "$d/SKILL.md" 2>/dev/null | head -1)
      echo "- $name: ${desc:0:120}"
    done
  } > "$BACKUP_DIR/skills-snapshot.md"
  log "  ✓ skills snapshot ($(ls -d "$REPO_DIR/skills"/*/ | wc -l) skills)"
fi

# 4. Estado do bot (mas NÃO logs gigantes)
if [ -d "$REPO_DIR/animus-bot/state" ]; then
  cp -a "$REPO_DIR/animus-bot/state" "$BACKUP_DIR/bot-state" 2>/dev/null || true
fi

# 5. Memory e learnings (se existirem — são opcionais)
[ -d "$REPO_DIR/memory" ] && cp -a "$REPO_DIR/memory" "$BACKUP_DIR/memory"
[ -d "$REPO_DIR/.learnings" ] && cp -a "$REPO_DIR/.learnings" "$BACKUP_DIR/learnings"

# 6. PM2 state
if command -v pm2 >/dev/null 2>&1; then
  pm2 jlist > "$BACKUP_DIR/pm2-state.json" 2>/dev/null || true
  log "  ✓ pm2 state"
fi

# 7. Git state
if (cd "$REPO_DIR" && git rev-parse HEAD >/dev/null 2>&1); then
  (cd "$REPO_DIR" && git log -1 --format='%H %s' > "$BACKUP_DIR/git-head.txt")
  (cd "$REPO_DIR" && git status --porcelain > "$BACKUP_DIR/git-status.txt")
  log "  ✓ git state"
fi

# 8. Metadata
cat > "$BACKUP_DIR/metadata.json" <<EOF
{
  "timestamp": "$TIMESTAMP",
  "repo_dir": "$REPO_DIR",
  "hostname": "$(hostname)",
  "user": "$(whoami)",
  "claude_version": "$(claude --version 2>/dev/null | head -1 || echo unknown)",
  "node_version": "$(node --version 2>/dev/null || echo unknown)",
  "python_version": "$(python3 --version 2>/dev/null | awk '{print $2}' || echo unknown)"
}
EOF

# 9. Pointer pro último backup
echo "$BACKUP_DIR" > /root/.animus-last-backup

# Saída
log "Backup OK: $BACKUP_DIR"
echo "$BACKUP_DIR"
