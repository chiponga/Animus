# QA

## Principio

Qualidade nao e "rodou na minha maquina". Qualidade e evidencia de que a mudanca atende criterio de aceite sem quebrar fluxo existente.

## Piramide pragmatica

Unitarios:
- Regras puras.
- Edge cases.
- Funcoes de transformacao.

Integracao:
- Banco, repositorios, filas, providers fake.
- Contratos reais entre camadas.

E2E:
- Fluxos criticos do usuario.
- Poucos, estaveis e valiosos.

Smoke:
- Verifica se release esta utilizavel.
- Login, rota critica, health, job basico.

## Testes de API

Checklist:
- [ ] Auth ausente.
- [ ] Auth invalida.
- [ ] Usuario sem permissao.
- [ ] Tenant errado.
- [ ] Input invalido.
- [ ] Caminho feliz.
- [ ] Erro de dependencia.

## Contrato de API

Validar:
- Status code.
- Shape de resposta.
- Codigo de erro.
- Campos obrigatorios.
- Compatibilidade com cliente existente.

## Testes de seguranca

Minimos:
- Acesso cruzado por tenant.
- IDOR.
- Rate limit.
- Injection basica.
- Upload invalido.
- Webhook signature invalida.

## Testes de carga

Use quando:
- Endpoint novo e critico.
- Worker processa volume.
- Deploy engine manipula multiplas releases.

Medir:
- Throughput.
- P95/P99.
- Erros.
- CPU/memoria.
- DB connections.
- Queue lag.

## Criterios de aceite

Bom criterio:
- Observavel.
- Testavel.
- Especifico.

Ruim:
- "Melhorar performance".

Bom:
- "Reduzir P95 de listagem de deployments abaixo de 300ms com 10k registros por tenant".

## Definition of Done

- [ ] Codigo implementado.
- [ ] Testes/validacao rodados.
- [ ] Sem secrets em log.
- [ ] Observabilidade suficiente.
- [ ] Rollback conhecido.
- [ ] Docs ou comentarios atualizados quando necessario.
- [ ] Riscos comunicados.
- [ ] Usuario recebeu como testar.

## Quando reprovar

Reprove se:
- Build falha.
- Teste critico falha.
- Auth/tenant esta incerto.
- Migration pode destruir dados.
- Deploy nao tem rollback.
- Erro foi mascarado.
- Validacao nao foi feita.
