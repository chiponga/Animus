# SETUP-AGENTE.md — Roteiro pro Claude instalar o Animus

> **Claude, este arquivo é pra você executar.** Lê do início ao fim, faz perguntas
> uma de cada vez quando precisar de info do Chefe, e entrega no final um bot
> Telegram orquestrador rodando 24/7 com 9 especialistas + 57 skills.

---

## Decisão inicial: qual ambiente?

Pergunta ao Chefe (uma por vez):

**Pergunta 1:** "Você vai rodar o Animus aqui mesmo (container Gradsky / WSL2 / VPS já
acessada via SSH) ou eu preciso fazer SSH de fora pra uma VPS Ubuntu nova?"

- Resposta **"aqui mesmo"** → use **MODO A** (Local). Pula pra ETAPA 0 logo abaixo.
- Resposta **"VPS nova"** → use **MODO B** (Remoto). Leia a próxima seção primeiro.

---

## MODO B — SSH remoto a uma VPS nova

Use essa seção quando o Chefe está no PC dele (Mac/Win/Linux) e tem só IP/senha
de uma VPS Ubuntu recém-provisionada.

### B.1 — Pré-checks no PC do Chefe

```bash
which ssh                  # geralmente já tem
which sshpass || echo "instalar sshpass primeiro"
```

- **Mac:** `brew install hudochenkov/sshpass/sshpass`
- **Linux Debian/Ubuntu:** `sudo apt-get install -y sshpass`
- **Windows:** instruir Chefe a usar WSL2 (Ubuntu). Sem WSL2, use Python+paramiko.

### B.2 — Coletar credenciais da VPS

Uma resposta por vez:

1. "Qual o IP público da sua VPS?" → guarda como `VPS_IP`
2. "Qual o usuário SSH? (geralmente `root`)" → guarda como `VPS_USER`
3. "Qual a senha?" → guarda como `VPS_PASS` (**NUNCA** logue ou echo isso)

### B.3 — Wrapper SSH (use SEMPRE este, não exponha senha em linha de comando)

```bash
ssh_run() {
  sshpass -p "$VPS_PASS" ssh -o StrictHostKeyChecking=no \
    -o UserKnownHostsFile=/dev/null \
    "$VPS_USER@$VPS_IP" "$@"
}
ssh_copy() {
  sshpass -p "$VPS_PASS" scp -o StrictHostKeyChecking=no \
    -o UserKnownHostsFile=/dev/null \
    "$1" "$VPS_USER@$VPS_IP:$2"
}
```

### B.4 — Testar conexão

```bash
ssh_run "uname -a && cat /etc/os-release | head -3"
```

Se falhar: pergunta IP/usuario/senha de novo. VPS recém-provisionada pode levar
1-3min pra ter SSH ativo.

### B.5 — A partir daqui

Toda linha `bash` da ETAPA 0 em diante, você prefixa com `ssh_run "..."` ou usa
heredoc + `ssh_copy`. Comportamento idêntico ao MODO A, só roda remoto.

---

## MODO A / B — ETAPA 0: Clonar repo

```bash
# Caminho padrão: /workspace (Gradsky), /opt (VPS Ubuntu)
INSTALL_DIR="${ANIMUS_INSTALL_DIR:-/workspace}"
[ -d /workspace ] || INSTALL_DIR=/opt

cd "$INSTALL_DIR"
if [ ! -d "$INSTALL_DIR/Animus" ]; then
  git clone https://github.com/chiponga/Animus.git
fi
cd "$INSTALL_DIR/Animus"
```

---

## ETAPA 1: Bootstrap (instala deps)

```bash
bash bootstrap.sh
```

Instala: Python 3, requests, pandas, Node 22, npm, PM2, Claude Code CLI, gh, ffmpeg.
Cria symlink `.claude/skills → ../skills` pra auto-discovery.
Roda `npm install` em `skills/hackernews-intel/` automaticamente.

**Idempotente:** rode quantas vezes quiser, só pula o que já tá feito.

---

## ETAPA 2: Login Claude

Verifica primeiro se já tá logado:

```bash
claude auth status 2>&1
```

Se mostrar `loggedIn: true`, pula essa etapa.

Se não, em **MODO A** rode `claude /login` interativo. Em **MODO B**:

```bash
ssh_run "claude auth login --claudeai"   # imprime URL
# ↳ você pega a URL e manda pro Chefe abrir no browser local dele
# ↳ Chefe autoriza, copia código e te devolve
# ↳ você envia o código:
ssh_run "echo 'CODIGO_AQUI' | claude auth submit"
ssh_run "claude auth status"  # deve mostrar loggedIn: true
```

---

## ETAPA 3: Wizard interativo (install.sh)

```bash
bash install.sh
```

O install pergunta (uma a uma):

| # | Pergunta | Obrigatório | Onde pegar |
|---|---|---|---|
| 1 | Nome do agente (ex: Animus, Atlas) | sim | invenção do Chefe |
| 2 | Como o agente te chama (ex: Chefe) | sim | preferência |
| 3 | Nome da empresa | não | livre |
| 4 | Nome do produto | não | livre |
| 5 | Token bot Telegram | sim | @BotFather → /newbot |
| 6 | user_id Telegram | sim | @userinfobot → /start |
| 7 | DATABASE_URL Supabase | não | dashboard.supabase.com |
| 8 | OPENAI_API_KEY (áudio entrada) | não | platform.openai.com |
| 9 | ELEVENLABS_API_KEY (áudio saída) | não | elevenlabs.io |
| 10 | ANTHROPIC_API_KEY (API direta) | não | console.anthropic.com |
| 11 | MUAPI_API_KEY (imagem/vídeo) | não | muapi.ai |
| 12 | GEMINI_API_KEY (4 skills) | não | aistudio.google.com (grátis) |
| 13 | VALIDEMAIL_API_KEY (cold email) | não | validemail.co |
| 14 | TAVILY_API_KEY (meeting brief) | não | tavily.com (grátis) |

O install escreve `.env` em modo 600, sobe o bot via PM2 e mostra o status.

---

## ETAPA 4: Validar

```bash
bash scripts/validate.sh
```

Checa 8 coisas: PM2 online, Claude autenticado, .env válido, .claude/skills,
.claude/agents (≥9), Telegram bot acessível, deps Python, deps Node.

Se algum check falhar, o script mostra o fix.

---

## ETAPA 5: Smoke test no Telegram

Peça pro Chefe mandar uma mensagem qualquer pro bot dele no Telegram (ex: "oi").

Esperado:
1. Bot reage com 👀 na mensagem
2. Bot manda ack curto ("Anotado, chefe...")
3. Bot responde a mensagem dele

Se não responder em 30s: `pm2 logs animus-telegram-bot --lines 30`

---

## Pós-setup: comandos úteis

```bash
pm2 status                              # status do bot
pm2 logs animus-telegram-bot            # logs ao vivo
pm2 restart animus-telegram-bot         # restart
bash scripts/validate.sh                # smoke test
bash scripts/upgrade.sh                 # atualiza pra versão mais recente do repo
bash scripts/rollback.sh                # restaura backup anterior
tail -f animus-bot/logs/bot.log         # log da aplicação
```

---

## Estrutura entregue

```
/workspace/Animus/                  (ou /opt/Animus/ em VPS)
├── .env                            (600, secrets do agente)
├── .claude/
│   ├── agents/                     9 especialistas (atlas, helena, ...)
│   └── skills/ → ../skills/        symlink pra auto-discovery
├── animus-bot/
│   ├── bot.py                      daemon PM2 (long polling Telegram)
│   ├── inbox/                      auditoria de msgs recebidas
│   ├── sent/                       auditoria de msgs enviadas
│   └── logs/                       bot.log + pm2.log
├── skills/                         57 skills (.claude/skills aponta aqui)
├── scripts/
│   ├── backup.sh                   backup completo timestamped
│   ├── rollback.sh                 restaura backup
│   ├── upgrade.sh                  git pull + reaplicar setup
│   └── validate.sh                 smoke test 8 checks
└── CLAUDE.md                       personalidade + regras do agente
```

---

## Troubleshooting rápido

| Sintoma | Fix |
|---|---|
| Bot não responde no Telegram | `pm2 logs animus-telegram-bot --lines 50` |
| "Not logged in · run /login" | `claude /login` (MODO A) ou refazer ETAPA 2 (MODO B) |
| Skills não carregam | `ls -la .claude/skills` (deve ser symlink) |
| Watchdog kill / timeout | aumentar `CLAUDE_TIMEOUT` no .env (default 300s) |
| Outros | ler `docs/TROUBLESHOOTING.md` |

---

## Quando entregar pro Chefe (mensagem final)

Após `validate.sh` retornar 0 falhas e teste no Telegram passar:

```
Animus instalado e online.

- 9 especialistas em .claude/agents/
- 57 skills auto-descobertas
- Bot rodando via PM2 (auto-restart se cair)
- Backup automático rodando antes de cada upgrade

Comandos:
  pm2 logs animus-telegram-bot     # ver logs
  bash scripts/upgrade.sh          # atualizar
  bash scripts/rollback.sh         # voltar atrás

Manda um "oi" pro bot pra testar.
```
