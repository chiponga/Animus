# Animus — Agente Claude Code + Telegram

Agente orquestrador rodando 24/7 num container Gradsky (Debian/Ubuntu persistente). Cada mensagem do Telegram dispara um `claude -p` headless que delega pros 9 subagentes especialistas (atlas, helena, aegis, titan, sentinel, victor, apollo, oracle, felipe).

---

## Instalação em 1 comando (recomendado)

### Pré-requisito
- Container Gradsky (Debian/Ubuntu, root) com `/workspace` persistente.
- Claude Code CLI logado na sua conta Pro/Max (ou rode `claude /login` na primeira vez).

### Fluxo

**1.** Abra o Claude Code dentro do container Gradsky:

```bash
cd /workspace && claude
```

**2.** Cole o prompt abaixo (também está em [`prompt-instalador.txt`](./prompt-instalador.txt)):

```
Olá! Quero instalar o agente Animus no meu container Gradsky.

Repositório: https://github.com/chiponga/Animus

Sua missão:
1. Clona o repo em /workspace/Animus (se ainda não existir).
2. Lê o arquivo INSTALL.md que está na raiz e executa todos os passos.
3. Me faz UMA pergunta de cada vez, espera eu responder antes da próxima.
```

**3.** Responda as perguntas conforme o Claude pedir (nome do agente, dono, token Telegram do @BotFather, seu user_id do @userinfobot, e os opcionais OpenAI/ElevenLabs/Supabase).

**4.** Em ~5 min o Claude vai dizer "agente no ar". Mande uma mensagem no Telegram pro seu bot.

> O roteiro que o Claude segue é o [`INSTALL.md`](./INSTALL.md). Ele lê, instala dependências via `bootstrap.sh`, escreve o `.env`, sobe o bot via PM2 e valida.

---

## Instalação manual (sem o Claude intermediando)

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
   │
   ▼
[bot.py — PM2, sempre vivo]    ← long polling getUpdates
   │
   ▼ subprocess STDIN
[claude -p stream-json]        ← cada msg é uma invocação
   │
   ├── responde direto (text events) → Telegram
   └── delega via Task tool → atlas / helena / aegis / titan / sentinel / victor / apollo / oracle / felipe
                              ↓
                          resposta consolidada → Telegram
```

Resiliência:
- PM2 reinicia o bot se ele cair (`pm2 save && pm2 startup`).
- Cada `claude -p` é stateless (session via flag `-c` se já houve sessão anterior).
- Inbox/sent persistente em `animus-bot/{inbox,sent,state,logs}/` pra auditoria.
- Volumes Gradsky (`/workspace`, `/root`, `/opt`) sobrevivem a restart/redeploy.

---

## Recursos

- **Bot externo Python** sempre vivo, independente do Claude Code.
- **9 subagentes especialistas** em `.claude/agents/` (auto-descobertos).
- **57 skills** em `skills/` (auto-descobertas via symlink `.claude/skills/ → ../skills/`).
- **Áudio bidirecional opcional** (Whisper entrada + ElevenLabs TTS saída).
- **Memória vetorial opcional** via Supabase Postgres + pgvector (DATABASE_URL no `.env`).
- **Aprendizado contínuo** via `.learnings/` (LEARNINGS.md, ERRORS.md, FEATURE_REQUESTS.md).
- **Marker `[[SEND_FILE:/path]]`** pra enviar arquivos como anexo no Telegram.

### Skills premium (todas opcionais, pulam silenciosamente sem a key)

| Skill | Key necessária | Onde pegar |
|---|---|---|
| `visual-gen` (imagem/vídeo via Flux, Imagen, Kling, Veo) | `MUAPI_API_KEY` | https://muapi.ai (pay-per-generation) |
| `reddit-icp-monitor`, `claude-md-generator`, `producthunt-launch-kit`, `meeting-brief-generator` | `GEMINI_API_KEY` | https://aistudio.google.com/app/apikey (grátis) |
| `cold-email-verifier` | `VALIDEMAIL_API_KEY` | https://validemail.co (50 grátis) |
| `meeting-brief-generator` | `TAVILY_API_KEY` | https://tavily.com (grátis) |
| `hackernews-intel` | `HN_KEYWORDS` + (opcional) `SLACK_WEBHOOK` | configure direto no `.env` |
| `reddit-icp-monitor` (modo OAuth, 60 RPM) | `REDDIT_CLIENT_*` | https://www.reddit.com/prefs/apps |

---

## Requisitos

- Container Gradsky (Debian/Ubuntu, root, com /workspace).
- Conta Claude Pro ou Max (CLI logada).
- Bot Telegram criado no @BotFather.
- (Opcional) OpenAI key — áudio entrada.
- (Opcional) ElevenLabs key — áudio saída.
- (Opcional) Supabase DATABASE_URL — memória vetorial.

---

## Comandos úteis (depois de instalado)

```bash
pm2 status                      # status do bot
pm2 logs animus-bot             # logs ao vivo
pm2 restart animus-bot          # restart
tail -f animus-bot/logs/bot.log # log da aplicação
cat .env                        # config atual (cuidado, contém secrets)
```

Pra atualizar o repo (idempotente, com backup automático):

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

| Arquivo | O quê |
|---|---|
| `SETUP-AGENTE.md` | Roteiro que o Claude segue (MODO A local + MODO B SSH remoto) |
| `prompt-instalador.txt` | Texto que você cola no Claude pra iniciar |
| `install.sh` | Wizard interativo CLI (alternativa ao fluxo via Claude) |
| `bootstrap.sh` | Instala deps (Python, Node, PM2, Claude CLI, gh, pandas) |
| `animus-bot/bot.py` | Daemon Telegram (PM2 roda esse) |
| `.env.example` | Template do `.env` — copie pra `.env` e preencha |
| `CLAUDE.md` | Personalidade + regras do agente (lida toda sessão) |
| `CHANGELOG.md` | Histórico de versões |
| `.claude/agents/` | 9 subagentes (atlas, helena, aegis, titan, sentinel, victor, apollo, oracle, felipe) |
| `.claude/skills/` | Symlink → `skills/` (auto-discovery) |
| `skills/` | 57 skills (marketing, dev, vendas, growth, branding, etc.) |
| `scripts/` | `backup.sh`, `rollback.sh`, `upgrade.sh`, `validate.sh` |
| `docs/TROUBLESHOOTING.md` | Fixes pros 20+ erros mais comuns |

---

## Por que Claude Code (não OpenClaw)?

| Critério | Animus (Claude Code) | OpenClaw |
|---|---|---|
| Skills auto-discovery | ✅ nativo via `.claude/skills/` | precisa adapter |
| LLMs alternativos (GLM, Codex) | ✗ só Claude | ✅ vantagem dele |
| Já paga Claude Pro/Max? | ✅ sem custo extra | redundante |
| Skill tool nativo | ✅ Claude carrega 57 skills no boot | manual |
| Maturidade do CLI | ✅ 2.1.144 estável | menos testado |

**Veredito**: se você já tem Claude Pro/Max, fica com Claude Code (este repo). OpenClaw só compensa pra quem quer rodar GLM 4.5 (Z.ai) ou GPT Codex 5.5 sem assinatura Anthropic.

---

## Notas legacy

`INSTRUCAO-PARA-ALUNO.md`, `PASSO-A-PASSO.txt`, `launchd/` pertencem ao fluxo antigo (Mac local + launchd). Ficam preservados mas não são usados no fluxo Gradsky/VPS atual.
