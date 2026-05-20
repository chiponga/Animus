<<<<<<< HEAD
﻿# TROUBLESHOOTING â€” Animus
=======
# TROUBLESHOOTING — Animus
>>>>>>> e3f95ead324819de792d72b88e4ceac8037a42fb

Erros mais comuns durante setup, upgrade e uso, com fix imediato.

---

<<<<<<< HEAD
## InstalaÃ§Ã£o
=======
## Instalação
>>>>>>> e3f95ead324819de792d72b88e4ceac8037a42fb

### `claude: command not found`

```bash
npm install -g @anthropic-ai/claude-code
```

<<<<<<< HEAD
Se `npm` tambÃ©m nÃ£o tiver, rode `bash bootstrap.sh` primeiro.

### `Not logged in Â· Please run /login`

Claude CLI nÃ£o tÃ¡ autenticado.

- **Gradsky:** `claude /login` - abra a URL, autentique na conta Pro/Max e cole o codigo quando solicitado.
=======
Se `npm` também não tiver, rode `bash bootstrap.sh` primeiro.

### `Not logged in · Please run /login`

Claude CLI não tá autenticado.

- **MODO A (local):** `claude /login` — abre URL no terminal, copia, cola no browser logado em Pro/Max.
- **MODO B (remoto SSH):** `claude auth login --claudeai` na VPS, captura URL, manda pro Chefe abrir no PC dele.
>>>>>>> e3f95ead324819de792d72b88e4ceac8037a42fb

### `pm2: command not found`

```bash
npm install -g pm2
<<<<<<< HEAD
pm2 save
=======
pm2 startup        # imprime comando pra você rodar (geralmente nada em Gradsky)
>>>>>>> e3f95ead324819de792d72b88e4ceac8037a42fb
```

### `bash bootstrap.sh` falha em "Instalando libs Python"

<<<<<<< HEAD
Ambiente Python externally-managed (PEP 668). Bootstrap jÃ¡ tenta `--break-system-packages` automaticamente. Se persistir:
=======
Ambiente Python externally-managed (PEP 668). Bootstrap já tenta `--break-system-packages` automaticamente. Se persistir:
>>>>>>> e3f95ead324819de792d72b88e4ceac8037a42fb

```bash
pip3 install --break-system-packages requests pandas
```

### `npm install` em `skills/hackernews-intel/` falha com gyp error

<<<<<<< HEAD
VersÃ£o antiga de `better-sqlite3` sem prebuilt pro Node 22. Fix:
=======
Versão antiga de `better-sqlite3` sem prebuilt pro Node 22. Fix:
>>>>>>> e3f95ead324819de792d72b88e4ceac8037a42fb

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

<<<<<<< HEAD
### Bot nÃ£o enxerga uma key que coloquei no .env
=======
### Bot não enxerga uma key que coloquei no .env
>>>>>>> e3f95ead324819de792d72b88e4ceac8037a42fb

Reinicia o bot com `--update-env`:

```bash
<<<<<<< HEAD
pm2 restart animus-bot --update-env
=======
pm2 restart animus-telegram-bot --update-env
>>>>>>> e3f95ead324819de792d72b88e4ceac8037a42fb
```

### `TELEGRAM_BOT_TOKEN missing`

`.env` vazio ou bot procurando em path errado. Confirma:

```bash
grep TELEGRAM_BOT_TOKEN /workspace/Animus/.env
echo $ANIMUS_ENV_FILE   # se vazio, bot usa default /workspace/Animus/.env
```

---

<<<<<<< HEAD
## Bot nÃ£o responde no Telegram

### Passo 1 â€” bot tÃ¡ online no PM2?
=======
## Bot não responde no Telegram

### Passo 1 — bot tá online no PM2?
>>>>>>> e3f95ead324819de792d72b88e4ceac8037a42fb

```bash
pm2 status
```

Se `stopped` ou `errored`:

```bash
<<<<<<< HEAD
pm2 logs animus-bot --lines 50 --nostream
pm2 restart animus-bot
```

### Passo 2 â€” Telegram aceita o token?
=======
pm2 logs animus-telegram-bot --lines 50 --nostream
pm2 restart animus-telegram-bot
```

### Passo 2 — Telegram aceita o token?
>>>>>>> e3f95ead324819de792d72b88e4ceac8037a42fb

```bash
TOKEN=$(grep '^TELEGRAM_BOT_TOKEN=' .env | cut -d= -f2)
curl -s "https://api.telegram.org/bot$TOKEN/getMe"
```

<<<<<<< HEAD
Esperado: `{"ok":true,"result":{...}}`. Se `{"ok":false,"description":"Unauthorized"}`, token errado/revogado â€” gere outro no @BotFather.

### Passo 3 â€” vocÃª estÃ¡ no ALLOWED_USERS?
=======
Esperado: `{"ok":true,"result":{...}}`. Se `{"ok":false,"description":"Unauthorized"}`, token errado/revogado — gere outro no @BotFather.

### Passo 3 — você está no ALLOWED_USERS?
>>>>>>> e3f95ead324819de792d72b88e4ceac8037a42fb

```bash
grep ALLOWED_USERS .env
```

<<<<<<< HEAD
Tem que ter seu user_id (numÃ©rico do @userinfobot). CSV se mais de um.

### Passo 4 â€” Claude tÃ¡ respondendo?
=======
Tem que ter seu user_id (numérico do @userinfobot). CSV se mais de um.

### Passo 4 — Claude tá respondendo?
>>>>>>> e3f95ead324819de792d72b88e4ceac8037a42fb

```bash
echo "ping" | claude -p --output-format=text
```

<<<<<<< HEAD
Se travar/erro, refaÃ§a login: `claude /login`.

### Passo 5 â€” Watchdog kill por timeout?
=======
Se travar/erro, refaça login: `claude /login`.

### Passo 5 — Watchdog kill por timeout?
>>>>>>> e3f95ead324819de792d72b88e4ceac8037a42fb

Logs mostram `claude rc=-9` ou `watchdog kill msg_id=...`? Tarefa passou de `CLAUDE_TIMEOUT` segundos. Aumente no `.env`:

```bash
sed -i 's/^CLAUDE_TIMEOUT=.*/CLAUDE_TIMEOUT=600/' .env
<<<<<<< HEAD
pm2 restart animus-bot --update-env
=======
pm2 restart animus-telegram-bot --update-env
>>>>>>> e3f95ead324819de792d72b88e4ceac8037a42fb
```

---

<<<<<<< HEAD
## Skills nÃ£o carregam

### `.claude/skills` nÃ£o existe
=======
## Skills não carregam

### `.claude/skills` não existe
>>>>>>> e3f95ead324819de792d72b88e4ceac8037a42fb

```bash
cd .claude && ln -sfn ../skills skills
```

### Symlink quebrado

```bash
ls -la .claude/skills
<<<<<<< HEAD
# Se mostra "â†’ ../skills" mas "ls .claude/skills" falha:
=======
# Se mostra "→ ../skills" mas "ls .claude/skills" falha:
>>>>>>> e3f95ead324819de792d72b88e4ceac8037a42fb
rm .claude/skills
cd .claude && ln -sfn ../skills skills
```

<<<<<<< HEAD
### Skill nova adicionada mas Claude nÃ£o vÃª

Restart do bot (claude lÃª o catÃ¡logo no startup do session):

```bash
pm2 restart animus-bot --update-env
=======
### Skill nova adicionada mas Claude não vê

Restart do bot (claude lê o catálogo no startup do session):

```bash
pm2 restart animus-telegram-bot --update-env
>>>>>>> e3f95ead324819de792d72b88e4ceac8037a42fb
```

### Skill com erro de frontmatter

<<<<<<< HEAD
Cada `SKILL.md` precisa comeÃ§ar com:
=======
Cada `SKILL.md` precisa começar com:
>>>>>>> e3f95ead324819de792d72b88e4ceac8037a42fb

```markdown
---
name: skill-name
<<<<<<< HEAD
description: descriÃ§Ã£o curta (250-400 chars ideal)
=======
description: descrição curta (250-400 chars ideal)
>>>>>>> e3f95ead324819de792d72b88e4ceac8037a42fb
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

<<<<<<< HEAD
Tem mudanÃ§as locais nÃ£o-commitadas. O `upgrade.sh` faz `git stash` automÃ¡tico. Se ainda falhar:
=======
Tem mudanças locais não-commitadas. O `upgrade.sh` faz `git stash` automático. Se ainda falhar:
>>>>>>> e3f95ead324819de792d72b88e4ceac8037a42fb

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

<<<<<<< HEAD
### Quero rodar upgrade sem backup (mais rÃ¡pido)
=======
### Quero rodar upgrade sem backup (mais rápido)
>>>>>>> e3f95ead324819de792d72b88e4ceac8037a42fb

```bash
bash scripts/upgrade.sh --no-backup
```

<<<<<<< HEAD
Risco seu. Recomendo sÃ³ pra testes.
=======
Risco seu. Recomendo só pra testes.
>>>>>>> e3f95ead324819de792d72b88e4ceac8037a42fb

---

## PM2

### Bot reiniciando em loop (status `errored`)

```bash
<<<<<<< HEAD
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
=======
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
>>>>>>> e3f95ead324819de792d72b88e4ceac8037a42fb
| `animus-bot/logs/bot.log` | Bot Python (arquivo) |
| `animus-bot/inbox/*.json` | Toda mensagem recebida |
| `animus-bot/sent/*.json` | Toda mensagem enviada |
| `~/.npm/_logs/*.log` | Falhas de npm install |
<<<<<<< HEAD
| `var/log/animus-upgrade.log` | HistÃ³rico de upgrades (se rodou upgrade.sh) |
=======
| `var/log/animus-upgrade.log` | Histórico de upgrades (se rodou upgrade.sh) |
>>>>>>> e3f95ead324819de792d72b88e4ceac8037a42fb

---

## Quando nada funciona

<<<<<<< HEAD
1. `bash scripts/validate.sh` â€” checa as 8 coisas crÃ­ticas
2. `bash scripts/rollback.sh` â€” volta pro Ãºltimo backup que funcionava
3. Abre issue em https://github.com/chiponga/Animus/issues com:
   - SaÃ­da de `validate.sh`
   - Ãšltimas 50 linhas do `pm2 logs`
   - ConteÃºdo do `.env` **sem secrets** (substitua valores por `***`)
=======
1. `bash scripts/validate.sh` — checa as 8 coisas críticas
2. `bash scripts/rollback.sh` — volta pro último backup que funcionava
3. Abre issue em https://github.com/chiponga/Animus/issues com:
   - Saída de `validate.sh`
   - Últimas 50 linhas do `pm2 logs`
   - Conteúdo do `.env` **sem secrets** (substitua valores por `***`)
>>>>>>> e3f95ead324819de792d72b88e4ceac8037a42fb
