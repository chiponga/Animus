# Troubleshooting - Animus

Guia rapido para diagnosticar a instalacao Gradsky + PM2 + Claude Code.

## Instalacao

### `claude` nao encontrado

Rode:

```bash
bash bootstrap.sh
```

Depois valide:

```bash
claude --version
```

### Claude nao autenticado

Sintoma comum: `Not logged in`.

Rode dentro do container:

```bash
claude /login
```

### `.env` ausente

Rode:

```bash
bash install.sh
```

Ou copie `.env.example` para `.env` e preencha as variaveis obrigatorias.

## Bot nao responde no Telegram

1. Verifique PM2:

```bash
pm2 status
pm2 logs animus-bot
```

2. Verifique o token:

```bash
curl "https://api.telegram.org/bot$TELEGRAM_BOT_TOKEN/getMe"
```

3. Verifique `ALLOWED_USERS`.

O valor precisa conter seu Telegram user id numerico.

4. Verifique Claude:

```bash
echo "teste" | claude -p
```

## Skills nao carregam

Recrie o symlink:

```bash
cd /workspace/Animus/.claude
ln -sfn ../skills skills
pm2 restart animus-bot
```

Cada skill precisa ter `SKILL.md` valido.

## Runtime Gaby nao responde

1. Veja se esta rodando:

```bash
pm2 status
pm2 logs gaby-agent-runtime
curl http://localhost:3333/health
```

2. Confirme variaveis:

```bash
grep '^GABY_' .env
```

3. Confirme no NEW ADMIN:

- Toggle do agente externo ligado.
- Webhook apontando para `https://seu-dominio/webhooks/subway`.
- Secret igual ao `GABY_WEBHOOK_SECRET`.
- Token igual ao `GABY_AGENT_API_TOKEN`.

## Deploy Gradsky

Depois que um service ja esta conectado ao GitHub, o padrao e fazer commit/push. A Gradsky inicia redeploy automatico.

Use deploy via API somente para criar service novo ou quando `GRADSKY_FORCE_DEPLOY=true`.

## Comandos uteis

```bash
bash scripts/validate.sh
bash scripts/backup.sh
bash scripts/upgrade.sh
bash scripts/rollback.sh
tail -f animus-bot/logs/bot.log
```

## O que enviar para diagnostico

- Saida de `bash scripts/validate.sh`.
- Ultimas linhas de `pm2 logs animus-bot`.
- Ultimas linhas de `pm2 logs gaby-agent-runtime`.
- `.env` com secrets mascarados.
