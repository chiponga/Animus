# Gradsky Patterns

## Principio

Em Gradsky, deploy nunca e so "subir container". Deploy e pipeline transacional com build, release, runtime, healthcheck, promocao, logs, metrics, billing, quotas, rollback e estado consistente.

## Componentes

Control Plane:
- API e estado autoritativo.
- Decide releases, tenants, quotas, billing e permissoes.

Worker:
- Executa build/deploy/jobs.
- Deve ser idempotente.
- Reporta estado verdadeiro.

Runtime Agent:
- Roda perto do Docker/runtime.
- Inicia, para, inspeciona containers.
- Coleta logs/health.

GradPack:
- Contrato de build/runtime.
- Define app, ports, env, healthcheck e resources.

BuildKit:
- Build reproduzivel.
- Cache controlado.
- Sem secrets vazando em layers.

Docker runtime:
- Container imutavel.
- Healthcheck.
- Logs stdout/stderr.
- Network e volumes isolados.

Release Engine:
- Cria release rastreavel.
- Mantem artefato, config, env hash e status.

Deploy Engine:
- Orquestra candidate, readiness, promotion e rollback.

## Estado transacional

Estados recomendados:
- queued
- building
- build_failed
- built
- deploying
- candidate_running
- candidate_unhealthy
- active
- failed
- rollback_running
- rolled_back

Regra:
- Status precisa refletir a verdade.
- Nao marcar active antes de candidate saudavel e promovido.
- Nao retornar sucesso se deploy continua incerto.

## ACTIVE_RELEASE_NOT_FOUND

Significa uma dessas falhas:
- App nunca teve release promovida.
- Estado foi corrompido.
- Query filtra tenant/app errado.
- Promotion falhou depois do container subir.
- Deploy retornou antes de persistir active release.

Investigacao:
1. Buscar app_id, tenant_id e release_id.
2. Conferir releases por estado.
3. Conferir logs do deploy engine.
4. Conferir eventos de promotion.
5. Verificar se healthcheck impediu ativacao.

## Deploy transacional

Fluxo:
1. Criar release em `queued`.
2. Build.
3. Persistir artifact/image digest.
4. Criar candidate.
5. Rodar readiness.
6. Smoke test interno.
7. Promover para active em transacao.
8. Atualizar routing.
9. Registrar audit log.
10. Encerrar release anterior quando seguro.

## Evitar retorno prematuro

Anti-pattern:
- API retorna "deployed" apos enfileirar job.

Correto:
- Retornar `deployment_id` com status `queued`, ou aguardar ate `active`.
- UI deve refletir estado real.

## Healthcheck real

Deve validar:
- Processo responde.
- Porta correta.
- App carregou env obrigatoria.
- Dependencias criticas quando readiness.

Nao basta:
- Container esta "running".

## Rollback seguro

Requisitos:
- Ultima release active conhecida.
- Schema compativel.
- Routing reversivel.
- Audit log.
- Motivo do rollback.

## Logs

Logs devem permitir:
- Seguir deploy por deployment_id.
- Ver build output.
- Ver start container.
- Ver healthcheck failures.
- Ver promotion.
- Ver rollback.

## Metrics

- deploy_duration.
- build_duration.
- promotion_duration.
- deploy_success_rate.
- rollback_count.
- candidate_health_failures.
- active_release_missing_count.
- queue_wait_time.

## Billing e quotas

Quotas devem ser:
- Checadas antes de build caro.
- Revalidadas antes de promotion se necessario.
- Auditadas.

Billing:
- Nao cobrar release failed como ativa.
- Registrar uso por tenant e release.

## Volumes

Regras:
- Declarar explicitamente.
- Isolar por tenant/app.
- Backup quando persistente.
- Nao apagar em rollback sem aprovacao.

## TCP gateway

Checklist:
- Roteamento por tenant/app/release.
- TLS quando necessario.
- Limites de conexao.
- Logs com correlation id.
- Sem vazamento cross-tenant.

## Multi-node e HA

Cuidados:
- Lock distribuido para promotion.
- Estado autoritativo no control plane.
- Workers idempotentes.
- Runtime agents reportam heartbeat.
- Reconciler corrige divergencia.

## Seguranca por tenant

- Namespace/rede isolada quando possivel.
- Secrets por tenant/app.
- Logs separados por tenant.
- Quotas por tenant.
- AuthZ em toda operacao de app/release/log.

## Reconciler

Um reconciler deve:
- Comparar estado desejado vs real.
- Detectar active release ausente.
- Detectar container morto.
- Corrigir ou marcar failed.
- Nunca mascarar divergencia como sucesso.
