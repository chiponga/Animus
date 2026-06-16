#!/usr/bin/env python3
"""
generate.py — CLI Muapi.ai pra skill visual-gen do Animus.

Uso típico:
    python3 generate.py --model flux-dev --prompt "..." --output /tmp/out.png
    python3 generate.py --model nano-banana --prompt "muda roupa pra terno preto" \\
                        --image-url https://... --output /tmp/edit.png
    python3 generate.py --model kling-v2.6-pro-t2v --prompt "..." --output /tmp/clip.mp4

Variáveis de ambiente:
    MUAPI_API_KEY   (obrigatório)  — pegue em muapi.ai
    MUAPI_BASE_URL  (opcional)     — default https://api.muapi.ai
    MUAPI_TIMEOUT   (opcional, s)  — default 300 (5 min)

Saída: imprime o path do arquivo baixado no stdout em caso de sucesso.
Falha: exit code != 0, mensagem no stderr.
"""
import argparse
import json
import os
import sys
import time
from pathlib import Path
from urllib.parse import urlparse

import requests

DEFAULT_BASE = os.environ.get("MUAPI_BASE_URL", "https://api.muapi.ai")
DEFAULT_TIMEOUT = int(os.environ.get("MUAPI_TIMEOUT", "300"))
POLL_INTERVAL = 3  # segundos
SKILL_DIR = Path(__file__).resolve().parent.parent
MODELS_FILE = SKILL_DIR / "scripts" / "models.json"


def die(msg, code=1):
    print(f"[visual-gen] ERRO: {msg}", file=sys.stderr)
    sys.exit(code)


def load_models():
    if not MODELS_FILE.exists():
        die(f"catálogo não encontrado em {MODELS_FILE}")
    return json.loads(MODELS_FILE.read_text()).get("models", {})


def load_env_file(path):
    """Lê .env simples (KEY=VALUE), retorna dict."""
    data = {}
    p = Path(path)
    if not p.exists():
        return data
    for line in p.read_text().splitlines():
        if "=" not in line or line.lstrip().startswith("#"):
            continue
        k, _, v = line.partition("=")
        v = v.split("#", 1)[0].strip().strip('"').strip("'")
        data[k.strip()] = v
    return data


def get_api_key():
    """Preferência: env var → .env do repo → erro."""
    key = os.environ.get("MUAPI_API_KEY")
    if key:
        return key
    repo_env = Path(__file__).resolve().parents[3] / ".env"
    parsed = load_env_file(repo_env)
    key = parsed.get("MUAPI_API_KEY")
    if not key:
        die(
            "MUAPI_API_KEY não definida. Pegue em muapi.ai e adicione ao "
            "/workspace/Animus/.env (linha: MUAPI_API_KEY=...)"
        )
    return key


def submit(base_url, endpoint, payload, api_key):
    """Submete o job. Retorna request_id ou resultado direto se síncrono."""
    url = f"{base_url}/api/v1/{endpoint}"
    try:
        r = requests.post(
            url,
            headers={"Content-Type": "application/json", "x-api-key": api_key},
            json=payload,
            timeout=30,
        )
    except requests.exceptions.RequestException as e:
        die(f"falha de rede no submit: {e}")
    if r.status_code != 200:
        die(f"submit falhou: HTTP {r.status_code} — {r.text[:300]}")
    data = r.json()
    return data


def poll(base_url, request_id, api_key, timeout):
    """Polling até o job estar pronto. Retorna dict do resultado."""
    url = f"{base_url}/api/v1/predictions/{request_id}/result"
    deadline = time.time() + timeout
    last_status = None
    while time.time() < deadline:
        try:
            r = requests.get(url, headers={"x-api-key": api_key}, timeout=15)
        except requests.exceptions.RequestException as e:
            print(f"[visual-gen] poll exception: {e}, retry em {POLL_INTERVAL}s", file=sys.stderr)
            time.sleep(POLL_INTERVAL)
            continue
        if r.status_code != 200:
            print(f"[visual-gen] poll HTTP {r.status_code}: {r.text[:200]}", file=sys.stderr)
            time.sleep(POLL_INTERVAL)
            continue
        data = r.json()
        status = data.get("status") or data.get("state")
        if status != last_status:
            print(f"[visual-gen] status: {status}", file=sys.stderr)
            last_status = status
        if status in ("completed", "succeeded", "success"):
            return data
        if status in ("failed", "error", "cancelled"):
            die(f"job falhou no servidor: {json.dumps(data)[:400]}")
        time.sleep(POLL_INTERVAL)
    die(f"timeout após {timeout}s aguardando resultado")


def extract_output_url(result):
    """Encontra a URL do arquivo gerado no payload do Muapi.
    A API retorna formatos variados; tentamos os mais comuns."""
    candidates = []
    for key in ("output", "outputs", "result", "results", "images", "videos", "output_url", "video_url", "image_url", "url"):
        v = result.get(key)
        if isinstance(v, str) and v.startswith("http"):
            candidates.append(v)
        elif isinstance(v, list):
            for item in v:
                if isinstance(item, str) and item.startswith("http"):
                    candidates.append(item)
                elif isinstance(item, dict):
                    for sub in ("url", "image", "video"):
                        sv = item.get(sub)
                        if isinstance(sv, str) and sv.startswith("http"):
                            candidates.append(sv)
        elif isinstance(v, dict):
            for sub in ("url", "image", "video"):
                sv = v.get(sub)
                if isinstance(sv, str) and sv.startswith("http"):
                    candidates.append(sv)
    if not candidates:
        die(f"não consegui extrair URL do resultado. Payload: {json.dumps(result)[:400]}")
    return candidates[0]


def download(url, output_path):
    print(f"[visual-gen] baixando {url} → {output_path}", file=sys.stderr)
    r = requests.get(url, stream=True, timeout=120)
    if r.status_code != 200:
        die(f"download falhou: HTTP {r.status_code}")
    output_path.parent.mkdir(parents=True, exist_ok=True)
    with output_path.open("wb") as f:
        for chunk in r.iter_content(chunk_size=64 * 1024):
            if chunk:
                f.write(chunk)
    return output_path


def infer_extension(url, kind):
    ext = Path(urlparse(url).path).suffix.lower()
    if ext in (".png", ".jpg", ".jpeg", ".webp", ".mp4", ".mov", ".webm"):
        return ext
    return ".mp4" if kind in ("t2v", "i2v", "v2v") else ".png"


def parse_args():
    p = argparse.ArgumentParser(description="CLI Muapi.ai para skill visual-gen.")
    p.add_argument("--model", required=True, help="ID do modelo (ex: flux-dev, kling-v2.6-pro-t2v)")
    p.add_argument("--prompt", required=True, help="Texto descrevendo a geração")
    p.add_argument("--output", help="Path de saída (default: /tmp/visual-gen/<model>-<timestamp>.<ext>)")
    p.add_argument("--aspect-ratio", help="Aspect ratio (16:9, 9:16, 1:1, etc.)")
    p.add_argument("--width", type=int, help="Largura (modelos que usam width/height)")
    p.add_argument("--height", type=int, help="Altura (modelos que usam width/height)")
    p.add_argument("--image-url", help="URL de imagem de entrada (I2I, I2V)")
    p.add_argument("--strength", type=float, help="Força da edição (0.0-1.0, I2I)")
    p.add_argument("--seed", type=int, help="Seed pra reproducibilidade")
    p.add_argument("--duration", type=int, help="Duração em segundos (vídeo)")
    p.add_argument("--num-images", type=int, help="Quantidade de imagens (modelos compatíveis)")
    p.add_argument("--extra", help="JSON com params adicionais que não estão nos flags acima")
    p.add_argument("--timeout", type=int, default=DEFAULT_TIMEOUT, help="Timeout total em segundos")
    p.add_argument("--dry-run", action="store_true", help="Valida payload sem enviar")
    return p.parse_args()


def build_payload(args, model_info):
    payload = {"prompt": args.prompt}
    if args.aspect_ratio:
        payload["aspect_ratio"] = args.aspect_ratio
    if args.width:
        payload["width"] = args.width
    if args.height:
        payload["height"] = args.height
    if args.image_url:
        image_field = model_info.get("image_field", "image_url")
        if model_info.get("image_field_is_array"):
            payload[image_field] = [args.image_url]
        else:
            payload[image_field] = args.image_url
        if args.strength is not None and not model_info.get("image_field_is_array"):
            payload["strength"] = args.strength
    if args.seed and args.seed != -1:
        payload["seed"] = args.seed
    if args.duration:
        payload["duration"] = args.duration
    if args.num_images:
        payload["num_images"] = args.num_images
    if args.extra:
        try:
            extra = json.loads(args.extra)
        except json.JSONDecodeError as e:
            die(f"--extra não é JSON válido: {e}")
        if not isinstance(extra, dict):
            die("--extra precisa ser um objeto JSON")
        payload.update(extra)
    return payload


def main():
    args = parse_args()
    models = load_models()
    if args.model not in models:
        print(
            f"[visual-gen] aviso: '{args.model}' não está no catálogo curado "
            f"(skills/visual-gen/scripts/models.json). Vou tentar mesmo assim — "
            f"se for ID válido no Muapi, funciona.",
            file=sys.stderr,
        )
    model_info = models.get(args.model, {})
    kind = model_info.get("kind", "t2i")
    endpoint = model_info.get("endpoint", args.model)

    payload = build_payload(args, model_info)

    if args.dry_run:
        print(json.dumps({"model": args.model, "endpoint": endpoint, "payload": payload}, indent=2))
        return 0

    api_key = get_api_key()
    print(f"[visual-gen] submit model={args.model} endpoint={endpoint} kind={kind}", file=sys.stderr)
    submit_resp = submit(DEFAULT_BASE, endpoint, payload, api_key)

    # Alguns endpoints retornam resultado direto, outros retornam request_id pra polling
    request_id = submit_resp.get("request_id") or submit_resp.get("id")
    if request_id:
        result = poll(DEFAULT_BASE, request_id, api_key, args.timeout)
    else:
        # resposta síncrona
        result = submit_resp

    url = extract_output_url(result)
    if args.output:
        output_path = Path(args.output)
    else:
        ts = int(time.time())
        ext = infer_extension(url, kind)
        output_path = Path(f"/tmp/visual-gen/{args.model}-{ts}{ext}")

    download(url, output_path)
    print(str(output_path))
    return 0


if __name__ == "__main__":
    sys.exit(main())
