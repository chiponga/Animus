# TROUBLESHOOTING — Animus

Erros mais comuns durante setup, upgrade e uso, com fix imediato.

---

## Instalação

### `claude: command not found`

```bash
npm install -g @anthropic-ai/claude-code
```

Se `npm` também não tiver, rode `bash bootstrap.sh` primeiro.

### `Not logged in · Please run /login`

Claude CLI não tá autenticado.

- **MODO A (local):** `claude /login` — abre URL no terminal, copia, cola no browser logado em Pro/Max.
- **MODO B (remoto SSH):** `claude auth login --claudeai` na VPS, captura URL, manda pro Chefe abrir no PC dele.

### `pm2: command not found`

```bash
npm install -g pm2
pm2 startup        # imprime comando pra você rodar (geralmente nada em Gradsky)
```

### `bash bootstrap.sh` falha em "Instalando libs Python"

Ambiente Python externally-managed (PEP 668). Bootstrap já tenta `--break-system-packages` automaticamente. Se persistir:

```bash
pip3 install --break-system-packages requests pandas
```

### `npm install` em `skills/hackernews-intel/` falha com gyp error

Versão antiga de `better-sqlite3` sem prebuilt pro Node 22. Fix:

```bash
cd skills/hackernews-intel
rm -rf node_modules package-lock.json
npm install better-sqlite3@latest
```

---

## .env e secrets

### `.env: Permission denied`

```bash
chmod 600 .env
```

### Bot não enxerga uma key que coloquei no .env

Reinicia o bot com `--update-env`:

```bash
pm2 restart animus-telegram-bot --update-env
```

### `TELEGRAM_BOT_TOKEN missing`

`.env` vazio ou bot procurando em path errado. Confirma:

```bash
grep TELEGRAM_BOT_TOKEN /workspace/Animus/.env
echo $ANIMUS_ENV_FILE   # se vazio, bot usa default /workspace/Animus/.env
```

---

## Bot não responde no Telegram

### Passo 1 — bot tá online no PM2?

```bash
pm2 status
```

Se `stopped` ou `errored`:

```bash
pm2 logs animus-telegram-bot --lines 50 --nostream
pm2 restart animus-telegram-bot
```

### Passo 2 — Telegram aceita o token?

```bash
TOKEN=$(grep '^TELEGRAM_BOT_TOKEN=' .env | cut -d= -f2)
curl -s "https://api.telegram.org/bot$TOKEN/getMe"
```

Esperado: `{"ok":true,"result":{...}}`. Se `{"ok":false,"description":"Unauthorized"}`, token errado/revogado — gere outro no @BotFather.

### Passo 3 — você está no ALLOWED_USERS?

```bash
grep ALLOWED_USERS .env
```

Tem que ter seu user_id (numérico do @userinfobot). CSV se mais de um.

### Passo 4 — Claude tá respondendo?

```bash
echo "ping" | claude -p --output-format=text
```

Se travar/erro, refaça login: `claude /login`.

### Passo 5 — Watchdog kill por timeout?

Logs mostram `claude rc=-9` ou `watchdog kill msg_id=...`? Tarefa passou de `CLAUDE_TIMEOUT` segundos. Aumente no `.env`:

```bash
sed -i 's/^CLAUDE_TIMEOUT=.*/CLAUDE_TIMEOUT=600/' .env
pm2 restart animus-telegram-bot --update-env
```

---

## Skills não carregam

### `.claude/skills` não existe

```bash
cd .claude && ln -sfn ../skills skills
```

### Symlink quebrado

```bash
ls -la .claude/skills
# Se mostra "→ ../skills" mas "ls .claude/skills" falha:
rm .claude/skills
cd .claude && ln -sfn ../skills skills
```

### Skill nova adicionada mas Claude não vê

Restart do bot (claude lê o catálogo no startup do session):

```bash
pm2 restart animus-telegram-bot --update-env
```

### Skill com erro de frontmatter

Cada `SKILL.md` precisa começar com:

```markdown
---
name: skill-name
description: descrição curta (250-400 chars ideal)
---
```

Sem isso, Claude ignora. Valida com:

```bash
for d in skills/*/; do
  head -1 "$d/SKILL.md" | grep -q '^---$' || echo "BAD: $d"
done
```

---

## Upgrade

### `git pull --ff-only` falha

Tem mudanças locais não-commitadas. O `upgrade.sh` faz `git stash` automático. Se ainda falhar:

```bash
git stash push -m "antes-do-upgrade"
git pull --ff-only origin main
git stash pop
```

### Upgrade deixou bot quebrado

```bash
bash scripts/rollback.sh
```

Restaura o backup mais recente (criado automaticamente antes do upgrade).

### Quero rodar upgrade sem backup (mais rápido)

```bash
bash scripts/upgrade.sh --no-backup
```

Risco seu. Recomendo só pra testes.

---

## PM2

### Bot reiniciando em loop (status `errored`)

```bash
pm2 logs animus-telegram-bot --err --lines 30 --nostream
```

Causa comum: `.env` faltando vars obrigatórias.

### PM2 esquece o processo após restart do container/VPS

```bash
pm2 save
pm2 startup    # em Gradsky imprime aviso (sem systemd, OK)
```

Em Gradsky sem systemd, basta rodar `pm2 resurrect` no startup do container (já tá no `bootstrap.sh` na maioria das instalações Gradsky).

---

## Logs e diagnóstico

| Onde | O quê |
|---|---|
| `pm2 logs animus-telegram-bot` | Bot Python (ao vivo) |
| `animus-bot/logs/bot.log` | Bot Python (arquivo) |
| `animus-bot/inbox/*.json` | Toda mensagem recebida |
| `animus-bot/sent/*.json` | Toda mensagem enviada |
| `~/.npm/_logs/*.log` | Falhas de npm install |
| `var/log/animus-upgrade.log` | Histórico de upgrades (se rodou upgrade.sh) |

---

## Quando nada funciona

1. `bash scripts/validate.sh` — checa as 8 coisas críticas
2. `bash scripts/rollback.sh` — volta pro último backup que funcionava
3. Abre issue em https://github.com/chiponga/Animus/issues com:
   - Saída de `validate.sh`
   - Últimas 50 linhas do `pm2 logs`
   - Conteúdo do `.env` **sem secrets** (substitua valores por `***`)
