# Observability

## Principio

Sistema de producao precisa explicar o que aconteceu sem depender de adivinhacao. Observabilidade vem antes do debugging heroico.

## Logs estruturados

Campos minimos:
- timestamp
- level
- service
- environment
- release_id
- request_id
- correlation_id
- tenant_id quando seguro
- user_id quando seguro
- event
- duration_ms
- error_code

Nunca logar:
- token
- senha
- API key
- cookie
- refresh token
- documento sensivel
- payload completo com PII

## Correlation ID e request ID

Request ID:
- Identifica uma requisicao HTTP.

Correlation ID:
- Conecta HTTP, fila, worker, DB event e webhook.

Regra:
- Gerar na borda se nao existir.
- Propagar por eventos e jobs.
- Incluir em logs e erros.

## Traces

Use traces quando:
- Fluxo cruza varios servicos.
- Latencia e dificil de localizar.
- Fila/worker participa.

Span bom:
- Nome claro.
- Tags sem dados sensiveis.
- Status de erro.
- Duracao.

## Metrics

Tecnicas:
- request_count
- request_duration
- error_rate
- queue_lag
- job_duration
- db_query_duration
- deploy_duration
- healthcheck_failures

Negocio:
- signup_created
- invoice_paid
- deploy_promoted
- lead_qualified
- tenant_quota_exceeded

## Alertas

Alerta bom:
- Acionavel.
- Tem severidade.
- Tem runbook.
- Evita ruido.

Alertar em:
- Error rate acima do baseline.
- Latencia P95/P99 alta.
- Queue lag crescendo.
- DLQ recebendo mensagens.
- Deploy failed.
- Healthcheck de readiness falhando.
- Disco quase cheio.

## Dashboards

Dashboard operacional:
- Uptime.
- Latencia.
- Erros.
- CPU/memoria/disco.
- Filas.
- DB.
- Releases.

Dashboard produto:
- Conversao.
- Ativacao.
- Retencao.
- Eventos de negocio.

## Audit logs

Eventos que exigem auditoria:
- Login/logout.
- Troca de permissao.
- Alteracao de billing.
- Criacao/promocao/rollback de release.
- Alteracao de secrets.
- Acesso administrativo.

## Diagnostico por observabilidade

Fluxo:
1. Pegar request_id/correlation_id.
2. Ver release_id.
3. Ver erro e latencia.
4. Ver spans externos.
5. Ver DB/fila.
6. Comparar com deploy recente.
7. Confirmar causa antes de alterar.
