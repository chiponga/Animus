# SETUP-AGENTE.md - instalacao do Animus

Use este roteiro quando o Claude Code for instalar o Animus no container Gradsky.

## Fluxo oficial

```text
Gradsky container
  -> PM2
  -> animus-bot/bot.py
  -> claude -p
  -> Animus
  -> Telegram
```

## Pre-checks

```bash
test -d /workspace || { echo "Esperava /workspace"; exit 1; }
command -v apt-get >/dev/null || { echo "Esperava Debian/Ubuntu"; exit 1; }
```

## Instalar

```bash
cd /workspace
if [ ! -d /workspace/Animus ]; then
  git clone https://github.com/chiponga/Animus.git
fi
cd /workspace/Animus
bash install.sh
```

## Depois de instalar

```bash
pm2 status
pm2 logs animus-bot
bash scripts/validate.sh
```

## Observacao

O runtime de atendimento do jogo nao e a Animus. Ele fica em `apps/gaby-agent-runtime` e pode ser iniciado separadamente.
