---
name: analisar-instagram-bmad
description: Faz analise BMAD profunda de qualquer perfil de Instagram, gera dossie cinematografico com 4 abas (Visao Geral, Conteudo, Estrategia 30 Dias, Dados Brutos) e faz deploy automatico em USERNAME.DOMINIO_BASE (subdominio do dominio do aluno, configurado no .env do agente). Ative essa skill quando o usuario disser coisas como "analisa esse perfil do instagram", "analisa @username", "faz dossie de @username", "analise BMAD do @perfil", "analisa o instagram dessa pessoa", "monta dossie completo do instagram", "quero entender o perfil @x", "analise estrategica do instagram @y", "gera plano de 30 dias pro @z", "auditoria instagram @w", "diagnostico instagram", "raio-x do instagram @username".
license: Comercial - Avalanche
---

# Skill: Analisar Instagram com BMAD

## O que essa skill faz

Voce e um agente que recebe um @username do Instagram e em ate 5 minutos entrega um dossie cinematografico completo, deployado em uma URL publica Gradsky ou, quando habilitado, em USERNAME.DOMINIO_BASE, com:

1. Analise BMAD (Business Model, Audience, Differentiation) profunda
2. Diagnostico de pilares de conteudo e padroes virais
3. Plano estrategico de 30 dias com meta de +10% seguidores
4. Site HTML cinematografico com 4 abas para o cliente navegar
5. Deploy via Gradsky PAT em service publico, com dominio customizado opcional do aluno

## Quando ativar

Sempre que o usuario pedir qualquer coisa relacionada a entender, analisar, auditar ou planejar crescimento de um perfil do Instagram. Triggers comuns:

- "analisa esse perfil do instagram @username"
- "faz dossie de @username"
- "analise BMAD do @username"
- "monta dossie completo do @username"
- "auditoria do instagram @username"
- "diagnostico do instagram @username"
- "plano de 30 dias pro @username"
- "quero entender o perfil @username"
- "raio-x do instagram do @username"

## Fluxo de execucao (8 etapas)

### Etapa 1: Receber input
Extrair @username da mensagem do usuario. Limpar @ e espacos. Validar formato.

### Etapa 2: Coletar dados do perfil
Coletar manualmente (ou via scraper de sua escolha) os dados base:
- bio, follower_count, full_name, is_verified, external_url, category
- 12 posts mais recentes com captions, likes, comments, taken_at
- 3 reels mais recentes (opcional)

A skill em si nao especifica qual scraper usar. Voce escolhe (ex: Apify Instagram Scraper, instaloader em Python, ou qualquer biblioteca publica).

### Etapa 3: Analise Gemini (3 chamadas em sequencia)
1. Visao Macro: nicho, ICP, posicionamento, top 3 forcas, top 3 fraquezas
2. Conteudo: pilares, formato dominante, frequencia, padroes virais, gaps
3. Estrategia 30 dias: plano dia a dia, metas, oportunidades nao exploradas

Prompts completos em `prompts/01-visao-macro.md`, `prompts/02-conteudo.md`, `prompts/03-estrategia-30-dias.md`.

### Etapa 4: Montar dossie HTML
Usar `template-dossie.html` e substituir placeholders:
- `{{USERNAME}}`, `{{AVATAR_URL}}`, `{{BIO}}`, `{{FOLLOWERS}}`, `{{FULL_NAME}}`, `{{VERIFIED}}`
- `{{ANALISE_VISAO_GERAL}}`, `{{ANALISE_CONTEUDO}}`, `{{PLANO_30_DIAS}}`, `{{POSTS_DATA}}`
- `{{GERADO_EM}}` (timestamp BRT)

### Etapa 5: Deploy
1. Le `GRADSKY_TOKEN` do `.env` do agente. Se nao existir, aborta e instrui o aluno a gerar um PAT Gradsky com scopes `read` e `deploy`.
2. Usa `GRADSKY_PROJECT_ID` quando definido. Se nao existir, lista `GET /projects`; se houver mais de um projeto acessivel, aborta e pede `GRADSKY_PROJECT_ID`.
3. Define dominio publico Gradsky com `POST /services/{serviceId}/public-domain` quando `GRADSKY_PUBLIC_DOMAIN=true`.
4. Define `FQDN="${USERNAME_INSTAGRAM}.${DOMINIO_BASE}"` somente se `GRADSKY_ATTACH_DOMAIN=true`.
4. `git init` na pasta de output.
5. Cria/push repo privado com `GH_TOKEN` e `GH_USER`.
6. Lista services com `GET /services?projectId=...` e procura `dossie-USERNAME` por `name` ou `slug`.
7. Se nao existir, usa `POST /projects/{projectId}/import-docker-app` com `nginx:alpine`.
8. Se existir e estiver conectado ao GitHub, apenas faz commit/push; a Gradsky dispara redeploy automatico. Usar env/restart somente com `GRADSKY_GIT_AUTO_DEPLOY=false`.
9. Se `GRADSKY_ATTACH_DOMAIN=true`, solicita dominio customizado em `POST /services/{serviceId}/domains` com `{ "hostname": "<host>" }`.
10. Se houver TXT de ownership, orientar o DNS. Em Cloudflare, proxy cinza/DNS only ate o SSL responder.

### Etapa 6: Entregar URL
Retornar `https://$FQDN` ao usuario (ex: `https://joaodasilva.meunegocio.com.br`), com resumo executivo de 5 bullets.

### Etapa 7: Meta de seguidores
Por padrao, plano de 30 dias mira em `+10%` no follower_count atual.
Excecao: se o usuario pedir explicitamente "foco em vendas" ou "foco em faturamento", mudar o foco do plano para receita imediata (escada de produtos, funis, trafego direto).

### Etapa 8: Tom do dossie
Educativo + estrategico + acionavel. Nunca academico. Nunca generico. Sempre com numeros, datas e CTAs concretos.

## Como usar

A skill entrega prompts e template prontos. Voce, agente que executa, monta o pipeline com as ferramentas que tiver disponivel:

1. Coletor de dados de Instagram (de sua escolha)
2. Cliente Gemini API para rodar os 3 prompts em sequencia
3. Renderizador HTML que aplica os outputs JSON ao template
4. Deploy via GitHub + Gradsky PAT

### Variaveis de ambiente necessarias

O aluno cadastra no `.env` do Animus (NAO no codigo da skill). A skill apenas le essas variaveis em runtime:

```
# IA
GEMINI_API_KEY=...

# Deploy Gradsky
GRADSKY_TOKEN=...                     # PAT Gradsky com read + deploy
GRADSKY_API=https://api.gradsky.com.br
GRADSKY_PROJECT_ID=proj_...           # recomendado se houver mais de um projeto
GRADSKY_PUBLIC_DOMAIN=true            # cria USERNAME.gradsky.com.br
GRADSKY_ATTACH_DOMAIN=false           # true para solicitar dominio customizado
GRADSKY_VERIFY_DOMAIN=false           # true para tentar verify custom domain com backoff
GRADSKY_FORCE_DOMAIN=false            # true para reconfigurar dominio de service existente
GRADSKY_GIT_AUTO_DEPLOY=true          # push no GitHub dispara redeploy automatico
GRADSKY_FORCE_DEPLOY=false            # true para forcar POST /deploy via API
DOMINIO_BASE=meunegocio.com.br        # obrigatorio apenas se GRADSKY_ATTACH_DOMAIN=true

# GitHub
GH_TOKEN=...                          # PAT GitHub do aluno
GH_USER=meunegocio-bot                # user/org no GitHub do aluno
GH_EMAIL=deploy@meunegocio.com.br
```

Se `GRADSKY_TOKEN` nao estiver setado, o agente ABORTA o deploy e responde:

> "Falta configurar `GRADSKY_TOKEN` no .env do agente. Gere um PAT no Gradsky com scopes `read` e `deploy`, salve em `GRADSKY_TOKEN`, e tente novamente."

E mostra o passo a passo (ver secao "Como o aluno configura o dominio dele" no PLAYBOOK-BMAD.md).

## Arquivos da skill

```
analisar-instagram-bmad/
  SKILL.md                    (este arquivo)
  PLAYBOOK-BMAD.md            (metodologia BMAD em PT-BR)
  template-dossie.html        (template cinematografico)
  prompts/
    01-visao-macro.md
    02-conteudo.md
    03-estrategia-30-dias.md
```

## Regras importantes

1. Nunca invente dados. Se o coletor nao retornar campo X, deixar `null` no HTML.
2. Sempre confirmar @username antes de gastar API. Se ambiguo, perguntar.
3. Se perfil for privado, avisar e parar. Nao tentar engenharia social.
4. Plano de 30 dias sempre tem meta numerica realista (+10% padrao).
5. Tom de voz: portugues brasileiro, fluido, sem travessoes, sem linguagem robotica.
6. Apos deploy, sempre entregar a URL retornada pela Gradsky. Se dominio customizado estiver habilitado, entregar tambem `https://USERNAME.DOMINIO_BASE`.
