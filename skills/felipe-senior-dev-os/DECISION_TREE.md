# Decision Tree

## Escolher stack

```text
Projeto novo?
  sim -> equipe domina TypeScript?
    sim -> Bun + Elysia se runtime alvo suportar
    nao -> stack que equipe opera melhor
  nao -> manter stack atual salvo dor real
```

## Escolher banco

```text
Dados relacionais e transacionais?
  sim -> MySQL ou Postgres
    precisa extensoes/JSONB forte? -> Postgres
    equipe/infra ja e MySQL? -> MySQL
  nao -> avaliar KV/documento/fila conforme caso
```

## MySQL vs Postgres

Use MySQL quando:
- Produto CRUD/transacional.
- Infra existente e conhecimento forte.
- Simplicidade operacional importa.

Use Postgres quando:
- Precisa extensoes, JSONB forte, full text, constraints avancadas.

## Escolher fila

```text
Precisa durabilidade, ack, DLQ, retry e backpressure?
  sim -> RabbitMQ
  nao -> Redis pode bastar para jobs leves/cache/pubsub
```

## RabbitMQ vs Redis

RabbitMQ:
- Durabilidade.
- Routing.
- DLQ.
- Ack.
- Backpressure.

Redis:
- Cache.
- Rate limit.
- Locks curtos.
- Jobs simples se perda for aceitavel ou mitigada.

## Escolher cache

```text
Dado caro de calcular e tolera staleness?
  sim -> Redis com TTL e invalidacao
  nao -> nao usar cache
```

Regra:
- Cache sem invalidacao e bug adiado.

## Escolher arquitetura

```text
Dominio instavel ou equipe pequena?
  sim -> monolito modular
  nao -> boundaries estaveis e escala independente?
    sim -> considerar microservice
    nao -> monolito modular
```

## Decidir refatoracao

Refatore se:
- A mudanca atual fica mais segura.
- Ha bug recorrente por complexidade.
- Teste fica possivel.
- Custo da refatoracao e menor que custo de manter.

Nao refatore se:
- E preferencia estetica.
- Toca muitas areas sem teste.
- Prazo pede hotfix seguro.

## Decidir hotfix

Hotfix se:
- Producao quebrada.
- Security incident.
- Perda de dados ou receita.

Mesmo hotfix precisa:
- Causa provavel.
- Mudanca minima.
- Validacao.
- Plano de follow-up.

## Decidir rollback

Rollback se:
- Release atual aumenta erro.
- Dado nao foi corrompido de forma irreversivel.
- Versao anterior e compativel com schema.

Nao rollback direto se:
- Migration destrutiva ja rodou.
- Estado externo foi alterado.
- Precisa forward fix mais seguro.

## Decidir microservice

Microservice apenas se:
- Boundary clara.
- Time opera deploy independente.
- Observabilidade existe.
- Falha isolada justifica.
- Dados podem ser separados.

## Bun vs Node

Bun:
- Performance, DX, APIs novas, scripts.

Node:
- Compatibilidade maxima, ecossistema maduro, ambientes restritivos.

## Serverless vs VPS

Serverless:
- Trafego variavel.
- Operacao reduzida.
- Jobs curtos.

VPS:
- Long-running.
- Docker/systemd.
- Custo previsivel.
- Controle de rede/runtime.

## Sincrono vs assincrono

Sincrono:
- Precisa resposta imediata.
- Operacao curta.

Assincrono:
- Tarefa longa.
- Retry.
- Provider instavel.
- Eventual consistency aceitavel.
