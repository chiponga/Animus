# Tokens visuais do padrao Felipe SaaS

Este arquivo define as decisoes visuais que a IA deve respeitar ao criar SaaS, dashboard, CRM, admin panel ou backoffice no padrao Felipe.

## Identidade geral

Sensacao desejada:

- Produto premium operacional.
- Interface de trabalho real, nao marketing.
- Densa, limpa, rapida de escanear.
- Dark-first.
- Acento lime forte.
- Superficies flat com profundidade controlada.
- Motion discreto e caro.

Nao deve parecer:

- Landing page.
- Template SaaS generico azul/roxo.
- Dashboard colorido demais.
- UI cheia de gradientes decorativos.
- Glassmorphism exagerado.
- Shadcn default sem identidade.

## Fonte

Primaria:

- `Gantari`

Fallback:

- `Inter`
- `system-ui`
- `sans-serif`

Regras:

- Body: Gantari, peso 400-500.
- Titulos: peso 700.
- Numeros: usar `tabular-nums`.
- Evitar letter-spacing negativa agressiva.
- Para labels pequenas, uppercase com tracking leve.

## Paleta principal

Dark mode:

| Token | Valor | Uso |
|---|---:|---|
| `bg` | `#000000` | Fundo global |
| `sidebar` | `#0A0A0A` | Sidebar fixa |
| `surface` | `#0F0F0F` | Cards principais |
| `surface-2` | `#161616` | Subcards, hover, blocos internos |
| `border` | `rgba(255,255,255,0.08)` | Bordas sutis |
| `text` | `#F8FAFC` | Texto principal |
| `text-muted` | `#A1A1AA` | Texto secundario |
| `text-dim` | `#71717A` | Labels, metadados |
| `accent` | `#AFFF00` | Acao, ativo, destaque |
| `accent-hover` | `#BCFF14` | Hover do acento |
| `accent-text` | `#D8FF58` | Texto/acento em fundo escuro |

Light mode:

| Token | Valor | Uso |
|---|---:|---|
| `bg` | `#F6F7F9` | Fundo global claro |
| `surface` | `#FFFFFF` | Cards |
| `surface-2` | `#F3F4F6` | Subcards |
| `sidebar` | `#0A0A0A` | Continua escura |
| `text` | `#09090B` | Texto principal |
| `text-muted` | `#52525B` | Texto secundario |
| `text-dim` | `#71717A` | Labels |
| `accent` | `#AFFF00` | Acao |
| `accent-text` | `#314D00` | Texto sobre acento claro |

Semanticos:

| Token | Valor | Uso |
|---|---:|---|
| `success` | `#22C55E` | Pagos, online, aprovado |
| `warning` | `#F59E0B` | Pendente, atencao |
| `danger` | `#EF4444` | Erro, falha, negativo |
| `info` | `#38BDF8` | Informativo secundario |

## Tailwind recomendado

Usar CSS variables no Tailwind para permitir dark/light:

```ts
colors: {
  bg: "rgb(var(--bg) / <alpha-value>)",
  surface: "rgb(var(--surface) / <alpha-value>)",
  "surface-2": "rgb(var(--surface-2) / <alpha-value>)",
  border: "rgb(var(--border) / <alpha-value>)",
  text: "rgb(var(--text) / <alpha-value>)",
  "text-muted": "rgb(var(--text-muted) / <alpha-value>)",
  "text-dim": "rgb(var(--text-dim) / <alpha-value>)",
  accent: "rgb(var(--accent) / <alpha-value>)",
  "accent-text": "rgb(var(--accent-text) / <alpha-value>)"
}
```

CSS vars em RGB:

```css
:root,
.dark {
  --bg: 0 0 0;
  --sidebar: 10 10 10;
  --surface: 15 15 15;
  --surface-2: 22 22 22;
  --border: 255 255 255;
  --text: 248 250 252;
  --text-muted: 161 161 170;
  --text-dim: 113 113 122;
  --accent: 175 255 0;
  --accent-text: 216 255 88;
}

.light {
  --bg: 246 247 249;
  --surface: 255 255 255;
  --surface-2: 243 244 246;
  --text: 9 9 11;
  --text-muted: 82 82 91;
  --text-dim: 113 113 122;
  --accent-text: 49 77 0;
}
```

## Radius

| Elemento | Radius |
|---|---:|
| Card principal | `1.25rem` |
| Subcard | `0.75rem` a `1rem` |
| Botao | `0.9rem` |
| Pill | `999px` |
| Input | `0.75rem` |
| Avatar/logo | `0.75rem` |

Nao usar radius exagerado em todos os lugares. O padrao e arredondado premium, nao bubble UI.

## Shadows e profundidade

Dark mode:

- Cards quase sem shadow.
- Profundidade vem de contraste de superficie.
- Hover pode trocar `surface` para `surface-2`.

Light mode:

- Cards brancos podem ter shadow muito suave.
- Shadow nao deve dominar.

Sombras uteis:

```css
--shadow-soft: 0 18px 45px rgba(15, 23, 42, 0.08);
--shadow-lime: 0 18px 36px rgba(175, 255, 0, 0.20);
```

## Motion

Easing principal:

```css
cubic-bezier(0.16, 1, 0.3, 1)
```

Duracoes:

- Micro hover: 160ms a 220ms.
- Page enter: 280ms a 360ms.
- Modal: 220ms a 280ms.
- Chart reveal: 500ms a 800ms.

Regras:

- Movimento maximo em page enter: `translateY(8px)`.
- Hover de botao: `translateY(-1px)`.
- Evitar animacao infinita sem funcao.
- Stagger maximo: 40ms a 60ms por item.

## Spacing

Desktop:

- App main: `px-6 pb-12`.
- Mobile: `px-4 pb-24`.
- Gap principal entre secoes: 12px a 16px.
- Cards dashboard: 12px entre cards.
- Card padding: 16px a 20px.
- Header de projeto: 12px mobile, 16px desktop.

Dashboard padrao:

- KPI grid: gap 12px.
- Secoes: margin-bottom 12px/16px.
- Chart card: padding 20px.
- Table rows: py 10px.

## Iconografia

- Usar Lucide.
- Nav icons: 18px.
- KPI icons: 15px a 18px.
- Header icons: 18px.
- Buttons icon-only: 36px a 40px.
- Icone ativo usa accent/lime.
- Icone neutro usa text-muted.

## Estados

Todo componente precisa ter:

- Default.
- Hover.
- Active/selected.
- Loading/skeleton.
- Empty quando aplicavel.
- Disabled quando aplicavel.
- Error quando aplicavel.

## Cores proibidas por padrao

Nao usar como paleta dominante:

- Roxo/azul SaaS generico.
- Bege/areia.
- Marrom/laranja.
- Gradiente neon sem funcao.
- Paleta de uma unica cor com 20 tons iguais.

Pode usar cores semanticas pontuais para status, mas o produto deve continuar preto/lime/surface.

