# Playbook BMAD aplicado a Instagram

Este playbook explica a metodologia BMAD usada na analise de perfis de Instagram. BMAD e um framework de auditoria estrategica que combina tres pilares de diagnostico:

- **B** = Business Model (Modelo de negocio)
- **M** = Marketing/Mensagem (Posicionamento e narrativa)
- **A** = Audience (Audiencia e ICP)
- **D** = Differentiation (Diferenciacao competitiva)

## Por que BMAD

A maioria dos perfis cria conteudo aleatorio sem clareza de modelo de negocio, mensagem central ou diferenciacao. O resultado e crescimento lento, baixa conversao em vendas e churn alto de seguidores.

Aplicar BMAD obriga o analista (no caso, voce, agente IA) a olhar o perfil sob 4 lentes complementares e produzir um diagnostico que o dono do perfil consiga executar em 30 dias.

## Pilar 1: Business Model (B)

Perguntas que voce responde:

1. Como esse perfil ganha dinheiro hoje? (curso, mentoria, infoproduto, servico, e-commerce, parcerias)
2. Existe oferta clara no link da bio?
3. Qual o ticket medio aparente?
4. Existe escada de valor (produto barato => caro)?
5. Existe funil de captura (lead magnet => nutricao => venda)?

Sinais de saude:
- Link da bio leva pra pagina de venda especifica (nao homepage)
- Bio menciona oferta principal e CTA
- Stories destacados explicam produtos
- Posts recentes sao colados em ofertas (lancamento ou perpetuo)

Sinais de doenca:
- Link "linktree" generico com 10 destinos sem priorizacao
- Bio so com missao/valores, sem CTA
- Zero menciao a produto nos ultimos 12 posts
- Nenhum lead magnet visivel

## Pilar 2: Marketing/Mensagem (M)

Perguntas:

1. Qual a promessa central do perfil?
2. Em uma frase, "esse perfil ajuda quem a fazer o que"?
3. A bio comunica isso em ate 150 caracteres?
4. Os ultimos 12 posts reforcam a mesma mensagem ou pulam de tema?

Sinais de saude:
- Mensagem central repetida em angulos diferentes
- Linguagem consistente (tom, jargao, gatilhos)
- Bio responde "pra quem e isso" e "qual o resultado prometido"

Sinais de doenca:
- Mistura nichos (ex: "fitness + financas pessoais + reels engracados")
- Bio com palavras genericas ("apaixonado por ajudar pessoas")
- Posts sem tese clara

## Pilar 3: Audience (A) — ICP

Perguntas:

1. Quem e o ICP (perfil de cliente ideal)?
2. Esse ICP pode pagar pelo produto?
3. Os comentarios mostram que esse ICP esta engajando?
4. Existe diversidade de origem (tudo veio de trafego pago? ou tem organico?)

Sinais de saude:
- Comentarios sao do nicho-alvo (linguagem coerente, perguntas de compra)
- ICP claro e segmentado (ex: "dentistas que faturam 30k/mes e querem escalar pra 100k")
- Trafego pago fortalece organico, nao mascara

Sinais de doenca:
- Comentarios vazios ("amei", "lindo")
- ICP indefinido ("todo mundo que quer melhorar de vida")
- Engajamento alto em conteudo viral mas zero em conteudo de venda

## Pilar 4: Differentiation (D)

Perguntas:

1. Por que esse perfil em vez do concorrente?
2. Qual o angulo unico?
3. Existe prova social proprietaria (cases, depoimentos, dados)?
4. Existe metodo proprio nomeado?

Sinais de saude:
- Metodo proprio com nome (ex: "Metodo SDR Avalanche")
- Cases recorrentes nos posts
- Posicionamento contraintuitivo

Sinais de doenca:
- Conteudo identico ao de 50 outros perfis do nicho
- Sem cases proprios
- Linguagem padrao do nicho ("dicas pra empreender", "mindset")

## Pricing pro cliente

Apos rodar o BMAD e gerar o dossie, esses sao os tickets sugeridos:

| Faixa de seguidores | Ticket sugerido | Margem operacional |
|---|---|---|
| Ate 50k | R$ 497 | > 99% |
| 50k a 500k | R$ 997 | > 99% |
| 500k a 1M | R$ 1.497 | > 99% |
| 1M+ | R$ 2.000+ | > 99% |

Custo de producao: depende do scraper escolhido pelo aluno + Gemini (~US$0,02 por chamada).

## Diferenciais do dossie BMAD vs analise comum

1. **Dados reais**: o coletor escolhido retorna numeros (seguidores, engajamento, lista de posts).
2. **Plano executavel**: 30 dias com posts dia a dia, nao apenas conselhos vagos.
3. **Site cinematografico**: cliente recebe URL profissional no SUBDOMINIO DO ALUNO (USERNAME.DOMINIO_BASE, ex: joaodasilva.meunegocio.com.br), nao PDF.
4. **Meta numerica**: +10% seguidores em 30 dias por padrao, ou foco em vendas se pedido.
5. **Velocidade**: poucos minutos do @username ao link entregue, dependendo do coletor.

## Como o aluno configura o dominio dele

A skill NAO usa dominio customizado fixo. Por padrao, ela gera um dominio publico Gradsky (`<USERNAME_DO_INSTAGRAM>.gradsky.com.br`). Se `GRADSKY_ATTACH_DOMAIN=true`, tambem solicita `<USERNAME_DO_INSTAGRAM>.<DOMINIO_BASE>`, onde `DOMINIO_BASE` vem do `.env` do agente do aluno.

### Pre-requisitos do aluno

1. Ter um dominio registrado (ex: `meunegocio.com.br`, `clinicadrjoao.com`, qualquer um).
2. Ter conta Gradsky ativa.
3. Ter um PAT Gradsky com scopes `read` e `deploy`.
4. Ter conta no GitHub (user ou organization).

### Variaveis que o aluno cadastra no .env do Animus

```bash
# Dominio raiz do aluno (sem http, sem subdominio)
DOMINIO_BASE=meunegocio.com.br

# Gradsky
GRADSKY_TOKEN=gsky_pat_...       # PAT com read + deploy
GRADSKY_API=https://api.gradsky.com.br
GRADSKY_PROJECT_ID=proj_...      # recomendado quando ha mais de um projeto
GRADSKY_PUBLIC_DOMAIN=true       # cria dominio gerenciado x.gradsky.com.br
GRADSKY_ATTACH_DOMAIN=false      # true para solicitar dominio customizado
GRADSKY_VERIFY_DOMAIN=false      # true para tentar verificar custom domain com backoff
GRADSKY_FORCE_DOMAIN=false       # true para reconfigurar dominio de service existente
GRADSKY_GIT_AUTO_DEPLOY=true     # push no GitHub dispara redeploy automatico
GRADSKY_FORCE_DEPLOY=false       # true para forcar POST /deploy via API

# GitHub (do aluno)
GH_TOKEN=ghp_...                 # PAT com permissao repo
GH_USER=meunegocio-bot           # username ou org do GitHub
GH_EMAIL=deploy@meunegocio.com.br
```

### Como o aluno consegue cada token

**Gradsky PAT + projeto:**
1. Login em `https://app.gradsky.com.br`.
2. Settings -> Tokens de Acesso -> Gerar novo token.
3. Scopes minimos: `read` e `deploy`.
4. Salvar em `GRADSKY_TOKEN`.
5. Se o token acessa mais de um projeto, definir `GRADSKY_PROJECT_ID`.
6. Para dominio publico Gradsky, manter `GRADSKY_PUBLIC_DOMAIN=true` e garantir scope `domains:write`.
7. Para dominio customizado, habilitar `GRADSKY_ATTACH_DOMAIN=true`, preencher `DOMINIO_BASE`, garantir scope `domains:write` e configurar DNS.
8. Se o DNS for Cloudflare, manter proxy cinza/DNS only ate o SSL responder; depois pode ligar proxy laranja com SSL `Full (strict)`.

**GitHub Token + Owner:**
1. Login em github.com -> Settings -> Developer settings -> Personal access tokens -> Fine-grained ou Classic.
2. Permissoes: `repo` (criar repos privados, push).
3. `GH_USER` e o username (ou org) que vai dono dos repos `dossie-<username>`.

### Validacao automatica no deploy-dossie.sh

O script valida na ordem:

1. Existe `DOMINIO_BASE`? Se nao -> aborta com instrucao.
2. Existe `GRADSKY_TOKEN`? Se nao -> aborta.
3. Existe `GRADSKY_PROJECT_ID` ou apenas um projeto acessivel via PAT? Se nao -> aborta.
4. Existe `GH_TOKEN` e `GH_USER`? Se nao -> aborta.
5. Se dominio customizado estiver ativo, a API retornou/verificou DNS ou o agente entregou as instrucoes de CNAME/TXT?

Se tudo OK, monta o FQDN como `${USERNAME_INSTAGRAM}.${DOMINIO_BASE}` e segue o pipeline.

### Exemplo concreto

Aluno: Joao da Silva. Dominio dele: `joaosilva.com.br`.

```bash
# .env do agente do Joao
DOMINIO_BASE=joaosilva.com.br
GRADSKY_PROJECT_ID=proj_joao
GRADSKY_PUBLIC_DOMAIN=true
GRADSKY_ATTACH_DOMAIN=true
GH_USER=joaosilva-bot
```

Joao roda `analisa @perfilcliente`. Resultado:
- Repo GitHub: `joaosilva-bot/dossie-perfilcliente` (privado)
- Service Gradsky: `dossie-perfilcliente`
- Dominio publico Gradsky: `perfilcliente.gradsky.com.br`
- Dominio Gradsky solicitado: `perfilcliente.joaosilva.com.br`
- URL final entregue ao cliente: `https://perfilcliente.joaosilva.com.br`

## Checklist mental antes de entregar

- [ ] Os 4 pilares B M A D foram cobertos no dossie?
- [ ] O plano de 30 dias tem 30 cards (um por dia)?
- [ ] A meta numerica esta explicita (+10% ou X reais)?
- [ ] O HTML carrega sem erro no service Gradsky?
- [ ] O `DOMINIO_BASE` do aluno foi lido com sucesso do .env?
- [ ] O dominio `USERNAME.DOMINIO_BASE` responde 200?
- [ ] O resumo executivo tem 5 bullets concretos?

Se algum item falhou, corrigir antes de entregar.

## Tom de voz

Sempre PT-BR, fluido, estrategico. Sem travessoes. Sem linguagem academica. Direto ao ponto, com numeros e CTAs concretos.

Exemplo de frase boa:
"Seu engajamento medio cai 47% nos posts de venda. A causa e que o angulo muda: voce vende como guru e seu publico esta acostumado com voce educando."

Exemplo de frase ruim:
"Observamos uma certa queda no engajamento dos posts comerciais que pode estar relacionada a fatores diversos."
