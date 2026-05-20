<<<<<<< HEAD
﻿# INSTALL.md â€” instruÃ§Ãµes para o Claude que estÃ¡ instalando o agente

> **Para vocÃª, Claude.** Esse arquivo Ã© o roteiro que o Chefe quer que vocÃª siga quando ele te der o repo e pedir "instala esse agente".
>
> Ambiente alvo: **container Gradsky persistente** (Debian/Ubuntu, sem gerenciador init tradicional, sem sudo, sem Postgres local, sem Caddy local â€” o provedor cuida do HTTPS).
>
> O fluxo oficial deste repositorio e Gradsky + PM2 + Claude Code.

---

## 0. PrÃ©-checks

```bash
# Confirma que estÃ¡ num Gradsky-like (Debian/Ubuntu, root)
test -d /workspace || { echo "Esperava /workspace existir."; exit 1; }
[[ "$EUID" -eq 0 ]] || { echo "Esperava rodar como root."; exit 1; }
command -v apt-get >/dev/null || { echo "Esperava apt-get disponÃ­vel."; exit 1; }
```

Se falhar qualquer um, **pare e avise o Chefe**: "esse instalador Ã© pra container Gradsky (Debian/Ubuntu, root, com /workspace). Esse ambiente nÃ£o bate. Me diz onde vocÃª quer instalar."
=======
# INSTALL.md — instruções para o Claude que está instalando o agente

> **Para você, Claude.** Esse arquivo é o roteiro que o Chefe quer que você siga quando ele te der o repo e pedir "instala esse agente".
>
> Ambiente alvo: **container Gradsky persistente** (Debian/Ubuntu, sem systemd, sem sudo, sem Postgres local, sem Caddy local — o provedor cuida do HTTPS).
>
> NÃO é uma VPS Ubuntu tradicional. Ignore qualquer referência a `systemctl`, `/opt/animus-bot/`, `caddy`, `postgresql-16` que apareça em arquivos legados (`SETUP-AGENTE.md` antigo, `CLAUDE.md`, etc.).

---

## 0. Pré-checks

```bash
# Confirma que está num Gradsky-like (Debian/Ubuntu, root)
test -d /workspace || { echo "Esperava /workspace existir."; exit 1; }
[[ "$EUID" -eq 0 ]] || { echo "Esperava rodar como root."; exit 1; }
command -v apt-get >/dev/null || { echo "Esperava apt-get disponível."; exit 1; }
```

Se falhar qualquer um, **pare e avise o Chefe**: "esse instalador é pra container Gradsky (Debian/Ubuntu, root, com /workspace). Esse ambiente não bate. Me diz onde você quer instalar."
>>>>>>> e3f95ead324819de792d72b88e4ceac8037a42fb

---

## 1. Clonar o repo

<<<<<<< HEAD
Se o repo ainda nÃ£o estiver clonado:
=======
Se o repo ainda não estiver clonado:
>>>>>>> e3f95ead324819de792d72b88e4ceac8037a42fb

```bash
cd /workspace
git clone https://github.com/chiponga/Animus.git
cd Animus
```

<<<<<<< HEAD
Se jÃ¡ estiver, garante que estÃ¡ em `main` e atualizado:
=======
Se já estiver, garante que está em `main` e atualizado:
>>>>>>> e3f95ead324819de792d72b88e4ceac8037a42fb

```bash
cd /workspace/Animus
git fetch origin
git checkout main
git pull --ff-only origin main
```

---

## 2. Coletar respostas do Chefe (UMA pergunta de cada vez)

<<<<<<< HEAD
**Importante:** pergunte **uma de cada vez** e espere o Chefe responder antes da prÃ³xima. NÃ£o dispare todas juntas.

Ordem das perguntas:

1. **"Como vai se chamar seu agente?"** (ex: Animus, Atlas, Nexus) â†’ `AGENT_NAME`
2. **"Como eu devo te chamar?"** (ex: Chefe, Felipe, Sandra) â†’ `OWNER_NAME`
3. **"Nome da sua empresa/produto?"** (opcional, enter pula) â†’ `COMPANY_NAME` / `PRODUCT_NAME`
4. **"Cole o token do bot Telegram"** (do @BotFather). Se ele nÃ£o tem, oriente:
   > "Abre o Telegram â†’ procura @BotFather â†’ /newbot â†’ escolha um nome â†’ ele te dÃ¡ um token tipo `123456:ABC...`. Cola aqui."
   â†’ `TELEGRAM_BOT_TOKEN`
5. **"Cole seu user_id do Telegram"** (numÃ©rico). Se nÃ£o souber:
   > "Abre o Telegram â†’ procura @userinfobot â†’ manda qualquer mensagem â†’ ele responde com seu user_id (nÃºmero)."
   â†’ `OWNER_TELEGRAM_ID` e `ALLOWED_USERS` (mesmo valor por padrÃ£o)
6. **"(Opcional) DATABASE_URL do Supabase pra memÃ³ria persistente?"** â€” enter pula.
7. **"(Opcional) Chave OpenAI pra transcrever Ã¡udios?"** â€” enter pula.
8. **"(Opcional) Chave ElevenLabs pra TTS feminino?"** â€” se sim, peÃ§a o `ELEVENLABS_VOICE_ID` tambÃ©m.
9. **"(Opcional) PAT Gradsky para deploys de projetos?"** â€” enter pula. Se preencher, peca tambem `GRADSKY_PROJECT_ID` se houver mais de um projeto.
10. **"(Opcional) GH_TOKEN/GH_USER para repos privados gerados pelas skills?"** â€” enter pula.

**Nunca** ecoe o valor do token/chave de volta pro Chefe no chat â€” eles vÃ£o pro `.env` direto.
=======
**Importante:** pergunte **uma de cada vez** e espere o Chefe responder antes da próxima. Não dispare todas juntas.

Ordem das perguntas:

1. **"Como vai se chamar seu agente?"** (ex: Animus, Atlas, Nexus) → `AGENT_NAME`
2. **"Como eu devo te chamar?"** (ex: Chefe, Felipe, Sandra) → `OWNER_NAME`
3. **"Nome da sua empresa/produto?"** (opcional, enter pula) → `COMPANY_NAME` / `PRODUCT_NAME`
4. **"Cole o token do bot Telegram"** (do @BotFather). Se ele não tem, oriente:
   > "Abre o Telegram → procura @BotFather → /newbot → escolha um nome → ele te dá um token tipo `123456:ABC...`. Cola aqui."
   → `TELEGRAM_BOT_TOKEN`
5. **"Cole seu user_id do Telegram"** (numérico). Se não souber:
   > "Abre o Telegram → procura @userinfobot → manda qualquer mensagem → ele responde com seu user_id (número)."
   → `OWNER_TELEGRAM_ID` e `ALLOWED_USERS` (mesmo valor por padrão)
6. **"(Opcional) DATABASE_URL do Supabase pra memória persistente?"** — enter pula.
7. **"(Opcional) Chave OpenAI pra transcrever áudios?"** — enter pula.
8. **"(Opcional) Chave ElevenLabs pra TTS feminino?"** — se sim, peça o `ELEVENLABS_VOICE_ID` também.

**Nunca** ecoe o valor do token/chave de volta pro Chefe no chat — eles vão pro `.env` direto.
>>>>>>> e3f95ead324819de792d72b88e4ceac8037a42fb

---

## 3. Rodar bootstrap (deps)

```bash
cd /workspace/Animus
bash bootstrap.sh
```

Isso instala: Python + libs, Node 22, PM2, Claude Code CLI, gh.

<<<<<<< HEAD
DÃ¡ ~3-5 minutos. Avise o Chefe: "instalando dependÃªncias, espera uns 5 min."

Se algum passo falhar, leia o erro, tente entender. Erros comuns:
- `apt-get update` falha â†’ repo apt corrompido, tente `apt-get clean && apt-get update`
- `npm install -g` falha â†’ checa permissÃ£o (`ls -la /usr/lib/node_modules`)
- `gh` nÃ£o instala â†’ segue sem ele, nÃ£o bloqueia
=======
Dá ~3-5 minutos. Avise o Chefe: "instalando dependências, espera uns 5 min."

Se algum passo falhar, leia o erro, tente entender. Erros comuns:
- `apt-get update` falha → repo apt corrompido, tente `apt-get clean && apt-get update`
- `npm install -g` falha → checa permissão (`ls -la /usr/lib/node_modules`)
- `gh` não instala → segue sem ele, não bloqueia
>>>>>>> e3f95ead324819de792d72b88e4ceac8037a42fb

---

## 4. Escrever o `.env`

Crie `/workspace/Animus/.env` com **modo 600** (`umask 077` antes do `cat >`). Estrutura:

```bash
umask 077
cat > /workspace/Animus/.env <<EOF
AGENT_NAME=<resposta>
OWNER_NAME=<resposta>
OWNER_TELEGRAM_ID=<resposta>
COMPANY_NAME=<resposta>
PRODUCT_NAME=<resposta>

TELEGRAM_BOT_TOKEN=<resposta>
ALLOWED_USERS=<resposta>

CLAUDE_TIMEOUT=180

DATABASE_URL=<resposta ou vazio>
OPENAI_API_KEY=<resposta ou vazio>
ELEVENLABS_API_KEY=<resposta ou vazio>
ELEVENLABS_VOICE_ID=<resposta ou vazio>
ANTHROPIC_API_KEY=<resposta ou vazio>
<<<<<<< HEAD

GH_TOKEN=<resposta ou vazio>
GH_USER=<resposta ou vazio>
GH_EMAIL=<resposta ou vazio>
GRADSKY_TOKEN=<resposta ou vazio>
GRADSKY_API=https://api.gradsky.com.br
GRADSKY_PROJECT_ID=<resposta ou vazio>
GRADSKY_ATTACH_DOMAIN=false
DOMINIO_BASE=<resposta ou vazio>
=======
>>>>>>> e3f95ead324819de792d72b88e4ceac8037a42fb
EOF
chmod 600 /workspace/Animus/.env
```

<<<<<<< HEAD
**Atalho:** se preferir, pode rodar `bash install.sh` que jÃ¡ faz todas as perguntas em modo CLI e escreve o `.env`. Mas se o Chefe estÃ¡ conversando com vocÃª no chat, Ã© mais natural vocÃª fazer as perguntas e escrever o arquivo direto.
=======
**Atalho:** se preferir, pode rodar `bash install.sh` que já faz todas as perguntas em modo CLI e escreve o `.env`. Mas se o Chefe está conversando com você no chat, é mais natural você fazer as perguntas e escrever o arquivo direto.
>>>>>>> e3f95ead324819de792d72b88e4ceac8037a42fb

---

## 5. Subir o bot via PM2

```bash
cd /workspace/Animus
mkdir -p animus-bot/{inbox,sent,state,logs}

<<<<<<< HEAD
# Mata instÃ¢ncia antiga (idempotÃªncia)
=======
# Mata instância antiga (idempotência)
>>>>>>> e3f95ead324819de792d72b88e4ceac8037a42fb
pm2 delete animus-bot 2>/dev/null || true

pm2 start animus-bot/bot.py \
  --name animus-bot \
  --interpreter python3 \
  --time \
  --log animus-bot/logs/pm2.log \
  --merge-logs

pm2 save
```

<<<<<<< HEAD
> Se o `AGENT_NAME` nÃ£o for "Animus", use `${AGENT_NAME,,}-bot` como nome do processo PM2 pra ficar consistente.
=======
> Se o `AGENT_NAME` não for "Animus", use `${AGENT_NAME,,}-bot` como nome do processo PM2 pra ficar consistente.
>>>>>>> e3f95ead324819de792d72b88e4ceac8037a42fb

---

## 6. Validar

```bash
# 1. Processo no PM2
pm2 status

# 2. Bot conectou no Telegram?
sleep 3
grep -E '(bot conectado|getMe|polling loop)' /workspace/Animus/animus-bot/logs/bot.log | tail -5

# 3. Claude CLI logado?
claude --version
```

<<<<<<< HEAD
Se o log mostrar **"bot conectado: @<username>"** e **"polling loop iniciado"**, estÃ¡ no ar.
=======
Se o log mostrar **"bot conectado: @<username>"** e **"polling loop iniciado"**, está no ar.
>>>>>>> e3f95ead324819de792d72b88e4ceac8037a42fb

---

## 7. Teste de ponta a ponta

<<<<<<< HEAD
PeÃ§a ao Chefe: **"Manda uma mensagem qualquer pro seu bot no Telegram (`@nome_do_bot`)."**

Ele deve ver:
1. ReaÃ§Ã£o ðŸ‘€ na mensagem dele
2. Resposta curta tipo "Anotado, chefe. Chamando o time."
3. Depois (10-60s) a resposta gerada pelo agente

Se nÃ£o chegar nada:
- `pm2 logs animus-bot --lines 50` â€” vÃª erro
- Checa `ALLOWED_USERS` no `.env` â€” o user_id do Chefe TEM que estar lÃ¡
- Checa se o `TELEGRAM_BOT_TOKEN` estÃ¡ correto (sem espaÃ§os, sem aspas)

---

## 8. PrÃ³ximos passos opcionais

Quando o bÃ¡sico estiver funcionando, ofereÃ§a ao Chefe (sem fazer ainda):

- **Skills externas:** `ui-ux-pro-max`, `design-system`, `ui-styling`, `self-improvement` (ele jÃ¡ tem cÃ³pias em `skills/`).
- **Subagentes:** os arquivos em `.claude/agents/` (atlas, helena, aegis, etc.) ficam disponÃ­veis automaticamente.
- **MemÃ³ria vetorial:** se ele jÃ¡ configurou Supabase com pgvector, conecte via `DATABASE_URL`. SenÃ£o, deixe pra depois.
- **Ãudio bidirecional:** depende de OpenAI + ElevenLabs configurados. Se estiverem no `.env`, o bot jÃ¡ usa.
=======
Peça ao Chefe: **"Manda uma mensagem qualquer pro seu bot no Telegram (`@nome_do_bot`)."**

Ele deve ver:
1. Reação 👀 na mensagem dele
2. Resposta curta tipo "Anotado, chefe. Chamando o time."
3. Depois (10-60s) a resposta gerada pelo agente

Se não chegar nada:
- `pm2 logs animus-bot --lines 50` — vê erro
- Checa `ALLOWED_USERS` no `.env` — o user_id do Chefe TEM que estar lá
- Checa se o `TELEGRAM_BOT_TOKEN` está correto (sem espaços, sem aspas)

---

## 8. Próximos passos opcionais

Quando o básico estiver funcionando, ofereça ao Chefe (sem fazer ainda):

- **Skills externas:** `ui-ux-pro-max`, `design-system`, `ui-styling`, `self-improvement` (ele já tem cópias em `skills/`).
- **Subagentes:** os arquivos em `.claude/agents/` (atlas, helena, aegis, etc.) ficam disponíveis automaticamente.
- **Memória vetorial:** se ele já configurou Supabase com pgvector, conecte via `DATABASE_URL`. Senão, deixe pra depois.
- **Áudio bidirecional:** depende de OpenAI + ElevenLabs configurados. Se estiverem no `.env`, o bot já usa.
>>>>>>> e3f95ead324819de792d72b88e4ceac8037a42fb

---

## Troubleshooting comum

<<<<<<< HEAD
| Sintoma | Causa provÃ¡vel | Fix |
|---|---|---|
| `pm2 status` mostra bot como `errored` | `.env` faltando vars obrigatÃ³rias | `pm2 logs animus-bot` â†’ mostra qual var falta |
| Bot conecta mas nÃ£o responde | `ALLOWED_USERS` nÃ£o inclui o user_id do Chefe | edita `.env`, `pm2 restart animus-bot` |
| Claude CLI dÃ¡ `401 Unauthorized` | NÃ£o logou | rode `claude /login` interativo |
| `npm install -g` dÃ¡ EACCES | npm prefix ruim | `npm config set prefix /usr/local && npm install -g pm2 @anthropic-ai/claude-code` |
| PM2 nao restaura apos restart do container | lista de processos nao foi salva/restaurada | rode `pm2 save` e, quando necessario, `pm2 resurrect` |

---

## Regras pra vocÃª (Claude)

- **Pergunta uma de cada vez.** NÃ£o dispare formulÃ¡rio.
- **NÃ£o ecoe secrets de volta.** Token, chaves, DATABASE_URL â€” vai direto pro `.env`.
- **Confirma antes de destruir.** Se jÃ¡ existe `.env`, pergunte antes de sobrescrever.
- **IdempotÃªncia.** Tudo deve poder rodar 2x sem quebrar.
- **Erro = pare e reporte.** NÃ£o tente "consertar" silenciosamente algo que falhou. Mostre o erro ao Chefe e ofereÃ§a opÃ§Ãµes.
=======
| Sintoma | Causa provável | Fix |
|---|---|---|
| `pm2 status` mostra bot como `errored` | `.env` faltando vars obrigatórias | `pm2 logs animus-bot` → mostra qual var falta |
| Bot conecta mas não responde | `ALLOWED_USERS` não inclui o user_id do Chefe | edita `.env`, `pm2 restart animus-bot` |
| Claude CLI dá `401 Unauthorized` | Não logou | rode `claude /login` interativo |
| `npm install -g` dá EACCES | npm prefix ruim | `npm config set prefix /usr/local && npm install -g pm2 @anthropic-ai/claude-code` |
| PM2 não persiste após reboot | Gradsky sem systemd → `pm2 startup` não cola | rode `pm2 resurrect` no script de boot do container, ou aceite que precisa rodar manualmente |

---

## Regras pra você (Claude)

- **Pergunta uma de cada vez.** Não dispare formulário.
- **Não ecoe secrets de volta.** Token, chaves, DATABASE_URL — vai direto pro `.env`.
- **Confirma antes de destruir.** Se já existe `.env`, pergunte antes de sobrescrever.
- **Idempotência.** Tudo deve poder rodar 2x sem quebrar.
- **Erro = pare e reporte.** Não tente "consertar" silenciosamente algo que falhou. Mostre o erro ao Chefe e ofereça opções.
>>>>>>> e3f95ead324819de792d72b88e4ceac8037a42fb
