# Deploy

## Principio

Deploy nao e copiar arquivo nem subir container. Deploy e pipeline controlado: build, config, migration, release, healthcheck, promocao, observabilidade e rollback.

## Checklist pre-deploy

- [ ] Build reproduzivel.
- [ ] Dependencias travadas.
- [ ] Env vars conferidas sem expor valores.
- [ ] Migration revisada.
- [ ] Plano de rollback definido.
- [ ] Healthcheck real implementado.
- [ ] Logs e metricas disponiveis.
- [ ] Smoke test definido.

## Build

Regras:
- Build deve falhar cedo.
- Separar build de runtime.
- Imagem Docker nao deve conter secrets.
- Artefato deve ter versao/release id.

## Env vars

- Validar no boot.
- Falhar com mensagem clara se ausente.
- Nunca logar valor sensivel.
- Documentar obrigatorias e opcionais.

## Migrations

Padrao seguro:
1. Expand: adicionar coluna/tabela compativel.
2. Deploy app que escreve nos dois formatos se necessario.
3. Backfill idempotente.
4. Contract: remover antigo depois de validar.

Evite:
- Drop destrutivo direto.
- Renomear coluna sem compatibilidade.
- Migration longa sem plano.

## Healthcheck

Liveness:
- Processo esta vivo.

Readiness:
- App consegue atender trafego real.
- Dependencias criticas verificadas com timeout curto.

Healthcheck falso:
- Endpoint retorna 200 sem testar nada relevante.

## Blue/green

Use quando:
- Precisa rollback rapido.
- Infra permite duas versoes simultaneas.

Fluxo:
1. Sobe candidate.
2. Roda readiness.
3. Roda smoke.
4. Promove trafego.
5. Mantem versao anterior por janela curta.

## Canary

Use quando:
- Quer reduzir risco com subset de trafego.
- Tem metricas boas.

Nao use canary sem:
- Medir erro/latencia.
- Reverter automaticamente ou manualmente rapido.

## PM2

Checklist processo:
- Nome estavel.
- Diretorio de trabalho correto.
- `.env` com permissao segura.
- Restart configurado.
- Logs em arquivo ou PM2.
- Graceful shutdown quando necessario.

## Docker

Checklist:
- `HEALTHCHECK`.
- Usuario nao-root.
- Sinais tratados.
- Graceful shutdown.
- Volumes declarados.
- Logs stdout/stderr.

## Gradsky-like deploy

Estados minimos:
- queued
- building
- built
- deploying
- running_candidate
- active
- failed
- rolled_back

Regra:
- Nao retornar sucesso antes da release estar ativa ou explicitamente marcada como assyncrona com status rastreavel.

## Tempo maximo

Defina timeout por etapa:
- Build.
- Pull image.
- Container start.
- Readiness.
- Smoke.
- Promotion.

Timeout sem estado claro e bug de deploy engine.

## Estrategia para falhas

- Falha antes de promover: manter release atual.
- Falha depois de promover: rollback para ultima active.
- Falha de migration: parar, nao tentar gambiarra em producao.
- Falha parcial: estado precisa refletir a verdade.
