<<<<<<< HEAD
﻿#!/bin/bash
# =============================================================
# rollback.sh â€” Restaura backup do Animus
# =============================================================
# Uso:
#   bash scripts/rollback.sh                  # restaura o backup mais recente
#   bash scripts/rollback.sh /caminho/backup  # restaura backup especÃ­fico
=======
#!/bin/bash
# =============================================================
# rollback.sh — Restaura backup do Animus
# =============================================================
# Uso:
#   bash scripts/rollback.sh                  # restaura o backup mais recente
#   bash scripts/rollback.sh /caminho/backup  # restaura backup específico
>>>>>>> e3f95ead324819de792d72b88e4ceac8037a42fb
#
# 5 passos: 1) para bot, 2) restaura .env, 3) restaura agents,
#           4) restaura state/memory/learnings, 5) reinicia bot
# =============================================================

set -euo pipefail

GREEN='\033[0;32m'; YELLOW='\033[1;33m'; RED='\033[0;31m'; NC='\033[0m'

log()  { echo -e "${GREEN}[$(date +'%H:%M:%S')]${NC} $1"; }
warn() { echo -e "${YELLOW}[AVISO]${NC} $1" >&2; }
err()  { echo -e "${RED}[ERRO]${NC} $1" >&2; }

REPO_DIR="${ANIMUS_REPO_DIR:-/workspace/Animus}"
BACKUP_DIR="${1:-}"

# Resolver backup
if [ -z "$BACKUP_DIR" ]; then
  if [ -f /root/.animus-last-backup ]; then
    BACKUP_DIR=$(cat /root/.animus-last-backup)
  else
    BACKUP_DIR=$(ls -td /root/animus-backup-* 2>/dev/null | head -1 || true)
  fi
fi

if [ -z "$BACKUP_DIR" ] || [ ! -d "$BACKUP_DIR" ]; then
  err "Nenhum backup encontrado. Procurei em /root/.animus-last-backup e /root/animus-backup-*"
  exit 1
fi

log "Restaurando de: $BACKUP_DIR"

<<<<<<< HEAD
# Mostra metadata pra confirmaÃ§Ã£o
=======
# Mostra metadata pra confirmação
>>>>>>> e3f95ead324819de792d72b88e4ceac8037a42fb
if [ -f "$BACKUP_DIR/metadata.json" ]; then
  log "Metadata do backup:"
  cat "$BACKUP_DIR/metadata.json" | sed 's/^/    /'
fi

<<<<<<< HEAD
# ConfirmaÃ§Ã£o nÃ£o-interativa se ANIMUS_FORCE_ROLLBACK=1
=======
# Confirmação não-interativa se ANIMUS_FORCE_ROLLBACK=1
>>>>>>> e3f95ead324819de792d72b88e4ceac8037a42fb
if [ "${ANIMUS_FORCE_ROLLBACK:-0}" != "1" ]; then
  read -r -p "Confirmar rollback? [y/N]: " resp
  if [[ ! "$resp" =~ ^[Yy]$ ]]; then
    log "Rollback cancelado."
    exit 0
  fi
fi

# Passo 1: parar bot
log "1/5 Parando bot..."
if command -v pm2 >/dev/null 2>&1; then
<<<<<<< HEAD
  pm2 stop animus-bot 2>/dev/null || warn "Bot nÃ£o estava rodando"
=======
  pm2 stop animus-telegram-bot 2>/dev/null || pm2 stop animus-bot 2>/dev/null || warn "Bot não estava rodando"
>>>>>>> e3f95ead324819de792d72b88e4ceac8037a42fb
fi

# Passo 2: restaurar .env
log "2/5 Restaurando .env..."
if [ -f "$BACKUP_DIR/env.bak" ]; then
  cp -a "$BACKUP_DIR/env.bak" "$REPO_DIR/.env"
  chmod 600 "$REPO_DIR/.env"
<<<<<<< HEAD
  log "  âœ“ .env restaurado"
else
  warn "  ! .env nÃ£o estava no backup, mantendo o atual"
=======
  log "  ✓ .env restaurado"
else
  warn "  ! .env não estava no backup, mantendo o atual"
>>>>>>> e3f95ead324819de792d72b88e4ceac8037a42fb
fi

# Passo 3: restaurar agents
log "3/5 Restaurando agents..."
if [ -d "$BACKUP_DIR/agents" ]; then
  rm -rf "$REPO_DIR/.claude/agents.rollback" 2>/dev/null || true
  [ -d "$REPO_DIR/.claude/agents" ] && mv "$REPO_DIR/.claude/agents" "$REPO_DIR/.claude/agents.rollback"
  cp -a "$BACKUP_DIR/agents" "$REPO_DIR/.claude/agents"
<<<<<<< HEAD
  log "  âœ“ agents restaurados ($(ls "$REPO_DIR/.claude/agents" | wc -l) arquivos)"
=======
  log "  ✓ agents restaurados ($(ls "$REPO_DIR/.claude/agents" | wc -l) arquivos)"
>>>>>>> e3f95ead324819de792d72b88e4ceac8037a42fb
fi

# Passo 4: restaurar state/memory/learnings
log "4/5 Restaurando estado..."
<<<<<<< HEAD
[ -d "$BACKUP_DIR/bot-state" ] && cp -a "$BACKUP_DIR/bot-state/." "$REPO_DIR/animus-bot/state/" 2>/dev/null && log "  âœ“ bot state"
[ -d "$BACKUP_DIR/memory" ] && cp -a "$BACKUP_DIR/memory" "$REPO_DIR/memory" 2>/dev/null && log "  âœ“ memory"
[ -d "$BACKUP_DIR/learnings" ] && cp -a "$BACKUP_DIR/learnings" "$REPO_DIR/.learnings" 2>/dev/null && log "  âœ“ learnings"
=======
[ -d "$BACKUP_DIR/bot-state" ] && cp -a "$BACKUP_DIR/bot-state/." "$REPO_DIR/animus-bot/state/" 2>/dev/null && log "  ✓ bot state"
[ -d "$BACKUP_DIR/memory" ] && cp -a "$BACKUP_DIR/memory" "$REPO_DIR/memory" 2>/dev/null && log "  ✓ memory"
[ -d "$BACKUP_DIR/learnings" ] && cp -a "$BACKUP_DIR/learnings" "$REPO_DIR/.learnings" 2>/dev/null && log "  ✓ learnings"
>>>>>>> e3f95ead324819de792d72b88e4ceac8037a42fb

# Passo 5: subir bot
log "5/5 Reiniciando bot..."
if command -v pm2 >/dev/null 2>&1; then
<<<<<<< HEAD
  pm2 restart animus-bot 2>/dev/null || warn "PM2 sem instÃ¢ncia â€” rode bash install.sh"
=======
  pm2 restart animus-telegram-bot 2>/dev/null || pm2 restart animus-bot 2>/dev/null || warn "PM2 sem instância — rode bash install.sh"
>>>>>>> e3f95ead324819de792d72b88e4ceac8037a42fb
fi

log "Rollback OK. Backup que estava ativo agora em .claude/agents.rollback (se precisar reverter)"
log "Pra ver status: pm2 status"
<<<<<<< HEAD

=======
>>>>>>> e3f95ead324819de792d72b88e4ceac8037a42fb
