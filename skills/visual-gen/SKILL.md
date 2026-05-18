---
name: visual-gen
description: Gera imagens e vídeos via API da Muapi.ai (Flux, Google Imagen, Nano Banana, Kling, Veo, Seedance). Use quando o Chefe pedir uma imagem/foto/banner/vídeo ou edição visual.
---

# Visual-Gen — Geração de imagem e vídeo

Skill thin que chama a API da [Muapi.ai](https://muapi.ai) (200+ modelos consolidados num único provider). Cobre 4 categorias: T2I (texto→imagem), I2I (editar imagem), T2V (texto→vídeo), I2V (imagem→vídeo).

## Quando usar

- "Gera uma imagem de…" / "cria um banner pra…" / "faz uma foto de…" → **flux-dev** ou **google-imagen4**
- "Muda essa foto pra…" / "edita a imagem pra ficar…" → **nano-banana** com `--image-url`
- "Faz um vídeo curto de…" → **kling-v2.6-pro-t2v** (premium) ou **seedance-pro-t2v-fast** (barato)
- "Anima essa imagem…" / "transforma essa foto em vídeo" → **veo3-image-to-video**

## Quando NÃO usar

- O Chefe só pediu um **prompt** pra ele colar em Freepik/Midjourney → não invoca a skill, escreve o prompt.
- Não tem `MUAPI_API_KEY` no `.env` → avisa o Chefe que precisa configurar primeiro.

## Setup (primeira vez)

1. Cria conta em <https://muapi.ai> e copia a API key.
2. Edita `/workspace/Animus/.env` e adiciona:
   ```
   MUAPI_API_KEY=mu_xxxxxxxxxxxxxxxxxxxx
   ```
3. Pronto. Não precisa instalar nada — só usa o Python já presente no container.

## Como invocar (linha de comando)

```bash
python3 /workspace/Animus/skills/visual-gen/scripts/generate.py \
  --model <ID> --prompt "<texto>" \
  [--aspect-ratio 16:9] [--width 1024 --height 1024] \
  [--image-url https://...] [--strength 0.7] \
  [--duration 5] [--seed 42] \
  [--output /tmp/saida.png]
```

Sucesso: imprime no stdout o **path do arquivo baixado** (`/tmp/visual-gen/<modelo>-<timestamp>.<ext>` se não passar `--output`).
Falha: exit code != 0, mensagem no stderr.

## Catálogo curado

Os 6 modelos abaixo cobrem a maioria dos casos. Catálogo completo está em [`scripts/models.json`](./scripts/models.json) e a fonte original é o `packages/studio/src/models.js` do repo [Open-Generative-AI](https://github.com/Anil-matcha/Open-Generative-AI) (200+ modelos).

| ID | Tipo | Quando usar | Tier |
|---|---|---|---|
| `flux-dev` | T2I | Imagem genérica, controle por `width`/`height` | padrão |
| `google-imagen4` | T2I | Foto-realismo premium, texto dentro da imagem | premium |
| `nano-banana` | T2I / I2I | Versátil; passa `--image-url` pra editar imagem existente preservando rosto/composição | padrão |
| `kling-v2.6-pro-t2v` | T2V | Vídeo curto premium a partir de texto | premium |
| `seedance-pro-t2v-fast` | T2V | Vídeo barato/rápido pra rascunho | barato |
| `veo3-image-to-video` | I2V | Anima imagem fixa, top de linha | premium |

## Exemplos

### Imagem T2I (Flux Dev)
```bash
python3 skills/visual-gen/scripts/generate.py \
  --model flux-dev \
  --prompt "Foto realista de uma mulher de 30 anos sorrindo numa cafeteria de São Paulo, luz natural, lente 85mm, profundidade de campo rasa." \
  --width 1024 --height 1024 \
  --output /tmp/foto-cafeteria.png
```

### Imagem premium (Google Imagen 4)
```bash
python3 skills/visual-gen/scripts/generate.py \
  --model google-imagen4 \
  --prompt "Mockup minimalista de um app SaaS de finanças em iPhone 15, fundo gradiente roxo." \
  --aspect-ratio 9:16
```

### Edição I2I (Nano Banana)
```bash
python3 skills/visual-gen/scripts/generate.py \
  --model nano-banana \
  --prompt "Mudar a roupa da pessoa pra terno preto formal mantendo rosto e cabelo." \
  --image-url https://exemplo.com/foto.jpg \
  --strength 0.7 \
  --output /tmp/foto-editada.png
```

### Vídeo T2V (Kling)
```bash
python3 skills/visual-gen/scripts/generate.py \
  --model kling-v2.6-pro-t2v \
  --prompt "Câmera lateral seguindo um Tesla Model S preto acelerando numa rua molhada à noite, reflexos de neon, slow motion." \
  --aspect-ratio 16:9 --duration 5 \
  --output /tmp/clip-tesla.mp4
```

### Vídeo I2V (Veo 3)
```bash
python3 skills/visual-gen/scripts/generate.py \
  --model veo3-image-to-video \
  --prompt "A pessoa pisca, sorri suavemente e o cabelo balança com o vento." \
  --image-url https://exemplo.com/retrato.jpg \
  --aspect-ratio 9:16 --duration 8 \
  --output /tmp/retrato-animado.mp4
```

## Integração com o bot Telegram (entrega de arquivos)

Depois de gerar, devolva o resultado pro Chefe usando o marker que o bot reconhece:

```
[[SEND_FILE:/tmp/visual-gen/flux-dev-1709567890.png|foto da cafeteria]]
```

O bot do Animus remove o marker e envia o arquivo como anexo no Telegram. Limite: 50MB por arquivo. Caminho deve ser **absoluto**.

## Custo aproximado

Muapi cobra por geração (varia por modelo). Em ordem de grandeza, ~2026:
- Flux Dev / Nano Banana / Seedance Fast: **alguns centavos** por imagem/clip
- Google Imagen 4 / Kling Pro / Veo 3: **dezenas de centavos** a alguns reais
- Vídeos longos podem chegar a vários dólares

**Boas práticas pra economizar:**
1. Faz **rascunho** com modelo barato (Flux Dev, Seedance Fast) antes de gastar com premium.
2. Em I2I, use `strength` baixa (0.3-0.5) pra alterações sutis — economiza tokens e preserva mais a imagem original.
3. Em vídeo, **5s** custa metade de 10s. Use 10s só quando a cena justifica.

## Troubleshooting

| Sintoma | Causa | Fix |
|---|---|---|
| `MUAPI_API_KEY não definida` | Falta no `.env` | Adiciona linha `MUAPI_API_KEY=...` |
| `submit falhou: HTTP 401` | Key inválida ou expirada | Gera nova em muapi.ai |
| `submit falhou: HTTP 402` | Sem crédito | Recarga em muapi.ai |
| `timeout após 300s aguardando resultado` | Modelo pesado, fila grande | Aumenta `--timeout 600` ou usa modelo mais rápido |
| `não consegui extrair URL do resultado` | Formato de resposta mudou | Adiciona o caminho novo em `extract_output_url()` |

## Como adicionar mais modelos

1. Encontra o ID no catálogo do [Open-Generative-AI/packages/studio/src/models.js](https://github.com/Anil-matcha/Open-Generative-AI/blob/main/packages/studio/src/models.js).
2. Adiciona uma entrada em `scripts/models.json` com `kind`, `label`, `use_when`, `params`, `tier`.
3. O script aceita IDs fora do catálogo curado também (com aviso) — então pra teste rápido é só passar `--model <novo-id>` direto.

## Referências

- [`references/prompt-guide.md`](./references/prompt-guide.md) — boas práticas de prompt por modelo
- [muapi.ai docs](https://muapi.ai/docs) — referência da API
- [Open-Generative-AI](https://github.com/Anil-matcha/Open-Generative-AI) — UI open-source que usa essa mesma API
