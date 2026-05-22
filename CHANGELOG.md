# Changelog

## 2026-05-20

- Adicionado `apps/gaby-agent-runtime`, runtime HTTP independente para atendimento do jogo/SaaS.
- Webhook `/webhooks/subway` com validacao HMAC.
- Fila em memoria com trava por `session_id`, permitindo conversas paralelas sem misturar ordem da mesma sessao.
- Cliente da API `/api/agent/v1` do NEW ADMIN para contexto, mensagens, PIX, bonus e transacoes.
- `.env.example`, `install.sh` e `bootstrap.sh` atualizados para variaveis do runtime Gaby.
- README, INSTALL e SETUP reescritos para Gradsky + PM2 + Claude Code.
- Corrigidos arquivos com conflito de merge e texto corrompido por encoding.

## 2026-05-19

- Rebrand para Animus.
- Arquitetura de agentes premium: Atlas, Aegis, Helena, Victor, Sentinel, Titan, Apollo, Oracle e Felipe.
- Skill `felipe-senior-dev-os`.
- Skill `gradsky-paas`.
- Skill `animus-orchestration-os`.

## 2026-05-18

- Skills premium e automacoes operacionais.
- Scripts de backup, rollback, upgrade e validacao.

## 2026-05-15

- Skill `visual-gen`.

## 2026-05-10

- Primeira versao do agente Telegram com Claude Code.
