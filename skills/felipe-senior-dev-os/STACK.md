# Stack Preferida

## Principio

A stack boa e a que reduz risco operacional, acelera entrega e continua compreensivel em producao. Preferir performance e simplicidade, mas sem sacrificar observabilidade, seguranca e rollback.

## Bun

Use quando:
- Projeto TypeScript novo ou servico com foco em performance e DX.
- Scripts internos, CLIs, workers leves e APIs Elysia.
- O ecossistema de dependencias usado for compativel.

Nao use quando:
- Dependencia critica falha fora do Node.
- Hosting alvo nao suporta Bun de forma confiavel.
- A equipe precisa de compatibilidade Node LTS acima de performance.

Tradeoffs:
- Excelente velocidade e simplicidade.
- Menor maturidade que Node em alguns pacotes.
- Exige smoke tests reais no runtime de producao.

Padrao:
```ts
// Preferir env validada no boot, nao process.env solto no handler.
const env = parseEnv(process.env)
```

## Elysia

Use quando:
- API HTTP performatica com TypeScript forte.
- Contratos, middlewares e composicao clara.
- Servicos pequenos ou modulos de monolito modular.

Nao use quando:
- O projeto ja esta consolidado em outro framework e migrar nao gera valor.
- O time precisa de ecossistema Express/Nest por dependencia de negocio.

Padroes:
- Separar `routes`, `services`, `repositories`, `schemas`.
- Middlewares para auth, tenant, request id, rate limit e error boundary.
- Nunca acessar banco direto no handler quando a regra de negocio crescer.

## TypeScript strict

Regras:
- `strict: true`.
- Evitar `any`; se inevitavel, isolar e justificar.
- Validar input em runtime com schema.
- Tipos nao substituem auth, validacao ou checks de tenant.

## Drizzle ORM

Use quando:
- Precisa de SQL explicito, type safety e migrations controladas.
- MySQL/Postgres com queries previsiveis.

Nao use quando:
- A query precisa de SQL cru muito especifico e Drizzle piora clareza.

Padroes:
- Schema versionado.
- Migrations revisadas antes de aplicar.
- Repositorios pequenos, sem esconder query critica demais.

## MySQL

Use quando:
- Produto transacional, multi-tenant, CRUD, billing e operacao comum.
- Equipe domina MySQL e infra ja esta pronta.

Nao use quando:
- Precisa de features nativas mais fortes de Postgres, como JSONB complexo, extensoes ou full text especifico.

Padroes:
- `utf8mb4`.
- IDs estaveis.
- Indices por tenant e filtros reais.
- Migrations expand/contract.

## Redis

Use para:
- Cache com TTL.
- Rate limit.
- Locks curtos e coordenacao leve.
- Sessao quando arquitetura exigir.

Nao use para:
- Fonte primaria de verdade.
- Fila duravel critica sem aceitar perda.

## RabbitMQ

Use para:
- Filas duraveis.
- Workers com retry, DLQ e backpressure.
- Processos que precisam sobreviver a restart.

Nao use quando:
- A tarefa e simples e sincrona.
- Pub/sub efemero basta.

## Docker

Use para:
- Empacotar runtime imutavel.
- Reproduzir ambiente.
- Deploy consistente em VPS/PaaS.

Padroes:
- Imagem pequena.
- Usuario nao-root.
- Healthcheck real.
- Secrets via env/secret manager, nunca baked na imagem.

## systemd

Use para:
- Servicos persistentes em VPS Ubuntu.
- Restart policy, logs via journal e dependencia de rede.

Padroes:
- `Restart=always` ou `on-failure` conforme risco.
- `WorkingDirectory`, `EnvironmentFile`, usuario nao-root.
- `ExecStartPre` apenas para checks seguros.

## Nginx/Caddy

Caddy:
- Melhor para SSL automatico e setup simples.

Nginx:
- Melhor quando precisa de controle fino, legado ou padroes corporativos.

## GitHub Actions

Use para:
- Lint, typecheck, test, build, security scan e deploy controlado.

Padroes:
- Separar CI de CD.
- Proteger secrets.
- Ambientes com approvals quando producao.

## VPS Ubuntu

Use quando:
- Custo previsivel, controle operacional e servicos long-running.

Nao use quando:
- Time nao consegue operar backups, updates, firewall e monitoramento.

## Gradsky/PaaS interno

Use quando:
- Precisa padronizar deploy, runtime, logs, metrics, releases e rollback para multiplos tenants/projetos.

Regra:
- Gradsky nao e "docker run". E pipeline transacional com estado verdadeiro.
