# QA checklist do padrao Felipe SaaS

Use este checklist antes de entregar qualquer SaaS, dashboard, CRM ou admin panel no padrao Felipe.

## 1. Identidade visual

- [ ] Usa Gantari ou fallback justificado.
- [ ] Dark mode e primeira experiencia.
- [ ] Accent principal e `#AFFF00`.
- [ ] Sidebar permanece escura.
- [ ] Cards usam `surface`/`surface-2`.
- [ ] Nao ha paleta azul/roxo generica dominando.
- [ ] Nao ha blobs/orbs/gradientes decorativos sem funcao.
- [ ] A tela parece produto operacional, nao landing.

## 2. Layout

- [ ] Desktop tem sidebar fixa.
- [ ] Mobile tem navegacao adequada.
- [ ] Main tem largura controlada, idealmente max `1400px`.
- [ ] Primeira viewport mostra produto funcionando.
- [ ] Header e compacto.
- [ ] Period/filtros sao escaneaveis.
- [ ] Cards nao estouram texto.
- [ ] Nao existe sobreposicao visual.

## 3. Componentes

- [ ] Card base consistente.
- [ ] Button primary/ghost/danger/subtle coerentes.
- [ ] KPI cards com label, valor, trend e loading.
- [ ] Tabelas compactas com status e estados.
- [ ] Graficos possuem estado vazio.
- [ ] Badges/pills tem active/inactive.
- [ ] Forms tem label, error, loading e disabled.
- [ ] Skeleton nao desloca layout.

## 4. Dashboard

- [ ] KPI principal em 4 colunas desktop, 2 mobile.
- [ ] KPI secundario em 3 colunas desktop, 1 mobile.
- [ ] Ha grafico principal.
- [ ] Ha tabela recente.
- [ ] Ha breakdown/funil quando faz sentido.
- [ ] Dados monetarios usam formato `R$`.
- [ ] Percentuais e numeros usam formatacao local.

## 5. UX operacional

- [ ] Cada tela tem proxima acao clara.
- [ ] Empty states orientam sem textao.
- [ ] Erros sao legiveis.
- [ ] Loading e visivel.
- [ ] Acoes destrutivas pedem confirmacao.
- [ ] Secrets ou dados sensiveis aparecem mascarados.
- [ ] Audit/log existe quando operacao critica.

## 6. Frontend tecnico

- [ ] TypeScript passa.
- [ ] Build passa.
- [ ] Sem erros de console relevantes.
- [ ] Componentes reutilizaveis nao duplicam logica.
- [ ] Fetch/API client nao esta espalhado sem criterio.
- [ ] Responsividade testada em mobile e desktop.
- [ ] Acessibilidade basica: foco, labels, contraste.

## 7. Backend tecnico

- [ ] Healthcheck existe.
- [ ] Error shape e consistente.
- [ ] Request ID/log estruturado quando possivel.
- [ ] Auth/tenant isolation avaliados se existem.
- [ ] Banco tem indices para filtros principais.
- [ ] Migrations nao destroem dados sem plano.
- [ ] Secrets nao estao no repo.
- [ ] Rate limit existe em rotas sensiveis.

## 8. Deploy

- [ ] `.env.example` existe sem secrets reais.
- [ ] Scripts de start/build claros.
- [ ] Gradsky/PM2/Docker documentado conforme alvo.
- [ ] Healthcheck usado pelo deploy.
- [ ] Rollback pensado.
- [ ] Auto-deploy via Git considerado quando Gradsky estiver configurado.

## 9. Revisao final

Perguntas finais:

- [ ] Um usuario real entenderia o que fazer em 5 segundos?
- [ ] O produto parece do ecossistema Felipe/Lumina/NEW ADMIN?
- [ ] O dashboard e util ou so bonito?
- [ ] Existem placeholders enganosos?
- [ ] Existe alguma promessa tecnica que nao foi implementada?
- [ ] O que foi validado esta documentado no relatorio final?

## Saida obrigatoria no relatorio final

O agente deve entregar:

- Arquivos criados/alterados.
- Padroes aplicados.
- Validacoes rodadas.
- O que nao foi validado.
- Riscos.
- Como rodar localmente.
- Como testar visualmente.
- Proximos passos tecnicos objetivos.

