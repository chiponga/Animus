# TROUBLESHOOTING â€” Animus

Erros mais comuns durante setup, upgrade e uso, com fix imediato.

---

## InstalaÃ§Ã£o

### `claude: command not found`

```bash
npm install -g @anthropic-ai/claude-code
```

Se `npm` tambÃ©m nÃ£o tiver, rode `bash bootstrap.sh` primeiro.

### `Not logged in Â· Please run /login`

Claude CLI nÃ£o tÃ¡ autenticado.

- **Gradsky:** `claude /login` - abra a URL, autentique na conta Pro/Max e cole o codigo quando solicitado.

### `pm2: command not found`

```bash
npm install -g pm2
pm2 save
```

### `bash bootstrap.sh` falha em "Instalando libs Python"

Ambiente Python externally-managed (PEP 668). Bootstrap jÃ¡ tenta `--break-system-packages` automaticamente. Se persistir:

```bash
pip3 install --break-system-packages requests pandas
```

### `npm install` em `skills/hackernews-intel/` falha com gyp error

VersÃ£o antiga de `better-sqlite3` sem prebuilt pro Node 22. Fix:

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

### Bot nÃ£o enxerga uma key que coloquei no .env

Reinicia o bot com `--update-env`:

```bash
pm2 restart animus-bot --update-env
```

### `TELEGRAM_BOT_TOKEN missing`

`.env` vazio ou bot procurando em path errado. Confirma:

```bash
grep TELEGRAM_BOT_TOKEN /workspace/Animus/.env
echo $ANIMUS_ENV_FILE   # se vazio, bot usa default /workspace/Animus/.env
```

---

## Bot nÃ£o responde no Telegram

### Passo 1 â€” bot tÃ¡ online no PM2?

```bash
pm2 status
```

Se `stopped` ou `errored`:

```bash
pm2 logs animus-bot --lines 50 --nostream
pm2 restart animus-bot
```

### Passo 2 â€” Telegram aceita o token?

```bash
TOKEN=$(grep '^TELEGRAM_BOT_TOKEN=' .env | cut -d= -f2)
curl -s "https://api.telegram.org/bot$TOKEN/getMe"
```

Esperado: `{"ok":true,"result":{...}}`. Se `{"ok":false,"description":"Unauthorized"}`, token errado/revogado â€” gere outro no @BotFather.

### Passo 3 â€” vocÃª estÃ¡ no ALLOWED_USERS?

```bash
grep ALLOWED_USERS .env
```

Tem que ter seu user_id (numÃ©rico do @userinfobot). CSV se mais de um.

### Passo 4 â€” Claude tÃ¡ respondendo?

```bash
echo "ping" | claude -p --output-format=text
```

Se travar/erro, refaÃ§a login: `claude /login`.

### Passo 5 â€” Watchdog kill por timeout?

Logs mostram `claude rc=-9` ou `watchdog kill msg_id=...`? Tarefa passou de `CLAUDE_TIMEOUT` segundos. Aumente no `.env`:

```bash
sed -i 's/^CLAUDE_TIMEOUT=.*/CLAUDE_TIMEOUT=600/' .env
pm2 restart animus-bot --update-env
```

---

## Skills nÃ£o carregam

### `.claude/skills` nÃ£o existe

```bash
cd .claude && ln -sfn ../skills skills
```

### Symlink quebrado

```bash
ls -la .claude/skills
# Se mostra "â†’ ../skills" mas "ls .claude/skills" falha:
rm .claude/skills
cd .claude && ln -sfn ../skills skills
```

### Skill nova adicionada mas Claude nÃ£o vÃª

Restart do bot (claude lÃª o catÃ¡logo no startup do session):

```bash
pm2 restart animus-bot --update-env
```

### Skill com erro de frontmatter

Cada `SKILL.md` precisa comeÃ§ar com:

```markdown
---
name: skill-name
description: descriÃ§Ã£o curta (250-400 chars ideal)
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

Tem mudanÃ§as locais nÃ£o-commitadas. O `upgrade.sh` faz `git stash` automÃ¡tico. Se ainda falhar:

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

### Quero rodar upgrade sem backup (mais rÃ¡pido)

```bash
bash scripts/upgrade.sh --no-backup
```

Risco seu. Recomendo sÃ³ pra testes.

---

## PM2

### Bot reiniciando em loop (status `errored`)

```bash
pm2 logs animus-bot --err --lines 30 --nostream
```

Causa comum: `.env` faltando vars obrigatÃ³rias.

### PM2 esquece o processo apÃ³s restart do container

```bash
pm2 save
pm2 save
```

Em Gradsky, rode `pm2 resurrect` no startup do container quando precisar restaurar a lista salva.

---

## Logs e diagnÃ³stico

| Onde | O quÃª |
|---|---|
| `pm2 logs animus-bot` | Bot Python (ao vivo) |
| `animus-bot/logs/bot.log` | Bot Python (arquivo) |
| `animus-bot/inbox/*.json` | Toda mensagem recebida |
| `animus-bot/sent/*.json` | Toda mensagem enviada |
| `~/.npm/_logs/*.log` | Falhas de npm install |
| `var/log/animus-upgrade.log` | HistÃ³rico de upgrades (se rodou upgrade.sh) |

---

## Quando nada funciona

1. `bash scripts/validate.sh` â€” checa as 8 coisas crÃ­ticas
2. `bash scripts/rollback.sh` â€” volta pro Ãºltimo backup que funcionava
3. Abre issue em https://github.com/chiponga/Animus/issues com:
   - SaÃ­da de `validate.sh`
   - Ãšltimas 50 linhas do `pm2 logs`
   - ConteÃºdo do `.env` **sem secrets** (substitua valores por `***`)
