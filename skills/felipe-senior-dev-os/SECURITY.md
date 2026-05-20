# Security

## Postura

Seguranca nao e etapa final. Toda mudanca tecnica deve perguntar: quem pode acessar, que dado cruza limite, como auditar, como limitar abuso e como recuperar.

## Checklist de pentest rapido

- [ ] Auth obrigatoria nas rotas privadas.
- [ ] Autorizacao checa recurso e tenant.
- [ ] Rate limit em login, webhook, API publica e endpoints caros.
- [ ] Inputs validados em runtime.
- [ ] Queries parametrizadas.
- [ ] Upload com tamanho, MIME, extensao e storage isolado.
- [ ] Webhooks com assinatura e timestamp.
- [ ] Logs sem secrets, tokens, cookies ou PII desnecessaria.
- [ ] Secrets fora do repo e fora de imagem Docker.
- [ ] Permissoes Linux e DB em least privilege.

## OWASP Top 10 aplicado

- Broken Access Control: testar acesso cruzado por tenant e ownership.
- Cryptographic Failures: TLS, hashing forte, secrets protegidos.
- Injection: SQL parametrizado, shell sem interpolacao perigosa.
- Insecure Design: threat modeling antes da feature sensivel.
- Security Misconfiguration: headers, CORS, debug off, permissao minima.
- Vulnerable Components: lockfile, scan, update planejado.
- Auth Failures: MFA quando aplicavel, brute force limit, session hygiene.
- Integrity Failures: CI/CD protegido, assinatura/verificacao de payload.
- Logging Failures: audit logs de eventos criticos.
- SSRF: bloquear metadata IPs e validar URL de destino.

## Auth

JWT:
- Curto prazo.
- Assinatura forte.
- Validar issuer, audience, exp.
- Nao guardar dado sensivel no payload.

Session:
- Cookie `HttpOnly`, `Secure`, `SameSite`.
- Rotacao apos login.
- Revogacao possivel.

Refresh token:
- Armazenar hash.
- Rotacionar.
- Detectar reuse.

## Autorizacao

RBAC:
- Bom para papeis claros: admin, owner, member.

ABAC:
- Bom para regra contextual: tenant, plano, ownership, status.

Regra:
- AuthN responde "quem e".
- AuthZ responde "pode fazer isso neste recurso agora".

## Tenant isolation

- Toda query de recurso multi-tenant deve filtrar `tenant_id`.
- Indices compostos por `tenant_id`.
- Nunca confiar em tenant vindo apenas do body.
- Resolver tenant por auth/session/contexto confiavel.
- Testar acesso cruzado.

## Vulnerabilidades comuns

XSS:
- Escapar output.
- Sanitizar HTML.
- CSP quando possivel.

CSRF:
- SameSite ou token CSRF em cookie auth.

SSRF:
- Allowlist de dominios.
- Bloquear IP privado e metadata.

RCE:
- Evitar shell com input.
- Sandbox quando executar codigo.

Path traversal:
- Normalizar path.
- Restringir base dir.

File upload:
- Validar tipo real.
- Storage fora do webroot.
- Scan quando risco alto.

## Webhook security

- HMAC com secret.
- Timestamp contra replay.
- Idempotency key.
- Rate limit.
- Logar evento sem payload sensivel.

## Container hardening

- Usuario nao-root.
- SSH key, senha desabilitada quando possivel.
- Firewall allowlist.
- Atualizacoes de seguranca.
- Fail2ban quando aplicavel.
- Backups testados.

## Docker security

- Imagem pequena.
- Usuario nao-root.
- Sem secrets no build args.
- Read-only filesystem quando possivel.
- Capabilities minimas.

## Incident response basico

1. Conter: revogar token, bloquear endpoint, pausar job.
2. Preservar evidencia: logs, timestamps, request id.
3. Erradicar causa raiz.
4. Recuperar com rollback/patch.
5. Comunicar impacto real.
6. Criar acao preventiva.
