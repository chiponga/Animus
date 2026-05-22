# Componentes do padrao Felipe SaaS

Este arquivo descreve os componentes que a IA deve criar ou reutilizar em SaaS, dashboard, CRM, admin e backoffice no padrao Felipe.

## 1. AppLayout

Responsabilidade:

- Estrutura global do app.
- Sidebar desktop.
- Topbar desktop.
- Mobile topbar.
- Mobile bottom navigation.
- Container principal responsivo.

Desktop:

- Sidebar fixa em `left: 0`, altura total.
- Sidebar colapsada: `72px`.
- Sidebar expandida: `240px`.
- Main com padding-left equivalente ao estado da sidebar.
- Topbar desktop com altura `64px`, alinhada a direita.
- Conteudo com `max-width: 1400px`.

Mobile:

- Sem sidebar fixa lateral.
- Topbar mobile no topo.
- Bottom nav fixa.
- Main com `px-4 pb-24`.

Nao fazer:

- Header marketing.
- Sidebar clara no light mode.
- Main muito largo sem max-width.
- Conteudo encostado nas bordas.

## 2. Sidebar

Visual:

- Fundo `sidebar` sempre escuro.
- Texto branco/cinza.
- Item ativo com `bg-lime/[0.14]`, `text-lime`, ring/border lime sutil.
- Item normal transparente.
- Hover com branco/lime discreto.

Dimensoes:

- Item nav: altura `44px`.
- Radius `12px`.
- Icone `18px`.
- Gap icon/text: `10px` a `12px`.
- Logo: `36px x 36px`, radius `12px`, bg lime transparente.

Conteudo:

- Logo/produto.
- Navegacao principal.
- Projetos/atalhos quando fizer sentido.
- Usuario/config no rodape quando necessario.

## 3. Topbar

Desktop:

- Altura `64px`.
- Conteudo alinhado a direita.
- Botoes circulares `36px x 36px`.
- User pill com avatar pequeno.
- Botao theme/notification discreto.

Mobile:

- Altura 56-64px.
- Titulo curto.
- Acoes essenciais apenas.

Regra:

- Topbar nao deve roubar atencao do dashboard.

## 4. Card

Classe base conceitual:

```tsx
<section className="lumina-card p-5" />
```

Dark:

- Background `surface`.
- Sem shadow forte.
- Sem borda visivel grossa.
- Radius `1.25rem`.
- Hover opcional: `surface-2`.

Light:

- Background branco.
- Shadow suave.
- Border muito discreta.

Header interno:

- `mb-3 flex items-start justify-between gap-3`.
- Title: `text-sm font-semibold text-text`.
- Subtitle: `text-xs text-text-muted`.

Nao fazer:

- Card dentro de card sem razao.
- Card com padding gigante.
- Card com gradiente decorativo.
- Card com borda neon pesada.

## 5. KpiCard

Uso:

- Receita.
- Despesas.
- Lucro.
- Margem.
- ROI.
- ROAS.
- Ticket Medio.
- Conversao.

Estrutura:

- Card `p-4`.
- Icone topo: `32px x 32px`, rounded-full, bg accent/10, text accent.
- Label: uppercase, `10px`, tracking `0.14em`, text-dim.
- Valor: `22px` aprox, font-bold, tabular-nums.
- Trend pill: `10.5px`, bg success/danger/neutral com alpha baixo.
- Rodape opcional com descricao curta.

Regras:

- Numeros devem usar formatacao local.
- Valor monetario: `R$ 12.345,67`.
- Percentual: `12,4%`.
- Negativo real em vermelho apenas quando for ruim.
- Loading com skeleton no mesmo tamanho do conteudo.

## 6. Button

Variantes:

- `primary`: lime `#AFFF00`, texto preto, shadow lime suave, hover `#BCFF14`.
- `ghost`: transparente, borda branca/10, hover surface-2.
- `danger`: vermelho discreto, nao neon.
- `subtle`: surface-2, texto muted.

Tamanhos:

- `sm`: h 32px, px 12px.
- `md`: h 40px, px 16px.
- `lg`: h 48px, px 20px.

Regras:

- Primary so para acao principal.
- Ghost para filtro, navegacao e acoes secundarias.
- Icon-only precisa tooltip quando acao nao for obvia.

## 7. Pill / Badge

Uso:

- Status.
- Periodo.
- Filtro.
- Tags de projeto.
- Ambiente.

Visual:

- Rounded-full.
- Padding `0.5rem 0.9rem` para pill clicavel.
- Font size `12px` a `13px`.
- Active: accent bg/text.
- Inactive: surface-2/border muted.

Status:

- Paid/online/success: green.
- Pending: amber.
- Failed/error: red.
- Draft/neutral: gray.

## 8. Table

Preferencia visual:

- Pode usar CSS grid para controle fino.
- Cabecalho pequeno uppercase.
- Linhas compactas.
- Hover sutil.
- Valores numericos alinhados a direita.

Header:

- `px-4 py-2.5`.
- Font `10px`, uppercase, tracking `.14em`, text-dim.
- Border bottom white/4.

Rows:

- `px-4 py-2.5`.
- Font `14px`.
- Hover `surface-2`.
- Stagger visual discreto quando renderiza.

Mobile:

- Reduzir colunas.
- Usar cards compactos se tabela ficar ilegivel.
- Nunca deixar texto quebrar layout.

## 9. RingKpi

Uso:

- Conversao por origem.
- Percentual de meta.
- Completion rate.

Visual:

- SVG viewBox `100 100`.
- Radius aprox `45.5`.
- Stroke `9`.
- Track `white/6`.
- Progress accent.
- Stroke cap round.
- Percentual central.
- Label acima ou abaixo.
- Footer com pago/total ou metrica primaria.

Regra:

- RingKpi deve ser informativo, nao decorativo.

## 10. LineChartSmooth

Uso:

- Receita/despesas/lucro por periodo.
- Evolucao de leads.
- Conversao.
- Volume de eventos.

Visual:

- SVG custom ou Recharts bem estilizado.
- Linha principal accent/lime.
- Series secundaria neutra.
- Grid pontilhado discreto.
- Area gradient muito sutil sob serie principal.
- Tooltip hover com fundo surface-2 e borda discreta.
- Altura padrao `220px` a `240px`.

Regras:

- Chart precisa ter estado vazio.
- Eixos nao devem poluir.
- Usar `tabular-nums`.
- Tooltip precisa formatar valores.

## 11. ProjectHeader

Uso:

- Paginas internas de projeto/admin.

Estrutura:

- Card compacto.
- Avatar/logo do projeto.
- Nome do projeto.
- Badges de status/ambiente.
- Acoes desktop.
- Acoes mobile reduzidas.

Visual:

- `p-3` mobile, `p-4` desktop.
- Gap 12-16px.
- H1 `18px` a `22px`, nunca hero.

## 12. PeriodPicker

Uso:

- Hoje.
- 7 dias.
- 30 dias.
- Mes.
- Custom.

Visual:

- Pills horizontais.
- No mobile, scroll horizontal.
- No desktop, wrap permitido.
- Active lime.

## 13. Forms

Inputs:

- Fundo surface-2.
- Border branca/10.
- Radius 12px.
- Focus ring accent/30.
- Label pequeno e claro.
- Error text vermelho, objetivo.

Forms nao devem:

- Ocupar largura total sem max-width quando forem simples.
- Esconder erro em toast apenas.
- Aceitar acao destrutiva sem confirmacao.

## 14. Skeleton

Regras:

- Mesmo tamanho aproximado do conteudo real.
- Shimmer discreto.
- Nao deslocar layout quando carrega.
- Usar em KPI, tabela, chart e cards.

## 15. Empty state

Visual:

- Card simples.
- Icone lucide discreto.
- Texto curto.
- CTA se houver proxima acao.

Nao usar:

- Ilustracao enorme.
- Texto explicativo longo.

