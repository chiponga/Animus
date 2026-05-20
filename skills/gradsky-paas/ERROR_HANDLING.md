# Gradsky Error Handling

Erro padrao:

```json
{
  "ok": false,
  "error": {
    "code": "STRING_CODE",
    "message": "Human readable",
    "details": {}
  }
}
```

## Codigos

| Codigo | Conduta |
|---|---|
| `AUTH_INVALID_TOKEN` | Pare e peca novo token |
| `AUTH_TOKEN_EXPIRED` | Pare e peca renovacao |
| `AUTH_TOKEN_REVOKED` | Pare e peca novo token |
| `PAT_INSUFFICIENT_SCOPE` | Informe `requiredScope` |
| `PAT_NOT_ALLOWED_ON_ROUTE` | Pare, rota nao suportada |
| `PAT_OUT_OF_PROJECT_SCOPE` | Informe restricao de projeto |
| `PAT_OUT_OF_ORG_SCOPE` | Informe restricao de org |
| `PAT_RATE_LIMIT_EXCEEDED` | Espere `retryAfterSeconds` |
| `DOMAIN_VERIFICATION_PENDING` | DNS ainda nao propagou; retry com backoff |
| `VALIDATION_ERROR` | Corrija payload usando `details.issues` |
| `<algo>_NOT_FOUND` | Liste recursos antes de operar |

## Conduta

- Nao retentar token invalido, expirado ou revogado.
- Nao mascarar erro.
- Nao continuar se a rota foi bloqueada por PAT.
- Nao mostrar valor de secrets.
- Em dominio customizado, nao forcar deploy como pronto ate o verify passar.
- Em Cloudflare, avisar o usuario para deixar proxy cinza/DNS only ate o SSL responder; proxy laranja antes da verificacao pode quebrar o challenge.
