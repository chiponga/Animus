# Architecture

## Objetivo

Desenhar sistemas que entregam valor, resistem a mudanca e falham de forma diagnosticavel. Arquitetura boa reduz custo de manutencao sem antecipar complexidade inutil.

## Processo de desenho

1. Definir objetivo de negocio.
2. Listar usuarios, consumidores e integracoes.
3. Mapear dados criticos.
4. Identificar invariantes: auth, tenant, billing, quotas, auditoria.
5. Escolher fronteiras de modulo.
6. Definir contratos: HTTP, eventos, filas, DB.
7. Planejar observabilidade e rollback.
8. Criar caminho evolutivo.

## Monolito modular vs microservices

Prefira monolito modular quando:
- Dominio ainda muda muito.
- Equipe pequena.
- Deploy coordenado e aceitavel.
- Consistencia transacional importa.

Considere microservices quando:
- Boundaries estao estaveis.
- Escala, risco ou ownership justificam.
- Falha isolada tem valor real.
- Observabilidade, CI/CD e operacao ja estao maduros.

Regra:
- Microservice cedo demais cria rede, deploy e dados distribuidos antes da dor existir.

## Boundaries

Um modulo deve ter:
- Responsabilidade clara.
- API interna explicita.
- Dono de dados definido.
- Sem acesso direto ao banco de outro modulo.
- Eventos publicados quando outros modulos precisam reagir.

Exemplo:
```text
billing/
  routes.ts
  service.ts
  repository.ts
  events.ts
  schema.ts
```

## Camadas pragmaticas

- Route/controller: HTTP, auth, input, output.
- Service/use case: regra de negocio.
- Repository: persistencia.
- Domain/policies: invariantes complexas.
- Infra: filas, cache, providers externos.

Nao crie camada vazia. Crie quando ela protege regra real.

## Contratos

APIs:
- Versionar quando consumidores externos dependem.
- Validar input e output.
- Erros com codigo estavel.

Eventos:
- Nome no passado: `invoice.paid`, `deploy.failed`.
- Payload com versao.
- Idempotency key.
- Correlation id.

## Sincrono vs assincrono

Use sincrono quando:
- Usuario precisa resposta imediata.
- Operacao e curta e confiavel.
- Consistencia imediata importa.

Use assincrono quando:
- Tarefa e longa.
- Precisa retry.
- Integra fornecedor instavel.
- Pode processar eventual consistency.

## Event-driven architecture

Checklist:
- Evento tem dono.
- Consumer e idempotente.
- Retry tem backoff.
- DLQ existe.
- Observabilidade inclui lag, retries, failures.
- Contrato de evento e versionado.

## Outbox pattern

Use quando:
- Precisa salvar dado e publicar evento sem perder consistencia.

Padrao:
1. Transacao salva entidade e outbox row.
2. Worker publica evento.
3. Marca outbox como publicado.
4. Retry seguro por idempotencia.

## Anti-overengineering

Perguntas:
- O problema existe hoje?
- Qual custo de nao resolver agora?
- A abstracao reduz duplicacao real?
- A solucao simples tem rollback?
- A equipe vai entender isso em 6 meses?

## Evoluir sem quebrar

- Expand/contract em schema e APIs.
- Feature flags para mudancas de comportamento.
- Compatibilidade temporaria.
- Backfill idempotente.
- Observabilidade antes de remover legado.
