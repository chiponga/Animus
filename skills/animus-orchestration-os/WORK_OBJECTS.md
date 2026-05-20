# Work Objects

Work Object e qualquer trabalho rastreavel que nasce, muda de estado e termina com decisao ou entrega.

## Tipos

| Tipo | Quando usar |
|---|---|
| Project | iniciativa com multiplas entregas |
| Task | trabalho pequeno com dono claro |
| Briefing | contexto estruturado antes de executar |
| Decision | escolha registrada com tradeoffs |
| Deliverable | artefato entregue |
| Quality Gate | verificacao que aprova ou barra |
| Incident | falha, bug ou risco em producao |
| Experiment | teste com metrica e hipotese |

## Template base

```text
Work Object: <nome>
Tipo: <Project|Task|Briefing|Decision|Deliverable|Quality Gate|Incident|Experiment>
Objetivo:
Escopo:
Fora de escopo:
Dono:
Agentes:
Insumos:
Restricoes:
Criterios de aceite:
Gates:
Status:
Riscos:
Proximo passo:
```

## Status permitidos

- `draft`: ainda formando.
- `ready`: pronto para execucao.
- `running`: em execucao.
- `waiting_user`: aguardando Chefe.
- `blocked`: impedido.
- `review`: aguardando gate.
- `approved`: aprovado.
- `delivered`: entregue.
- `archived`: encerrado.

## Regras

- Todo trabalho complexo precisa de dono.
- Todo trabalho entregue precisa de criterio de aceite.
- Todo gate precisa de evidencia.
- Todo bloqueio precisa de motivo e proxima decisao.
