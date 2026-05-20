# Animus â€” Agente Claude Code + Telegram

Agente orquestrador rodando 24/7 num container Gradsky (Debian/Ubuntu persistente). Cada mensagem do Telegram dispara um `claude -p` headless que delega pros 9 subagentes especialistas (atlas, helena, aegis, titan, sentinel, victor, apollo, oracle, felipe).

---

## InstalaÃ§Ã£o em 1 comando (recomendado)

### PrÃ©-requisito
- Container Gradsky (Debian/Ubuntu, root) com `/workspace` persistente.
- Claude Code CLI logado na sua conta Pro/Max (ou rode `claude /login` na primeira vez).

### Fluxo

**1.** Abra o Claude Code dentro do container Gradsky:

```bash
cd /workspace && claude
```

**2.** Cole o prompt abaixo (tambÃ©m estÃ¡ em [`prompt-instalador.txt`](./prompt-instalador.txt)):

```
OlÃ¡! Quero instalar o agente Animus no meu container Gradsky.

RepositÃ³rio: https://github.com/chiponga/Animus.git

Sua missÃ£o:
1. Clona o repo em /workspace/Animus (se ainda nÃ£o existir).
2. LÃª o arquivo INSTALL.md que estÃ¡ na raiz e executa todos os passos.
3. Me faz UMA pergunta de cada vez, espera eu responder antes da prÃ³xima.
```

**3.** Responda as perguntas conforme o Claude pedir (nome do agente, dono, token Telegram do @BotFather, seu user_id do @userinfobot, e os opcionais OpenAI/ElevenLabs/Supabase).

**4.** Em ~5 min o Claude vai dizer "agente no ar". Mande uma mensagem no Telegram pro seu bot.

> O roteiro que o Claude segue Ã© o [`INSTALL.md`](./INSTALL.md). Ele lÃª, instala dependÃªncias via `bootstrap.sh`, escreve o `.env`, sobe o bot via PM2 e valida.

---

## InstalaÃ§Ã£o manual (sem o Claude intermediando)

Se preferir fazer no terminal direto:

```bash
cd /workspace
git clone https://github.com/chiponga/Animus.git
cd Animus
bash install.sh
```

O `install.sh` faz as mesmas perguntas que o Claude faria, escreve o `.env` e sobe o bot via PM2.

---

## Arquitetura

```
[Telegram]
   â”‚
   â–¼
[bot.py â€” PM2, sempre vivo]    â† long polling getUpdates
   â”‚
   â–¼ subprocess STDIN
[claude -p stream-json]        â† cada msg Ã© uma invocaÃ§Ã£o
   â”‚
   â”œâ”€â”€ responde direto (text events) â†’ Telegram
   â””â”€â”€ delega via Task tool â†’ atlas / helena / aegis / titan / sentinel / victor / apollo / oracle / felipe
                              â†“
                          resposta consolidada â†’ Telegram
```

ResiliÃªncia:
- PM2 reinicia o bot se ele cair; use `pm2 save` apos alterar processos.
- Cada `claude -p` Ã© stateless (session via flag `-c` se jÃ¡ houve sessÃ£o anterior).
- Inbox/sent persistente em `animus-bot/{inbox,sent,state,logs}/` pra auditoria.
- Volumes Gradsky (`/workspace`, `/root`, `/opt`) sobrevivem a restart/redeploy.

---

## Recursos

- **Bot externo Python** sempre vivo, independente do Claude Code.
- **9 subagentes especialistas** em `.claude/agents/` (auto-descobertos).
- **59 skills** em `skills/` (auto-descobertas via symlink `.claude/skills/ â†’ ../skills/`).
- **Ãudio bidirecional opcional** (Whisper entrada + ElevenLabs TTS saÃ­da).
- **MemÃ³ria vetorial opcional** via Supabase Postgres + pgvector (DATABASE_URL no `.env`).
- **Aprendizado contÃ­nuo** via `.learnings/` (LEARNINGS.md, ERRORS.md, FEATURE_REQUESTS.md).
- **Marker `[[SEND_FILE:/path]]`** pra enviar arquivos como anexo no Telegram.

### Skills premium (todas opcionais, pulam silenciosamente sem a key)

| Skill | Key necessÃ¡ria | Onde pegar |
|---|---|---|
| `visual-gen` (imagem/vÃ­deo via Flux, Imagen, Kling, Veo) | `MUAPI_API_KEY` | https://muapi.ai (pay-per-generation) |
| `reddit-icp-monitor`, `claude-md-generator`, `producthunt-launch-kit`, `meeting-brief-generator` | `GEMINI_API_KEY` | https://aistudio.google.com/app/apikey (grÃ¡tis) |
| `cold-email-verifier` | `VALIDEMAIL_API_KEY` | https://validemail.co (50 grÃ¡tis) |
| `meeting-brief-generator` | `TAVILY_API_KEY` | https://tavily.com (grÃ¡tis) |
| `hackernews-intel` | `HN_KEYWORDS` + (opcional) `SLACK_WEBHOOK` | configure direto no `.env` |
| `reddit-icp-monitor` (modo OAuth, 60 RPM) | `REDDIT_CLIENT_*` | https://www.reddit.com/prefs/apps |

---

## Requisitos

- Container Gradsky (Debian/Ubuntu, root, com /workspace).
- Conta Claude Pro ou Max (CLI logada).
- Bot Telegram criado no @BotFather.
- (Opcional) OpenAI key â€” Ã¡udio entrada.
- (Opcional) ElevenLabs key â€” Ã¡udio saÃ­da.
- (Opcional) Supabase DATABASE_URL â€” memÃ³ria vetorial.

---

## Comandos Ãºteis (depois de instalado)

```bash
pm2 status                      # status do bot
pm2 logs animus-bot             # logs ao vivo
pm2 restart animus-bot          # restart
tail -f animus-bot/logs/bot.log # log da aplicaÃ§Ã£o
cat .env                        # config atual (cuidado, contÃ©m secrets)
```

Pra atualizar o repo (idempotente, com backup automÃ¡tico):

```bash
cd /workspace/Animus
bash scripts/upgrade.sh
```

Se quebrar algo:

```bash
bash scripts/rollback.sh
```

---

## Arquivos relevantes

| Arquivo | O quÃª |
|---|---|
| `SETUP-AGENTE.md` | Roteiro que o Claude segue no container Gradsky |
| `prompt-instalador.txt` | Texto que vocÃª cola no Claude pra iniciar |
| `install.sh` | Wizard interativo CLI (alternativa ao fluxo via Claude) |
| `bootstrap.sh` | Instala deps (Python, Node, PM2, Claude CLI, gh, pandas) |
| `animus-bot/bot.py` | Daemon Telegram (PM2 roda esse) |
| `.env.example` | Template do `.env` â€” copie pra `.env` e preencha |
| `CLAUDE.md` | Personalidade + regras do agente (lida toda sessÃ£o) |
| `CHANGELOG.md` | HistÃ³rico de versÃµes |
| `docs/ANIMUS-OS.md` | Metodologia de orquestracao, Work Objects, camadas e gates |
| `docs/GRADSKY-PAT.md` | Guia de PAT Gradsky para deploys, services, env vars e dominios |
| `.claude/agents/` | 9 subagentes (atlas, helena, aegis, titan, sentinel, victor, apollo, oracle, felipe) |
| `.claude/skills/` | Symlink â†’ `skills/` (auto-discovery) |
| `skills/` | Skills do Animus, incluindo `animus-orchestration-os`, `gradsky-paas`, marketing, dev, vendas, growth e branding |
| `scripts/` | `backup.sh`, `rollback.sh`, `upgrade.sh`, `validate.sh` |
| `docs/TROUBLESHOOTING.md` | Fixes pros 20+ erros mais comuns |

---

## Plataforma Oficial

O Animus usa Claude Code como motor oficial. O fluxo suportado neste repositorio e:

```text
Gradsky -> PM2 -> animus-bot/bot.py -> claude -p -> subagentes -> Telegram
```

Nao ha runtime alternativo no setup principal. A documentacao, o instalador e os scripts de validacao devem permanecer alinhados a esse fluxo.
