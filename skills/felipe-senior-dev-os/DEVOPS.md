# DevOps

## Principio

Operacao boa e previsivel, auditavel e reversivel. VPS simples pode ser excelente se tiver usuarios corretos, firewall, logs, backup, SSL e deploy disciplinado.

## VPS Ubuntu

Checklist inicial:
- [ ] Usuario nao-root para app.
- [ ] SSH por chave.
- [ ] Firewall ativo.
- [ ] Timezone definido.
- [ ] Updates de seguranca.
- [ ] Disco monitorado.
- [ ] Backups configurados.

## systemd

Unit file minimo:
```ini
[Service]
User=app
WorkingDirectory=/opt/app
EnvironmentFile=/opt/app/.env
ExecStart=/usr/bin/bun run start
Restart=on-failure
RestartSec=5
```

Checklist:
- [ ] Usuario correto.
- [ ] Env file com permissao restrita.
- [ ] Restart policy.
- [ ] Logs no journal.
- [ ] Graceful shutdown.

## Docker

Boas praticas:
- Multi-stage build.
- Imagem pequena.
- Usuario nao-root.
- Healthcheck.
- Sem secrets na imagem.
- Pin de versoes criticas.

## Firewall

Padrao:
- Abrir apenas 22, 80, 443 e portas internas necessarias.
- DB e fila nao expostos publicamente.
- Admin ports em VPN ou allowlist.

## Nginx/Caddy

Checklist:
- [ ] TLS ativo.
- [ ] Redirect HTTP para HTTPS.
- [ ] Headers basicos.
- [ ] Timeout adequado.
- [ ] Proxy passa request id.
- [ ] Limite de body em upload.

## Logs

- App em stdout/stderr ou arquivo rotacionado.
- Journal com retencao.
- Nao logar secrets.
- Centralizar quando multi-node.

## Backups

Regra 3-2-1 quando possivel:
- 3 copias.
- 2 midias.
- 1 fora do servidor.

Obrigatorio:
- Restore testado.
- Retencao documentada.

## Secrets

- `.env` com `chmod 600`.
- Secret manager quando disponivel.
- Rotacao planejada.
- Nunca em Git, imagem Docker ou log.

## Monitoramento

Minimo:
- Uptime.
- CPU/memoria/disco.
- Error rate.
- Latencia.
- Queue lag.
- DB connections.
- Certificado SSL expirando.

## Permissoes

- Least privilege.
- App nao roda como root.
- Banco com usuario por app.
- Arquivos de deploy pertencem ao usuario do servico.

## Rotacao de secrets

Passos:
1. Criar novo secret.
2. Deploy com suporte ao novo.
3. Revogar antigo.
4. Verificar logs e erros.
5. Registrar auditoria.
