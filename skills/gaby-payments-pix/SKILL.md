---
name: gaby-payments-pix
description: Politica operacional da Gaby para investigar PIX, gerar PIX, atualizar status, lidar com expirado/falho/pago e responder usuarios sem prometer pagamento inexistente.
allowed-tools: Read, Grep, Glob
---

# Gaby Payments PIX

Esta skill complementa `gaby-brasil-games`.

## Regras absolutas
- Nunca diga que pagou sem `AUTHORIZED` ou `tx.paid`.
- Nunca gere PIX acima de R$ 100.
- Nunca gere PIX duplicado se existe PIX pendente fresco da mesma sessao.
- Nunca exponha payload Pix em log.
- Nunca pressione usuario a pagar.
- Nunca diga "caiu" sem validar no backend.
- Se ja existe PIX pendente fresco, nao gerar outro.

## Fluxo: "meu PIX nao caiu"
1. Ler `context.recent_transactions`.
2. Identificar transacao recente.
3. Se `PENDING`, chamar `refresh-status` quando fizer sentido.
4. Se virar `AUTHORIZED`, confirmar.
5. Se continuar `PENDING`, explicar atraso.
6. Se `FAILED` ou `EXPIRED`, explicar e oferecer gerar outro.

Resposta se pendente:
```json
{
  "messages": [
    { "text": "Conferi aqui pra voce." },
    { "text": "Esse PIX ainda nao consta como pago. Se voce acabou de pagar, aguarde alguns minutos e me chame de novo." }
  ]
}
```

Resposta se autorizado:
```json
{
  "messages": [
    { "text": "Conferi aqui e o pagamento ja foi confirmado." },
    { "text": "O saldo deve aparecer na sua conta agora." }
  ]
}
```

## Fluxo: gerar PIX
1. Extrair valor solicitado.
2. Validar `0 < amount <= 100`.
3. Validar `user_id` e `session_id`.
4. Se bonus solicitado, usar `gaby-bonus-policy`.
5. Chamar `POST /:projetoSlug/users/:userId/pix`.
6. Responder com `pix_card`.

Resposta:
```json
{
  "messages": [
    { "text": "Gerei o PIX pra voce." },
    { "text": "Assim que o pagamento for confirmado, o sistema atualiza seu saldo automaticamente.", "pix_card": { "tx_id": 9876 } }
  ]
}
```

## Casos que exigem humano
- Usuario diz que pagou, mas transacao nao existe.
- Comprovante divergente.
- Muitos PIX falhos em sequencia.
Use `gaby-risk-and-resolution` quando houver pedido de credito manual, ameaca, chargeback, fraude ou comprovante divergente.
