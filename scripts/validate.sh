#!/bin/bash
# =============================================================
# validate.sh — Smoke test do Animus
# =============================================================
# Checa:
#   1) PM2 bot online
#   2) Claude CLI autenticado
#   3) .env presente e modo 600
#   4) .claude/skills symlink funcional
#   5) .claude/agents presentes (>=9 esperados)
#   6) Telegram bot acessível (getMe)
#   7) Deps Python (requests, pandas) instaladas
#
# Exit code: 0 se tudo OK, número de falhas se algo quebrar.
# =============================================================

set -uo pipefail  # NÃO usar -e, queremos coletar todas as falhas

GREEN='\033[0;32m'; YELLOW='\033[1;33m'; RED='\033[0;31m'; CYAN='\033[1;36m'; NC='\033[0m'

ok()   { echo -e "${GREEN}  ✓${NC} $1"; }
warn() { echo -e "${YELLOW}  !${NC} $1"; FAILS=$((FAILS+1)); }
fail() { echo -e "${RED}  ✗${NC} $1"; FAILS=$((FAILS+1)); }
hdr()  { echo -e "${CYAN}>> $1${NC}"; }

REPO_DIR="${ANIMUS_REPO_DIR:-/workspace/Animus}"
FAILS=0

hdr "Animus validate — $(date)"
echo

# 1. PM2 bot
hdr "1. PM2 bot"
if command -v pm2 >/dev/null 2>&1; then
  if pm2 jlist 2>/dev/null | python3 -c "import json,sys; ps=json.load(sys.stdin); names=[p['name'] for p in ps if p.get('pm2_env',{}).get('status')=='online']; sys.exit(0 if any('bot' in n.lower() for n in names) else 1)" 2>/dev/null; then
    ok "PM2 com bot online"
  else
    fail "Nenhum bot online no PM2 (rode: pm2 list)"
  fi
else
  fail "PM2 não instalado"
fi

# 2. Claude CLI
hdr "2. Claude CLI"
if command -v claude >/dev/null 2>&1; then
  ok "claude CLI presente: $(claude --version 2>/dev/null | head -1)"
  # Tenta um ping no modo bare (não usa rede além de auth check)
  if echo "test" | timeout 10 claude -p --bare 2>&1 | grep -q "Not logged in"; then
    fail "Claude não está autenticado — rode: claude /login"
  else
    ok "Claude responde"
  fi
else
  fail "claude CLI não encontrado no PATH"
fi

# 3. .env
hdr "3. .env"
if [ -f "$REPO_DIR/.env" ]; then
  MODE=$(stat -c '%a' "$REPO_DIR/.env" 2>/dev/null || stat -f '%Lp' "$REPO_DIR/.env" 2>/dev/null)
  if [ "$MODE" = "600" ]; then
    ok ".env presente, modo 600"
  else
    warn ".env presente mas modo é $MODE (deveria ser 600). Rode: chmod 600 $REPO_DIR/.env"
  fi
  # Verifica vars essenciais
  for var in TELEGRAM_BOT_TOKEN ALLOWED_USERS AGENT_NAME; do
    if grep -qE "^${var}=.+" "$REPO_DIR/.env"; then
      ok "  $var configurado"
    else
      fail "  $var vazio ou ausente no .env"
    fi
  done
else
  fail ".env não existe em $REPO_DIR/.env (rode: bash install.sh)"
fi

# 4. .claude/skills symlink
hdr "4. Skills (.claude/skills)"
if [ -L "$REPO_DIR/.claude/skills" ]; then
  TARGET=$(readlink "$REPO_DIR/.claude/skills")
  if [ -d "$REPO_DIR/.claude/skills" ]; then
    COUNT=$(ls -d "$REPO_DIR/.claude/skills"/*/ 2>/dev/null | wc -l)
    ok "Symlink válido → $TARGET ($COUNT skills)"
  else
    fail "Symlink quebrado: $REPO_DIR/.claude/skills → $TARGET"
  fi
elif [ -d "$REPO_DIR/.claude/skills" ]; then
  COUNT=$(ls -d "$REPO_DIR/.claude/skills"/*/ 2>/dev/null | wc -l)
  ok ".claude/skills é diretório direto ($COUNT skills)"
elif [ -d "$REPO_DIR/skills" ]; then
  warn ".claude/skills não existe (skills em skills/ não auto-descobertas)"
  warn "  Fix: cd $REPO_DIR/.claude && ln -sfn ../skills skills"
else
  warn "Nenhuma skills/ encontrada"
fi

# 5. Agents
hdr "5. Agents (.claude/agents)"
if [ -d "$REPO_DIR/.claude/agents" ]; then
  COUNT=$(ls "$REPO_DIR/.claude/agents"/*.md 2>/dev/null | wc -l)
  if [ "$COUNT" -ge 9 ]; then
    ok "$COUNT agents encontrados (esperado: ≥9)"
  else
    warn "Só $COUNT agents (esperado: 9). Verifique .claude/agents/"
  fi
else
  fail ".claude/agents/ não existe"
fi

# 6. Telegram getMe
hdr "6. Telegram bot"
TOKEN=$(grep '^TELEGRAM_BOT_TOKEN=' "$REPO_DIR/.env" 2>/dev/null | cut -d= -f2- | tr -d '"' | tr -d "'")
if [ -n "${TOKEN:-}" ]; then
  if RESP=$(curl -sS --max-time 10 "https://api.telegram.org/bot$TOKEN/getMe" 2>/dev/null) && echo "$RESP" | grep -q '"ok":true'; then
    USERNAME=$(echo "$RESP" | python3 -c "import json,sys;d=json.load(sys.stdin);print(d['result']['username'])" 2>/dev/null)
    ok "Bot acessível: @$USERNAME"
  else
    fail "getMe falhou — token inválido ou sem internet"
  fi
else
  fail "TELEGRAM_BOT_TOKEN não setado no .env"
fi

# 7. Deps Python
hdr "7. Dependências Python"
for pkg in requests pandas; do
  if python3 -c "import $pkg" 2>/dev/null; then
    VER=$(python3 -c "import $pkg; print($pkg.__version__)" 2>/dev/null)
    ok "$pkg $VER"
  else
    warn "$pkg não instalado (skills podem quebrar)"
  fi
done

# 8. node + skill deps
hdr "8. Deps Node (skills)"
if [ -f "$REPO_DIR/skills/hackernews-intel/package.json" ]; then
  if [ -d "$REPO_DIR/skills/hackernews-intel/node_modules/better-sqlite3" ]; then
    ok "hackernews-intel: better-sqlite3 instalado"
  else
    warn "hackernews-intel: rode cd $REPO_DIR/skills/hackernews-intel && npm install"
  fi
fi

echo
if [ "$FAILS" -eq 0 ]; then
  echo -e "${GREEN}✓ Tudo OK ($FAILS falhas)${NC}"
  exit 0
else
  echo -e "${RED}✗ $FAILS problemas encontrados${NC}"
  exit "$FAILS"
fi
