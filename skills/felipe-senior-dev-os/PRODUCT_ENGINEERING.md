# Product Engineering

## Principio

Engenharia senior nao entrega apenas codigo. Entrega resultado de produto com risco controlado, manutencao viavel e experiencia consistente para o usuario.

## Perguntas antes de construir

- Que problema do usuario isso resolve?
- Qual fluxo atual sera alterado?
- Qual metrica melhora?
- Qual risco operacional novo aparece?
- Qual parte precisa ser robusta agora?
- O que pode ser MVP sem virar divida perigosa?

## MVP vs robustez

MVP aceitavel:
- Escopo pequeno.
- Sem risco de dados sensiveis.
- Rollback simples.
- Observabilidade minima.

Robustez obrigatoria:
- Auth, billing, tenant, deploy, dados financeiros.
- Acoes irreversiveis.
- Filas com retry.
- Fluxos de producao 24/7.

## Custo de manutencao

Toda feature adiciona:
- Codigo.
- Testes.
- Monitoramento.
- Suporte.
- Migracoes futuras.
- Onboarding cognitivo.

Se o ganho nao compensa, simplifique.

## UX tecnica

Inclui:
- Mensagens de erro claras.
- Estados de loading.
- Retry seguro.
- Idempotencia em botoes de acao.
- Feedback de progresso em deploy/jobs.
- Logs acessiveis para diagnostico.

## Metricas

Produto:
- Ativacao.
- Retencao.
- Conversao.
- Tempo ate valor.

Tecnicas:
- Latencia.
- Erros.
- Tempo de deploy.
- Falhas por release.
- MTTR.

## Priorizacao

Use matriz:
- Impacto no usuario.
- Risco operacional.
- Esforco.
- Reversibilidade.
- Dependencias.

Priorize:
- Bugs que bloqueiam valor.
- Seguranca e dados.
- Observabilidade onde ha cegueira.
- Simplificacao que reduz custo recorrente.

## Simplificacao

Pergunte:
- Da para remover estado?
- Da para evitar fila?
- Da para adiar microservice?
- Da para resolver com modulo interno?
- Da para usar feature flag?

## Risco operacional

Risco alto se toca:
- Auth.
- Tenant.
- Billing.
- Deploy.
- Banco.
- Worker com efeito externo.
- Permissoes.

Para risco alto:
- Plano.
- Backup/diff.
- Validacao.
- Rollback.
- Comunicacao clara.
