# CHANGELOG

Todas as mudanÃ§as notÃ¡veis no Animus.

Formato: [Keep a Changelog](https://keepachangelog.com/pt-BR/1.1.0/).
Versionamento: [SemVer](https://semver.org/lang/pt-BR/).

## [3.0.0] â€” 2026-05-18

Marco principal: repo plug-and-play, 57 skills auto-descobertas, scripts ops
(backup/rollback/upgrade/validate), SETUP-AGENTE.md modo A+B.

### Adicionado
- **7 skills externas** do OpenDirectory (Varnan-Tech):
  - `brand-alchemy` â€” naming com fonosemÃ¢ntica + domain checker
  - `reddit-icp-monitor` â€” monitora subreddits + scoreia leads
  - `cold-email-verifier` â€” valida deliverability via ValidEmail.co
  - `producthunt-launch-kit` â€” assets pra PH launch
  - `meeting-brief-generator` â€” pre-call brief via Tavily+Gemini
  - `hackernews-intel` â€” monitor HN com alerta Slack
  - `claude-md-generator` â€” gera CLAUDE.md de codebase
- **Auto-discovery de skills**: symlink `.claude/skills â†’ ../skills` (Claude Code carrega as 57 skills automaticamente).
- **4 scripts ops** em `scripts/`:
  - `backup.sh` â€” backup timestamped antes de mexer
  - `rollback.sh` â€” restaura backup
  - `upgrade.sh` â€” git pull + reaplica setup, idempotente
  - `validate.sh` â€” smoke test 8 checks (PM2, claude auth, .env, skills, agents, telegram, deps)
- **docs/TROUBLESHOOTING.md** â€” fixes pros 20+ erros mais comuns.
- **CHANGELOG.md** com versionamento.
- **Skill keys premium** no install.sh: MUAPI, GEMINI, VALIDEMAIL, TAVILY.

### Corrigido
- `visual-gen/scripts/generate.py`: `extract_output_url()` agora aceita campos
  `images` e `outputs` no payload da Muapi (era retornar erro mesmo com sucesso).
- `bootstrap.sh`: instala `pandas` (necessÃ¡rio pra `cold-email-verifier`).
- `bootstrap.sh`: roda `npm install` em `hackernews-intel/` automaticamente.

### Mudado
- `.env.example` reescrito com seÃ§Ã£o SKILLS PREMIUM + links pra cada provedor.
- `install.sh` agora pergunta skill keys premium (todas opcionais).
- `README.md` com tabela de skills premium + comparaÃ§Ã£o com setup antigo.
- `prompt-instalador.txt` versÃ£o premium plug-and-play.

### Notas de upgrade

Pra atualizar instalaÃ§Ã£o existente:

```bash
cd /workspace/Animus
git pull
bash scripts/upgrade.sh
```

Se o upgrade quebrar algo:

```bash
bash scripts/rollback.sh
```

---

## [2.0.0] â€” 2026-05-15

### Adicionado
- Skill `visual-gen` â€” imagem/vÃ­deo via Muapi.ai (Flux, Imagen, Kling, Veo).
- 4 skills externas: `design-system`, `self-improvement`, `ui-styling`, `ui-ux-pro-max`.
- Instalador 1-comando pra container Gradsky.

---

## [1.0.0] â€” 2026-05-10

### Adicionado
- Bot Telegram daemon Python (long polling).
- 9 subagentes especialistas (atlas, helena, aegis, titan, sentinel, victor, apollo, oracle, felipe).
- 47 skills marketing/dev iniciais.
- Roteamento por intenÃ§Ã£o no CLAUDE.md.
- Marker `[[SEND_FILE:/path]]` pra anexar arquivos no Telegram.
- Suporte opcional a memÃ³ria vetorial (Supabase + pgvector).
- Ãudio bidirecional opcional (Whisper + ElevenLabs).
