---
name: criar-subagente
description: Cria um subagente novo do zero para Claude Code/Animus, com personalidade, system prompt, tools restritas e nicho especifico. Acionar quando o usuario disser "cria um subagente pra X", "preciso de um agente especialista em Y", "monta um subagente novo de Z", "quero um SDR de estetica", "cria um copywriter de mercado financeiro", "monta um analista de dados", "adiciona um agente novo no time", "expande a equipe com mais um agente", "preciso de um especialista em <nicho>", ou qualquer pedido para adicionar um novo membro ao time Animus alem dos especialistas centrais.
allowed-tools: Read, Write, Edit, Bash, Grep, Glob
---

# Skill: Criar Subagente

## Quando usar

Use esta skill quando o usuario quiser adicionar um subagente ao time Animus.

Frases gatilho:

- "cria um subagente pra X"
- "preciso de um agente especialista em Y"
- "monta um subagente novo de Z"
- "adiciona um agente novo no time"
- "expande a equipe com mais um agente"
- "quero um SDR especializado em <nicho>"
- "preciso de um copywriter de <mercado>"
- "monta um analista de dados / pesquisador / designer / gerente"

## O que esta skill faz

Cria um subagente Claude Code com:

1. Nome validado em slug.
2. Descricao com triggers reais.
3. System prompt completo em PT-BR.
4. Tools restritas conforme especialidade.
5. Modelo apropriado.
6. Arquivo salvo em `.claude/agents/<nome>.md`.
7. Validacao de conflito e checklist final.

## Plataforma oficial

O Animus usa Claude Code. O destino oficial dos subagentes e:

```text
.claude/agents/<nome>.md
```

Nao criar agentes para outros runtimes dentro deste projeto.

## Pipeline obrigatorio

### 1. Coletar inputs

Perguntar ou inferir:

- Nome do subagente: lowercase, sem espacos. Ex: `sdr-estetica`.
- Especialidade: o que ele faz.
- Nicho de atuacao.
- Quando deve ser acionado.
- Tools necessarias.
- Modelo: default `sonnet`; usar modelo superior apenas se houver justificativa.

### 2. Validar nome

Regras:

- Apenas `a-z`, `0-9` e hifen.
- Sem espacos, acentos, underscore ou maiusculas.
- Maximo 30 caracteres.
- Nao pode colidir com agente existente.

Se invalido, sugerir 2 ou 3 slugs corrigidos.

### 3. Gerar descricao com triggers

Formato:

```text
<Papel curto>. <O que faz>. Acionar quando: "<trigger 1>", "<trigger 2>", "<trigger 3>".
```

Triggers devem parecer frases reais do usuario.

### 4. Escolher tools

Ler `CATALOGO-TOOLS.md`. Regra principal: conceder a menor quantidade de tools que resolve o trabalho.

Resumo:

| Tipo | Tools |
|---|---|
| Dev / engenharia | Read, Write, Edit, Bash, WebFetch, Grep, Glob |
| Copywriter | Read, Write, Edit, WebFetch, WebSearch, Grep |
| SDR / vendas | Read, Write, WebFetch |
| Designer | Read, Write, Edit, Bash, WebFetch, Grep, Glob |
| Analista de dados | Read, Bash, WebFetch, WebSearch, Grep, Glob |
| Pesquisador | Read, WebFetch, WebSearch, Grep, Write |
| Gestor / PM | Read, Write, Edit, Grep, Glob |
| Triagem / roteador | Read, Grep |

### 5. Gerar system prompt

Usar `templates/subagent-template.md`.

Estrutura:

1. Quem e.
2. Hierarquia: reporta ao Animus.
3. Tom.
4. O que faz.
5. O que nao faz.
6. Tools permitidas e motivo.
7. Regras de seguranca.
8. Anti-patterns.
9. Como entregar.

### 6. Salvar arquivo

Preferir o script:

```bash
bash skills/criar-subagente/scripts/criar-subagente-claude.sh \
  --nome "sdr-estetica" \
  --descricao "SDR especialista em estetica..." \
  --tools "Read, Write, WebFetch" \
  --modelo "sonnet" \
  --prompt-file /tmp/sdr-estetica-prompt.md
```

Destino:

```text
.claude/agents/<nome>.md
```

### 7. Validar

- Conferir se o arquivo existe.
- Conferir frontmatter.
- Conferir se tools seguem o principio de menor privilegio.
- Conferir se nao houve colisao de nome.
- Conferir se o prompt nao manda o agente falar direto com o Chefe sem passar pelo Animus.

### 8. Output final

```text
Subagente <nome> criado.

Onde: .claude/agents/<nome>.md
Modelo: <modelo>
Tools: <tools>
Triggers: "<trigger 1>", "<trigger 2>", "<trigger 3>"

Como usar:
- "Animus, acione <nome> para <tarefa>."

Status: pronto para o proximo turno do Claude Code.
```

## Arquivos da skill

- `SKILL.md` - entrada principal.
- `scripts/criar-subagente-claude.sh` - script Claude Code.
- `templates/subagent-template.md` - skeleton do agente.
- `EXEMPLOS.md` - exemplos prontos.
- `CATALOGO-TOOLS.md` - matriz tools x especialidade.
- `PLAYBOOK.md` - quando criar vs adaptar existente.

## Regras de ouro

1. PT-BR sempre no system prompt.
2. Hierarquia clara: subagente reporta ao Animus.
3. Menos tools = mais seguranca.
4. Validar colisao antes de salvar.
5. Nao quebrar agentes existentes.
6. Nao criar runtime paralelo.
