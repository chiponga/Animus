# Anti-Patterns

## Refatorar tudo sem necessidade

Sintoma:
- PR gigante.
- Objetivo original sumiu.
- Risco maior que beneficio.

Correcao:
- Fatiar.
- Proteger comportamento com teste.
- Refatorar somente caminho afetado.

## Mexer em muitas areas

Risco:
- Regressao invisivel.
- Review impossivel.

Regra:
- Uma intencao por mudanca.

## Abstracao antes da dor

Sintoma:
- Interfaces vazias.
- Factories sem necessidade.
- Genericidade para casos imaginarios.

Correcao:
- Duplicacao pequena primeiro.
- Abstrair depois da terceira dor real.

## Esconder erro

Anti-pattern:
```ts
try { ... } catch { return null }
```

Correcao:
- Log estruturado seguro.
- Erro com codigo.
- Propagar quando precisa falhar.

## Logar secret

Nunca logar:
- Authorization header.
- Cookie.
- Token.
- Password.
- API key.
- Payload sensivel.

## Deploy sem rollback

Risco:
- Incidente vira improviso.

Correcao:
- Release id.
- Versao anterior.
- Healthcheck.
- Smoke test.

## Fila sem idempotencia

Risco:
- Retry duplica cobranca, email, deploy ou side effect.

Correcao:
- Idempotency key.
- Constraint unica.
- Estado de processamento.

## Endpoint sem rate limit

Critico em:
- Login.
- Webhook.
- Upload.
- Busca cara.
- Criacao de recurso.

## Tenant sem isolamento

Anti-pattern:
```sql
SELECT * FROM projects WHERE id = ?
```

Correto:
```sql
SELECT * FROM projects WHERE id = ? AND tenant_id = ?
```

## Migration destrutiva

Evite:
- Drop coluna direto.
- Alter pesado sem janela.
- Backfill nao idempotente.

## Testes falsos

Sintoma:
- Testa mock do proprio mock.
- Nao falha quando comportamento quebra.

Correcao:
- Testar contrato, regra e efeito observavel.

## "Funciona na minha maquina"

Correcao:
- Reproduzir em ambiente limpo.
- Docker/CI.
- Documentar env vars.

## Overengineering

Sintoma:
- Microservices sem escala.
- Event sourcing sem auditoria exigida.
- Cache antes de medir.
- CQRS para CRUD simples.

## Microservices cedo demais

Consequencia:
- Rede, tracing, deploy, consistencia distribuida e ownership antes da maturidade.

Padrao melhor:
- Monolito modular com boundaries fortes.
