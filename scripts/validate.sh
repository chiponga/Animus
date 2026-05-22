#!/bin/bash
# Smoke test do Animus.

set -uo pipefail

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
CYAN='\033[1;36m'
NC='\033[0m'

FAILS=0
REPO_DIR="${ANIMUS_REPO_DIR:-/workspace/Animus}"

ok() { echo -e "${GREEN}  OK${NC} $1"; }
warn() { echo -e "${YELLOW}  WARN${NC} $1"; FAILS=$((FAILS + 1)); }
fail() { echo -e "${RED}  FAIL${NC} $1"; FAILS=$((FAILS + 1)); }
hdr() { echo -e "${CYAN}>> $1${NC}"; }

hdr "Animus validate - $(date)"
echo

hdr "1. PM2 bot"
if command -v pm2 >/dev/null 2>&1; then
  if pm2 jlist 2>/dev/null | python3 -c "import json,sys; ps=json.load(sys.stdin); names=[p['name'] for p in ps if p.get('pm2_env',{}).get('status')=='online']; sys.exit(0 if any('bot' in n.lower() for n in names) else 1)" 2>/dev/null; then
    ok "PM2 com bot online"
  else
    fail "Nenhum bot online no PM2"
  fi
else
  fail "PM2 nao instalado"
fi

hdr "2. Claude CLI"
if command -v claude >/dev/null 2>&1; then
  ok "claude CLI presente: $(claude --version 2>/dev/null | head -1)"
  if echo "test" | timeout 10 claude -p --bare 2>&1 | grep -q "Not logged in"; then
    fail "Claude nao autenticado. Rode: claude /login"
  else
    ok "Claude responde"
  fi
else
  fail "claude CLI nao encontrado no PATH"
fi

hdr "3. .env"
if [ -f "$REPO_DIR/.env" ]; then
  MODE=$(stat -c '%a' "$REPO_DIR/.env" 2>/dev/null || stat -f '%Lp' "$REPO_DIR/.env" 2>/dev/null)
  if [ "$MODE" = "600" ]; then
    ok ".env presente, modo 600"
  else
    warn ".env presente mas modo e $MODE. Rode: chmod 600 $REPO_DIR/.env"
  fi

  for var in TELEGRAM_BOT_TOKEN ALLOWED_USERS AGENT_NAME; do
    if grep -qE "^${var}=.+" "$REPO_DIR/.env"; then
      ok "$var configurado"
    else
      fail "$var vazio ou ausente no .env"
    fi
  done
else
  fail ".env nao existe em $REPO_DIR/.env"
fi

hdr "4. Skills"
if [ -L "$REPO_DIR/.claude/skills" ]; then
  TARGET=$(readlink "$REPO_DIR/.claude/skills")
  if [ -d "$REPO_DIR/.claude/skills" ]; then
    COUNT=$(ls -d "$REPO_DIR/.claude/skills"/*/ 2>/dev/null | wc -l)
    ok "Symlink valido -> $TARGET ($COUNT skills)"
  else
    fail "Symlink quebrado: $REPO_DIR/.claude/skills -> $TARGET"
  fi
elif [ -d "$REPO_DIR/.claude/skills" ]; then
  COUNT=$(ls -d "$REPO_DIR/.claude/skills"/*/ 2>/dev/null | wc -l)
  ok ".claude/skills e diretorio direto ($COUNT skills)"
elif [ -d "$REPO_DIR/skills" ]; then
  warn ".claude/skills nao existe. Fix: cd $REPO_DIR/.claude && ln -sfn ../skills skills"
else
  warn "Nenhuma pasta skills encontrada"
fi

hdr "5. Agents"
if [ -d "$REPO_DIR/.claude/agents" ]; then
  COUNT=$(ls "$REPO_DIR/.claude/agents"/*.md 2>/dev/null | wc -l)
  if [ "$COUNT" -ge 9 ]; then
    ok "$COUNT agents encontrados"
  else
    warn "Somente $COUNT agents encontrados"
  fi
else
  fail ".claude/agents nao existe"
fi

hdr "6. Telegram bot"
TOKEN=$(grep '^TELEGRAM_BOT_TOKEN=' "$REPO_DIR/.env" 2>/dev/null | cut -d= -f2- | tr -d '"' | tr -d "'")
if [ -n "${TOKEN:-}" ]; then
  if RESP=$(curl -sS --max-time 10 "https://api.telegram.org/bot$TOKEN/getMe" 2>/dev/null) && echo "$RESP" | grep -q '"ok":true'; then
    USERNAME=$(echo "$RESP" | python3 -c "import json,sys;d=json.load(sys.stdin);print(d['result']['username'])" 2>/dev/null)
    ok "Bot acessivel: @$USERNAME"
  else
    fail "getMe falhou. Token invalido ou sem internet"
  fi
else
  fail "TELEGRAM_BOT_TOKEN nao setado no .env"
fi

hdr "7. Python deps"
for pkg in requests pandas; do
  if python3 -c "import $pkg" 2>/dev/null; then
    ok "$pkg instalado"
  else
    warn "$pkg nao instalado"
  fi
done

hdr "8. Gaby runtime"
if [ -d "$REPO_DIR/apps/gaby-agent-runtime" ]; then
  ok "apps/gaby-agent-runtime presente"
else
  warn "apps/gaby-agent-runtime ausente"
fi

echo
if [ "$FAILS" -eq 0 ]; then
  echo -e "${GREEN}OK Tudo validado${NC}"
  exit 0
fi

echo -e "${RED}$FAILS problemas encontrados${NC}"
exit "$FAILS"
