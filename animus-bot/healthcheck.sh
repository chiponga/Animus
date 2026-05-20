#!/usr/bin/env bash
set -euo pipefail

# Healthcheck do Animus em Gradsky + PM2 + Claude Code.
# Pode ser chamado manualmente ou por automacao do container.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
ENV_FILE="${ANIMUS_ENV_FILE:-$REPO_DIR/.env}"
LOG_DIR="$SCRIPT_DIR/logs"
LOG="$LOG_DIR/healthcheck.log"
BOT_NAME="${ANIMUS_PM2_NAME:-animus-bot}"

mkdir -p "$LOG_DIR"

now() { date '+%Y-%m-%d %H:%M:%S'; }
log() { echo "[$(now)] $*" | tee -a "$LOG" >/dev/null; }

fail() {
  log "FAIL - $*"
  exit 1
}

cd "$REPO_DIR"

[ -f "$ENV_FILE" ] || fail ".env nao encontrado em $ENV_FILE"
command -v pm2 >/dev/null || fail "pm2 nao encontrado"
command -v claude >/dev/null || fail "claude CLI nao encontrado"

if ! pm2 describe "$BOT_NAME" >/dev/null 2>&1; then
  log "PM2 nao conhece $BOT_NAME. Tentando iniciar."
  pm2 start animus-bot/bot.py \
    --name "$BOT_NAME" \
    --interpreter python3 \
    --time \
    --log animus-bot/logs/pm2.log \
    --merge-logs >/dev/null
  pm2 save >/dev/null || true
fi

STATUS="$(pm2 jlist 2>/dev/null | node -e "let s='';process.stdin.on('data',d=>s+=d);process.stdin.on('end',()=>{const name=process.argv[1];const arr=JSON.parse(s||'[]');const p=arr.find(x=>x.name===name);console.log(p?.pm2_env?.status||'missing')})" "$BOT_NAME")"

if [ "$STATUS" != "online" ]; then
  log "PM2 status de $BOT_NAME = $STATUS. Reiniciando."
  pm2 restart "$BOT_NAME" >/dev/null
  sleep 3
fi

STATUS="$(pm2 jlist 2>/dev/null | node -e "let s='';process.stdin.on('data',d=>s+=d);process.stdin.on('end',()=>{const name=process.argv[1];const arr=JSON.parse(s||'[]');const p=arr.find(x=>x.name===name);console.log(p?.pm2_env?.status||'missing')})" "$BOT_NAME")"
[ "$STATUS" = "online" ] || fail "$BOT_NAME nao ficou online no PM2"

claude --version >/dev/null 2>&1 || fail "claude CLI nao respondeu"

log "OK - $BOT_NAME online, repo=$REPO_DIR"
