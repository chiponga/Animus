# Database

## Principio

Banco e contrato de producao. Mudanca de schema, query ou consistencia pode quebrar usuarios, billing, auditoria e deploy. Trate banco como parte critica da arquitetura.

## Modelagem MySQL

Checklist:
- [ ] Tabela tem owner claro.
- [ ] Chave primaria estavel.
- [ ] `tenant_id` quando multi-tenant.
- [ ] `created_at`, `updated_at` quando auditoria operacional importa.
- [ ] Constraints para invariantes reais.
- [ ] Indices para filtros reais, nao imaginarios.

Padrao multi-tenant:
```sql
CREATE INDEX idx_orders_tenant_status_created
ON orders (tenant_id, status, created_at);
```

## Drizzle migrations

Regras:
- Migration deve ser revisada como codigo.
- Nao editar migration ja aplicada.
- Nome claro por intencao.
- Separar mudanca destrutiva em etapa posterior.
- Backfill deve ser idempotente.

## Indices

Adicionar indice quando:
- Query frequente filtra/ordena por campo.
- EXPLAIN mostra full scan indevido.
- Endpoint impacta latencia ou custo.

Nao adicionar quando:
- Campo tem baixa seletividade e nao ajuda.
- Escrita e muito intensa e indice nao sera usado.
- Nao existe query real.

## Transacoes

Use transacao quando:
- Duas ou mais escritas precisam ser atomicas.
- Estado financeiro/billing muda.
- Outbox pattern precisa persistir dado + evento.

Regra:
- Transacao curta.
- Sem chamada HTTP externa dentro da transacao.
- Locks na menor janela possivel.

## Locks

Optimistic locking:
- Use com `version` ou `updated_at`.
- Bom para concorrencia baixa/media.

Pessimistic locking:
- Use quando nao pode perder disputa.
- Bom para saldo, quotas, estoque, release promotion.
- Exige timeout e cuidado com deadlock.

## N+1

Sinais:
- Loop chama repository para cada item.
- Latencia cresce linearmente com quantidade.

Correcoes:
- Batch query.
- Join controlado.
- DataLoader pattern.
- Preload com limite.

## Paginacao

Preferir cursor quando:
- Lista grande.
- Ordenacao estavel.
- Trafego alto.

Offset serve quando:
- Lista pequena.
- Simplicidade importa mais.

## Consistencia

Forte:
- Auth, billing, quota, deploy active release.

Eventual:
- Analytics, notificacoes, counters nao criticos.

## Backup e restore

Checklist:
- [ ] Backup automatico.
- [ ] Restore testado.
- [ ] Retencao definida.
- [ ] Criptografia quando sensivel.
- [ ] Tempo de recuperacao conhecido.

## Auditoria

Audit log deve registrar:
- Quem fez.
- O que mudou.
- Quando.
- De onde.
- Antes/depois quando seguro.
- Correlation id.

Nao registrar secrets ou payload sensivel integral.

## Soft delete

Use quando:
- Compliance, auditoria ou recuperacao importa.

Cuidado:
- Queries precisam filtrar deletados.
- Unique constraints podem precisar incluir `deleted_at`.

## Sharding

Somente quando:
- O banco unico virou gargalo real.
- Indices, queries, cache e replicas ja foram explorados.
- Operacao consegue lidar com complexidade.

Nao usar sharding por ansiedade de escala.
