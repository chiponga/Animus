# Como instalar o Animus no Gradsky

Este e o caminho recomendado para instalar o Animus com Telegram, Claude Code e PM2.

Repositorio oficial: https://github.com/chiponga/Animus.git

## O que voce vai precisar

- Container Gradsky persistente com `/workspace`.
- Conta Claude Pro ou Max.
- Claude Code autenticado no container.
- Bot Telegram criado no @BotFather.
- Seu user_id Telegram obtido no @userinfobot.
- Opcional: chaves OpenAI, ElevenLabs, Supabase, Muapi, Gemini, ValidEmail e Tavily.

## Passo 1 - Criar o bot Telegram

1. Abra o Telegram.
2. Procure `@BotFather`.
3. Envie `/newbot`.
4. Escolha nome e username.
5. Copie o token.

Para descobrir seu user_id:

1. Procure `@userinfobot`.
2. Envie `/start`.
3. Copie o numero retornado.

## Passo 2 - Abrir Claude Code no Gradsky

No container Gradsky:

```bash
cd /workspace
claude
```

Se o Claude ainda nao estiver logado, rode:

```bash
claude /login
```

## Passo 3 - Pedir a instalacao

Cole este prompt no Claude Code:

```text
Quero instalar o Animus no meu container Gradsky.

Repositorio: https://github.com/chiponga/Animus.git

Leia o INSTALL.md da raiz, execute o setup, faca uma pergunta de cada vez e no final valide com scripts/validate.sh.
```

## Passo 4 - Responder as perguntas

O instalador vai pedir:

1. Nome do agente.
2. Como o agente deve chamar voce.
3. Empresa/produto.
4. Token do Telegram.
5. Seu user_id Telegram.
6. Chaves opcionais.

Se nao tiver alguma chave opcional, deixe em branco.

## Passo 5 - Validar

Quando terminar, rode:

```bash
bash scripts/validate.sh
```

O esperado:

- `animus-bot` online no PM2.
- Claude Code autenticado.
- `.env` seguro.
- `.claude/skills` apontando para `skills/`.
- Telegram conectado.

## Passo 6 - Testar no Telegram

Envie uma mensagem para o bot:

```text
oi
```

Depois teste comandos mais completos:

```text
Animus, use Felipe e revise esse projeto para producao.
Animus, peca para Victor criar uma copy de landing page.
Animus, peca para Aegis auditar a seguranca desse backend.
Animus, peca para Titan validar o deploy.
Animus, coordene Atlas, Helena e Sentinel para criar uma feature.
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

## Suporte

Use sempre o repositorio oficial:

https://github.com/chiponga/Animus.git
