# Padroes de pagina do Felipe SaaS

Este arquivo define como montar telas completas, principalmente dashboard e admin panel.

## Principio central

Todo SaaS deve abrir em uma tela operacional.

Primeira viewport ideal:

- Sidebar.
- Topbar.
- Header compacto do projeto/area.
- Period picker/filtros.
- KPIs.
- Pelo menos um grafico ou tabela visivel.

Nao iniciar com:

- Hero de marketing.
- Texto explicando o produto.
- Card gigante de boas-vindas.
- Ilustracao decorativa.

## Dashboard principal

Ordem recomendada:

1. Header de projeto/area.
2. Period picker.
3. Grid KPI principal.
4. Grid KPI secundario.
5. Card de conversao/origem com RingKpis.
6. Card de grafico principal.
7. Card de composicao ou breakdown.
8. Funil/conversao.
9. Tabela de eventos/transacoes recentes.

### 1. Header

Conteudo:

- Nome do SaaS/projeto.
- Contexto curto: "Visao geral", "Operacao", "Financeiro", etc.
- Badges: ambiente, status, plano, projeto ativo.
- Acoes: exportar, atualizar, configurar.

Layout:

```text
[Avatar] Nome + badges                         [Acoes]
Descricao curta opcional
```

Mobile:

- Acoes podem virar menu.
- Nao quebrar titulo em muitas linhas.

### 2. Period picker

Exemplo:

```text
Hoje | 7 dias | 30 dias | Mes atual | Custom
```

Regras:

- Mobile com scroll horizontal.
- Estado ativo bem claro.
- Filtro muda todos os KPIs.

### 3. KPI grid principal

Desktop:

- 4 colunas.

Mobile:

- 2 colunas.

Conteudo exemplo:

- Receita.
- Despesas.
- Lucro.
- Margem.

Cada card:

- Icone.
- Label pequena.
- Valor grande.
- Trend.
- Descricao curta.

### 4. KPI grid secundario

Desktop:

- 3 colunas.

Mobile:

- 1 coluna.

Conteudo exemplo:

- ROI.
- ROAS.
- Ticket Medio.

### 5. Conversao por origem

Card com titulo e grid de RingKpis:

- Organico.
- Pago.
- Afiliado.
- WhatsApp.
- Instagram.
- Direct.

Cada RingKpi:

- Percentual.
- Total.
- Pago/convertido.
- Label.

### 6. Grafico principal

Card:

- Titulo.
- Subtitulo.
- LineChartSmooth.
- Tooltip hover.
- Estado vazio.

Series:

- Principal: receita/volume.
- Secundaria: despesa/benchmark.

Altura:

- 220 a 240px.

### 7. Breakdown/composicao

Exemplos:

- Despesas por gateway.
- Leads por origem.
- Status por etapa.
- Uso por tenant.

Layout:

- Grid 3 colunas no desktop.
- 1 coluna mobile.
- Subcards `surface-2`.

### 8. Funil

Uso:

- Visitas -> Cadastro -> Deposito -> Compra -> Retencao.
- Lead -> Qualificado -> Reuniao -> Proposta -> Fechado.

Visual:

- Barras horizontais ou funil compacto.
- Percentuais claros.
- Sem grafico 3D.

### 9. Tabela recente

Conteudo:

- Ultimas transacoes.
- Ultimos leads.
- Ultimos eventos.
- Ultimos tickets.

Regras:

- Compacta.
- Link "Ver todas".
- Status com badge.
- Valor/data alinhados.
- Limite 10 na dashboard.

## Pagina de listagem

Uso:

- Usuarios.
- Clientes.
- Transacoes.
- Projetos.
- Tickets.

Estrutura:

1. Header compacto.
2. Toolbar com busca, filtros e acao primaria.
3. Tabela.
4. Paginacao.
5. Empty state.

Toolbar:

- Busca esquerda.
- Filtros em pills/selects.
- Acao primaria direita.

Mobile:

- Busca full width.
- Filtros em scroll horizontal.
- Tabela vira cards se necessario.

## Pagina de detalhe

Uso:

- Cliente.
- Projeto.
- Transacao.
- Tenant.
- Ticket.

Estrutura:

1. Header com entidade e status.
2. Grid de KPIs ou resumo.
3. Tabs.
4. Conteudo principal.
5. Timeline/audit log.

Tabs comuns:

- Visao geral.
- Historico.
- Configuracoes.
- Logs.
- Financeiro.

Regra:

- Auditabilidade e rastreabilidade sao parte do produto, nao opcional.

## Pagina de configuracao

Estrutura:

1. Header.
2. Secoes em cards.
3. Forms compactos.
4. Save bar ou botoes por secao.
5. Confirmacao para acoes destrutivas.

Configuracoes sensiveis:

- Secrets sempre mascarados.
- Mostrar "alterar" sem revelar valor.
- Audit log da alteracao.
- Confirmacao para deletar env/domain/webhook.

## Pagina de autenticacao

Visual:

- Minimalista.
- Dark premium.
- Card unico com formulario.
- Sem hero split exagerado.
- Logo pequeno.

Campos:

- Email.
- Senha.
- 2FA quando existir.

Regras:

- Erro claro.
- Loading no submit.
- Nao revelar se email existe quando for sensivel.

## SaaS novo: telas minimas

Para um MVP SaaS operacional, criar pelo menos:

- Login.
- Dashboard.
- Listagem da entidade principal.
- Detalhe da entidade principal.
- Configuracoes.
- Logs/auditoria ou atividades recentes.

Se houver billing:

- Plano/assinatura.
- Pagamentos/faturas.
- Webhook/audit log.

Se houver multi-tenant:

- Organization switcher.
- Usuarios/membros.
- Permissoes.
- Audit log por tenant.

## Responsividade

Breakpoints conceituais:

- Mobile: < 768px.
- Tablet: 768-1024px.
- Desktop: > 1024px.

Regras:

- Desktop usa sidebar.
- Mobile usa bottom nav.
- KPI 4 cols desktop, 2 cols mobile.
- Secoes grandes 3 cols desktop, 1 mobile.
- Tabela pode virar cards no mobile.
- Texto nao pode sair do container.

## Conteudo e microcopy

Tom:

- Operacional.
- Claro.
- Curto.
- Sem marketing em excesso.

Labels:

- "Receita", "Despesas", "Lucro", "Margem".
- "Ultimas transacoes".
- "Conversao por origem".
- "Atividade recente".
- "Configurar".

Evitar:

- "Revolucione seu negocio".
- "Plataforma inovadora".
- Textos longos explicando UI.

