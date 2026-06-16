# Prompt guide — visual-gen

Boas práticas de prompt por modelo. Vai direto ao que funciona — sem teoria.

## Princípios gerais (todos modelos)

1. **Descreva, não comande.** "Foto de uma cafeteria" funciona melhor que "Crie uma cafeteria pra mim".
2. **Específico ganha de genérico.** "Lente 85mm, ISO 400, golden hour" > "foto bonita".
3. **Câmera + iluminação > adjetivos vagos.** "luz suave de janela à esquerda, sombras quentes" > "lindo e profissional".
4. **PT-BR funciona, mas EN gera resultado mais consistente** nos modelos treinados com legendas em inglês (Flux, Kling, Veo). Use PT-BR só se o modelo tiver suporte explícito (Nano Banana, Seedream).

---

## Flux Dev / Flux Schnell (T2I)

**O que faz bem:** texto realista, composições com texto sobreposto, foto-realismo, ilustração editorial.
**O que faz mal:** anatomia complexa (mãos), múltiplas pessoas distintas, pequenos detalhes específicos.

**Fórmula:**
```
[subject], [action/pose], [setting/environment], [lighting], [camera/lens], [style/mood]
```

**Exemplo bom:**
> A barista woman in her 30s, mid-laugh while pouring latte art, modern Brazilian café with warm wood panels, golden hour light from window left, 85mm portrait lens, shallow depth of field, documentary style.

**Exemplo ruim** (vago demais, sem direção de câmera):
> Uma barista feliz numa cafeteria.

**Tips:**
- Width/height múltiplos de 64. Quadrado: 1024×1024. Retrato: 832×1216. Paisagem: 1216×832.
- Pra texto dentro da imagem use aspas: `... a sign reading "OPEN" in chalk lettering ...`
- Negative prompt (passando via `--extra '{"negative_prompt":"..."}'`): `blurry, low quality, watermark, text overlay` evita ruído.

---

## Google Imagen 4 (T2I premium)

**O que faz bem:** foto-realismo extremo, texto crisp dentro da imagem, retratos, produto.
**O que faz mal:** ilustração / estilo artístico não-fotográfico.

**Estilo de prompt:** mais natural/descritivo, frases inteiras, menos "tags". Imagen entende português melhor que Flux.

**Exemplo bom:**
> Retrato profissional de um homem brasileiro de 45 anos, executivo, sorriso confiante, terno azul-marinho, fundo desfocado de escritório moderno em São Paulo, iluminação suave de estúdio em três pontos, foco nos olhos.

**Tip:** Imagen 4 só aceita aspect ratio (não width/height). Use `--aspect-ratio 16:9` ou similar.

---

## Nano Banana (T2I ou I2I)

**T2I:** rápido, versátil, suporta português.
**I2I (com `--image-url`):** brilha em **edição preservando identidade**. Muda roupa, fundo, estilo, mas mantém rosto/composição.

**Prompts I2I devem descrever o RESULTADO FINAL, não a edição:**

❌ Ruim:
> Mude a roupa pra terno.

✅ Bom:
> A mesma pessoa, agora vestindo um terno preto formal com gravata, mantendo expressão e pose originais, fundo idêntico.

**`--strength`:**
- `0.3` = mudança sutil (cor, iluminação)
- `0.6` (default) = mudança média (roupa, fundo)
- `0.9` = transformação radical (estilo, cenário)

---

## Kling v2.6 Pro (T2V)

**O que faz bem:** movimento natural de câmera, ação física crível, slow motion, transições suaves.
**O que faz mal:** rosto humano sustentado (deforma após 3-4s), texto/letras animadas, narrativa complexa.

**Fórmula:**
```
[camera movement], [subject + action], [setting], [pacing/style cues]
```

**Exemplo bom:**
> Tracking shot from the side, a black Tesla Model S accelerates on a rainy night street in Tokyo, neon reflections on wet asphalt, slow motion, cinematic, shallow depth of field.

**Tips:**
- **Movimento de câmera** primeiro: `tracking shot`, `slow zoom in`, `dolly forward`, `static wide shot`.
- **Duração curta = qualidade alta.** 5s sempre melhor que 10s em quase tudo.
- **Aspect 9:16** pra vertical (Reels/Stories), `16:9` pra YouTube/landscape.

---

## Seedance Pro Fast (T2V barato)

Mesmo princípio do Kling mas qualidade ~60-70% e custo ~20%. Use pra **rascunho/teste de conceito**.

Quando rodar:
- Primeiro: Seedance Fast (R$0,X)
- Se aprovou conceito: re-roda em Kling Pro (R$X,XX)

---

## Veo 3 (I2V — anima imagem)

**O que faz bem:** movimento sutil que parece "filmagem real" da imagem inicial. Foco em micro-movimentos (piscar, respirar, cabelo balançando, fumaça subindo).
**O que faz mal:** mudança radical de cenário/composição (a imagem é a ÂNCORA).

**Prompt descreve só o MOVIMENTO, não a imagem:**

❌ Ruim:
> Uma mulher numa cafeteria sorrindo, o cabelo balançando.

✅ Bom:
> The woman blinks slowly, smiles a little wider, hair sways gently to the right, steam rising softly from the cup.

**Tips:**
- Movimento pequeno > grande. Veo 3 brilha em sutileza.
- Aspect ratio **deve bater** com a imagem de entrada — se a foto é 9:16, passa `--aspect-ratio 9:16`.
- Áudio nativo opcional: passa `--extra '{"audio":true}'` (mais caro).

---

## Anti-patterns universais

❌ Prompt com **lista de adjetivos vazios**: "linda, incrível, profissional, perfeita"
❌ Pedir **número exato** de elementos > 3: "5 pessoas exatamente alinhadas" raramente sai certo
❌ **Texto longo** dentro da imagem: > 4 palavras tende a sair quebrado (exceto Imagen 4 e Ideogram)
❌ **Marcas reais** com logotipo específico: vai sair "parecido com" — direitos autorais
❌ Pedir o impossível físico: "uma pessoa olhando pra dois lados ao mesmo tempo"

---

## Workflow recomendado (custo + qualidade)

1. **Rascunho** com Flux Dev ou Seedance Fast (cêntimos).
2. Mostra pro Chefe — só aprovado, vai pra premium.
3. **Final** em Imagen 4 / Kling Pro / Veo 3.
4. **Edição pontual** em Nano Banana com strength baixa.

Sempre gere com `--seed <N>` quando achar uma composição boa pra **reproduzir** com variações.
