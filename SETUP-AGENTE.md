# SETUP-AGENTE.md - Roteiro para instalar o Animus

> Para o Claude Code executar. Leia do inicio ao fim, faca uma pergunta de cada vez e entregue o bot Telegram do Animus rodando 24/7 via PM2 em container Gradsky.

## Arquitetura oficial

```text
Gradsky container
  -> PM2
  -> animus-bot/bot.py
  -> claude -p
  -> Animus orquestra subagentes
  -> Telegram
```

Nao usar fluxo operacional antigo. O setup oficial deste repositorio nao depende de terminal interativo persistente, servico Linux tradicional, paths absolutos antigos ou arquivo de resposta manual.

## Etapa 0 - Pre-checks

Rode:

```bash
test -d /workspace || { echo "Esperava /workspace existir."; exit 1; }
command -v apt-get >/dev/null || { echo "Esperava Debian/Ubuntu com apt-get."; exit 1; }
```

Se falhar, pare e diga ao Chefe:

```text
Esse instalador foi desenhado para container Gradsky persistente com /workspace. O ambiente atual nao bate. Me diga onde voce quer instalar.
```

## Etapa 1 - Clonar ou atualizar repo

```bash
cd /workspace
if [ ! -d /workspace/Animus ]; then
  git clone https://github.com/chiponga/Animus.git
fi
cd /workspace/Animus
git fetch origin
git checkout main
git pull --ff-only origin main || true
```

Se houver alteracoes locais, nao sobrescreva. Avise o Chefe e peca decisao.

## Etapa 2 - Rodar bootstrap

```bash
cd /workspace/Animus
bash bootstrap.sh
```

O bootstrap instala dependencias do projeto:

- Python 3 e libs necessarias.
- Node 22 e npm.
- PM2.
- Claude Code CLI.
- GitHub CLI quando possivel.
- Symlink `.claude/skills -> ../skills`.
- Dependencias de skills que exigem install local.

## Etapa 3 - Conferir login Claude Code

```bash
claude auth status 2>&1 || true
```

Se nao estiver logado:

```bash
claude /login
```

Entregue a URL ao Chefe quando necessario e espere a autenticacao terminar.

## Etapa 4 - Coletar dados do Chefe

Faca uma pergunta de cada vez:

1. Como vai se chamar o agente? Ex: Animus.
2. Como o agente deve te chamar? Ex: Chefe, Felipe.
3. Qual empresa/produto devo registrar? Opcional.
4. Cole o token do bot Telegram do @BotFather.
5. Cole seu user_id Telegram do @userinfobot.
6. DATABASE_URL Supabase/Postgres para memoria persistente? Opcional.
7. OPENAI_API_KEY para transcrever audio? Opcional.
8. ELEVENLABS_API_KEY e ELEVENLABS_VOICE_ID para voz? Opcional.
9. MUAPI_API_KEY para imagem/video? Opcional.
10. GEMINI_API_KEY, VALIDEMAIL_API_KEY e TAVILY_API_KEY para skills premium? Opcional.
11. GRADSKY_TOKEN e GRADSKY_PROJECT_ID para deploys Gradsky? Opcional.
12. GH_TOKEN/GH_USER/GH_EMAIL para repos privados gerados pelas skills? Opcional.

Nunca ecoe secrets no chat. Grave direto no `.env`.

## Etapa 5 - Rodar wizard

Preferencial:

```bash
bash install.sh
```

O wizard escreve `.env` com permissao segura, prepara pastas do bot e inicia PM2.

Se precisar escrever `.env` manualmente, use `umask 077`, preencha somente variaveis reais e finalize com:

```bash
chmod 600 /workspace/Animus/.env
```

## Etapa 6 - Iniciar ou reiniciar bot

```bash
cd /workspace/Animus
pm2 delete animus-bot 2>/dev/null || true
pm2 start animus-bot/bot.py \
  --name animus-bot \
  --interpreter python3 \
  --time \
  --log animus-bot/logs/pm2.log \
  --merge-logs
pm2 save
```

## Etapa 7 - Validar

```bash
bash scripts/validate.sh
```

Validacoes esperadas:

- PM2 com `animus-bot` online.
- Claude Code autenticado.
- `.env` presente e seguro.
- `.claude/skills` apontando para `skills/`.
- Pelo menos 9 agentes em `.claude/agents/`.
- Telegram `getMe` funcionando.
- Dependencias Python/Node essenciais OK.

## Etapa 8 - Smoke test no Telegram

Peca ao Chefe:

```text
Manda "oi" para o bot no Telegram.
```

Esperado:

1. Bot recebe a mensagem.
2. Claude Code e invocado por `claude -p`.
3. Animus responde em PT-BR.
4. Se a tarefa for complexa, Animus delega para subagentes.

## Estrutura entregue

```text
/workspace/Animus/
  .env
  .claude/
    agents/
    skills -> ../skills
  animus-bot/
    bot.py
    inbox/
    sent/
    state/
    logs/
  skills/
  scripts/
    backup.sh
    rollback.sh
    upgrade.sh
    validate.sh
  docs/
    GRADSKY-PAT.md
  CLAUDE.md
  INSTALL.md
  README.md
```

## Comandos uteis

```bash
pm2 status
pm2 logs animus-bot
pm2 restart animus-bot
tail -f animus-bot/logs/bot.log
bash scripts/validate.sh
bash scripts/backup.sh
bash scripts/upgrade.sh
bash scripts/rollback.sh
```

## Mensagem final ao Chefe

Quando `scripts/validate.sh` passar e o Telegram responder:

```text
Animus instalado e online.

- Bot rodando via PM2.
- Claude Code autenticado.
- 9 especialistas disponiveis em .claude/agents/.
- Skills descobertas via .claude/skills.
- Telegram respondendo.

Comandos:
pm2 logs animus-bot
bash scripts/validate.sh
bash scripts/upgrade.sh
bash scripts/rollback.sh
```
