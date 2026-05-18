# Debugging

## Principio

Nao corrija sintomas antes de entender causa raiz. Debugging senior e coleta de evidencia, reducao de incerteza e validacao de hipotese.

## Metodo

1. Reproduzir ou definir condicao de ocorrencia.
2. Isolar escopo: frontend, API, worker, banco, fila, infra.
3. Coletar evidencia: logs, request id, payload, status, metricas.
4. Criar hipotese.
5. Validar hipotese com menor experimento.
6. Corrigir causa raiz.
7. Testar regressao.
8. Documentar aprendizado.

## Perguntas iniciais

- Quando comecou?
- Acontece sempre ou intermitente?
- Qual deploy ou mudanca ocorreu antes?
- Afeta todos os tenants ou um tenant?
- Existe request id, job id, release id ou correlation id?
- Existe mensagem de erro real?

## Producao

Regras:
- Nao rodar comando destrutivo.
- Nao imprimir secrets.
- Nao editar direto em producao sem backup/diff.
- Preferir observacao antes de acao.

Checklist:
- [ ] Status de servicos.
- [ ] Logs recentes.
- [ ] Healthcheck real.
- [ ] Uso de CPU, memoria, disco.
- [ ] Erros por release.
- [ ] Conexoes DB/fila.

## Deploy

Investigue:
- Build gerou artefato correto?
- Env vars existem?
- Migration rodou?
- Container iniciou?
- Healthcheck responde?
- Proxy aponta para release correta?
- Logs mostram crash loop?

## Banco

Investigue:
- Query lenta.
- Lock wait.
- Deadlock.
- Indice ausente.
- Migration incompleta.
- Dados inconsistentes.
- Tenant filter ausente.

Comandos conceituais:
```sql
EXPLAIN SELECT ...;
SHOW PROCESSLIST;
SHOW ENGINE INNODB STATUS;
```

## Filas

Investigue:
- Mensagens acumuladas.
- Consumer parado.
- Retry infinito.
- DLQ crescendo.
- Mensagem nao idempotente.
- Ack antes de concluir.
- Backpressure ausente.

## Memory leak

Sinais:
- RSS cresce sem cair.
- OOM kill.
- Latencia aumenta com uptime.

Investigue:
- Cache sem limite.
- Listeners acumulados.
- Promises penduradas.
- Streams nao fechados.
- Objetos globais por request.

## Race condition

Sinais:
- Bug intermitente.
- Concorrencia por tenant/recurso.
- Estado final impossivel.

Mitigacoes:
- Transacao.
- Lock otimista.
- Lock pessimista quando necessario.
- Idempotency key.
- Constraint unica.

## Problemas intermitentes

Trate como problema de observabilidade:
- Aumentar logs estruturados temporarios.
- Capturar correlation id.
- Registrar versao/release.
- Medir frequencia.
- Comparar tenants, horarios, workers e nodes.

## Relatorio de debugging

```md
Causa raiz:
Evidencia:
Correcao:
Validacao:
Risco residual:
Prevencao:
```
