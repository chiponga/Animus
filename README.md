# Animus - Agente Claude Code + Telegram

Animus e um orquestrador de agentes rodando 24/7 em container Gradsky com PM2. Cada mensagem do Telegram chama `claude -p` em modo headless e a Animus delega para especialistas como Atlas, Helena, Aegis, Titan, Sentinel, Victor, Apollo, Oracle e Felipe.

## Instalacao rapida

Pre-requisitos:

- Container Gradsky Debian/Ubuntu com `/workspace` persistente.
- Claude Code CLI logado na conta Pro/Max.
- Bot Telegram criado no BotFather.

No container:

```bash
cd /workspace
git clone https://github.com/chiponga/Animus.git
cd Animus
bash install.sh
```

O instalador roda `bootstrap.sh`, cria o `.env`, prepara as pastas do bot e inicia o PM2.

## Fluxo oficial

```text
Telegram
  -> animus-bot/bot.py
  -> claude -p
  -> Animus
  -> subagentes
  -> Telegram
```

O setup oficial nao usa systemd, tmux, inbox/outbox manual ou paths antigos de VPS. O runtime suportado e:

```text
Gradsky -> PM2 -> animus-bot/bot.py -> claude -p -> subagentes -> Telegram
```

## Recursos

- Bot Python supervisionado por PM2.
- 10 subagentes em `.claude/agents/`, incluindo Gaby para atendimento do jogo/SaaS.
- 59 skills em `skills/`.
- Skill `gradsky-paas` para deploys e services Gradsky via PAT.
- Skill `animus-orchestration-os` para coordenacao de tarefas complexas.
- Audio opcional via OpenAI Whisper e ElevenLabs.
- Memoria opcional via Supabase/Postgres.
- Envio de arquivos no Telegram via marcador `[[SEND_FILE:/path]]`.

## Comandos uteis

```bash
pm2 status
pm2 logs animus-bot
pm2 restart animus-bot
tail -f animus-bot/logs/bot.log
bash scripts/validate.sh
bash scripts/upgrade.sh
bash scripts/rollback.sh
```

## Deploys Gradsky

Para skills que publicam landing pages, propostas ou dossies:

```env
GH_TOKEN=
GH_USER=
GH_EMAIL=
GRADSKY_TOKEN=
GRADSKY_API=https://api.gradsky.com.br
GRADSKY_PROJECT_ID=
GRADSKY_PUBLIC_DOMAIN=true
GRADSKY_ATTACH_DOMAIN=false
GRADSKY_VERIFY_DOMAIN=false
GRADSKY_FORCE_DOMAIN=false
GRADSKY_GIT_AUTO_DEPLOY=true
GRADSKY_FORCE_DEPLOY=false
DOMINIO_BASE=
```

Depois que um service Gradsky ja existe e esta conectado ao GitHub, o padrao e fazer commit/push. A Gradsky inicia o redeploy automaticamente. Use `GRADSKY_FORCE_DEPLOY=true` apenas para forcar deploy pela API.

## Arquivos importantes

| Arquivo | Funcao |
|---|---|
| `install.sh` | Wizard de instalacao |
| `bootstrap.sh` | Instala dependencias |
| `.env.example` | Template de variaveis |
| `animus-bot/bot.py` | Bot Telegram |
| `CLAUDE.md` | Regras centrais da Animus |
| `docs/GRADSKY-PAT.md` | Guia Gradsky PAT |
| `skills/gradsky-paas/` | Skill Gradsky |
| `skills/animus-orchestration-os/` | Skill de orquestracao |
| `apps/gaby-agent-runtime/` | Runtime externo para agente de atendimento do jogo |
| `.claude/agents/gaby.md` | Subagente Gaby, atendente oficial Brasil Games |
| `skills/gaby-brasil-games/` | System prompt operacional da Gaby Brasil Games |
| `skills/gaby-*` | Skills complementares da Gaby |

## Novo runtime de atendimento

O atendimento do jogo/SaaS nao e feito pela Animus. Ele fica em um servico separado:

```text
apps/gaby-agent-runtime
```

O subagente final da Gaby fica em `.claude/agents/gaby.md` e usa como base a skill `skills/gaby-brasil-games/`.

O runtime recebe webhooks do NEW ADMIN, valida HMAC, enfileira eventos, aplica a politica da Gaby e responde no chat via API `/api/agent/v1`.
