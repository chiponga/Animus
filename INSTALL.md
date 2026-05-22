# INSTALL.md - roteiro para instalar o Animus

Este arquivo e o roteiro para instalar o Animus em container Gradsky persistente.

## Ambiente alvo

- Debian/Ubuntu com `apt-get`.
- Diretorio `/workspace`.
- PM2 como supervisor.
- Claude Code CLI logado.

Nao use systemd, tmux ou paths antigos de VPS.

## Passos

```bash
cd /workspace
git clone https://github.com/chiponga/Animus.git
cd Animus
bash install.sh
```

O instalador:

1. Roda `bootstrap.sh`.
2. Pergunta dados do Telegram e opcionais.
3. Escreve `.env` com modo 600.
4. Prepara `animus-bot/{inbox,sent,state,logs}`.
5. Inicia `animus-bot/bot.py` via PM2.

## Validacao

```bash
pm2 status
pm2 logs animus-bot --lines 50
python3 -m py_compile animus-bot/bot.py
bash scripts/validate.sh
```

## Gaby Agent Runtime

O agente de atendimento do jogo/SaaS fica separado da Animus em:

```text
apps/gaby-agent-runtime
```

Ele recebe webhooks do NEW ADMIN, valida HMAC, enfileira eventos, processa com o agente Gaby e responde usando a Agent API do gestor.
