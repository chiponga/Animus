# Code Review

## Objetivo

Revisar como engenheiro principal: procurar bugs, regressao, risco operacional, falha de seguranca, acoplamento desnecessario e ausencia de validacao. Estilo importa, mas comportamento importa mais.

## Ordem da revisao

1. Entender objetivo da mudanca.
2. Ler diff inteiro.
3. Identificar areas criticas: auth, billing, dados, deploy, filas.
4. Revisar fluxo feliz.
5. Revisar edge cases.
6. Revisar testes e observabilidade.
7. Revisar rollback.

## Checklist

Legibilidade:
- [ ] Nome comunica intencao.
- [ ] Funcoes pequenas o suficiente.
- [ ] Comentarios explicam "por que", nao "o que" obvio.

Duplicacao:
- [ ] Duplicacao pequena pode ser aceitavel.
- [ ] Abstracao so existe se reduz dor real.

Acoplamento:
- [ ] Handler nao conhece detalhe de banco demais.
- [ ] Service nao depende de framework HTTP.
- [ ] Modulo nao acessa dados de outro modulo sem contrato.

Complexidade:
- [ ] Branches e estados sao compreensiveis.
- [ ] Erros sao tratados perto da origem.

Arquitetura:
- [ ] Boundaries preservadas.
- [ ] Contratos de API/eventos estaveis.
- [ ] Mudanca e evolutiva.

Performance:
- [ ] Evita N+1.
- [ ] Indices cobrem filtros.
- [ ] Cache tem invalidacao.
- [ ] Query pesada tem limite/paginacao.

Seguranca:
- [ ] Auth e tenant checados.
- [ ] Input validado.
- [ ] Secrets nao logados.
- [ ] Rate limit quando necessario.

Testes:
- [ ] Cobre caminho feliz.
- [ ] Cobre erro relevante.
- [ ] Cobre regressao do bug.

Logs:
- [ ] Inclui request id/correlation id.
- [ ] Nao inclui dados sensiveis.
- [ ] Ajuda a diagnosticar causa.

Rollback:
- [ ] Mudanca pode ser revertida.
- [ ] Migration nao destrutiva ou tem plano claro.

Compatibilidade:
- [ ] Consumidores existentes nao quebram.
- [ ] Feature flag quando risco alto.

DX:
- [ ] Setup local continua claro.
- [ ] Erros ajudam desenvolvedor.

## Severidade de comentarios

- P0: quebra producao, security critical, perda de dados.
- P1: bug serio, regressao provavel, auth/tenant fraco.
- P2: manutencao, edge case relevante, observabilidade ausente.
- P3: estilo, clareza, melhoria futura.

## Template de review

```md
Findings:
- [P1] arquivo:linha - risco e evidencia.

Validacoes:
- comando rodado e resultado.

Risco residual:
- o que nao foi possivel provar.
```
