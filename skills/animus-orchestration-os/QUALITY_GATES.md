# Quality Gates

Quality Gate e uma barreira objetiva antes de declarar sucesso.

## Gates por tipo

| Tipo de entrega | Gate obrigatorio |
|---|---|
| Codigo | Atlas + Sentinel |
| Seguranca | Aegis |
| Deploy | Titan + Sentinel |
| UI/UX | Helena + Sentinel |
| Copy/oferta | Victor + Oracle quando houver estrategia |
| Growth/vendas | Apollo + Oracle |
| Analytics/BI | Oracle |
| Projeto completo | Sentinel consolida evidencias |

## Template de gate

```text
Gate:
Escopo validado:
Evidencias:
Falhas encontradas:
Risco residual:
Status: aprovado | ajustes | bloqueado
```

## Criterios universais

- O output cumpre o objetivo?
- Existe evidencia?
- Ha regressao provavel?
- Ha risco de seguranca?
- Ha risco operacional?
- O usuario consegue usar?
- O proximo passo esta claro?

## Quando barrar

Barre se:
- build/teste/smoke falhou.
- segredo foi exposto.
- comportamento nao foi validado.
- copy promete algo que o produto nao entrega.
- design nao cobre estado vazio/erro/loading.
- deploy nao tem rollback.
- decisao depende de dado ausente.
