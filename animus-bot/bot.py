#!/usr/bin/env python3
"""
Animus Telegram Bot - daemon Python para container Gradsky.

Invoca `claude -p` como subprocess para cada mensagem; sem sessao terminal persistente e sem arquivos manuais de resposta.
Todos os paths e branding vem do .env. Sem hardcode de pessoa/empresa.

Vars obrigatorias no .env (ver .env.example):
    AGENT_NAME, OWNER_NAME, OWNER_TELEGRAM_ID, TELEGRAM_BOT_TOKEN, ALLOWED_USERS
"""
import os, re, sys, json, time, logging, random, signal, subprocess, threading, shutil
from pathlib import Path
from datetime import datetime, timezone
import requests


def env_path(var, fallback):
    return Path(os.environ.get(var, fallback)).expanduser()


REPO_DIR = env_path('ANIMUS_REPO_DIR', Path(__file__).resolve().parent.parent)
BOT_DIR = env_path('ANIMUS_BOT_DIR', REPO_DIR / 'animus-bot')
ENV_FILE = env_path('ANIMUS_ENV_FILE', REPO_DIR / '.env')

INBOX = BOT_DIR / 'inbox'
SENT = BOT_DIR / 'sent'
STATE = BOT_DIR / 'state'
LOGS = BOT_DIR / 'logs'
SESSION_MARKER = STATE / 'claude-session-started.flag'


def load_env_file(path):
    data = {}
    if not path.exists():
        return data
    for line in path.read_text().splitlines():
        if '=' not in line or line.lstrip().startswith('#'):
            continue
        k, _, v = line.partition('=')
        v = v.split('#', 1)[0].strip().strip('"').strip("'")
        data[k.strip()] = v
    return data


env = load_env_file(ENV_FILE)


def cfg(key, default=None, required=False):
    val = env.get(key) or os.environ.get(key) or default
    if required and not val:
        sys.exit(f'{key} missing in {ENV_FILE}')
    return val


TOKEN = cfg('TELEGRAM_BOT_TOKEN', required=True)
ALLOWED_USERS = {u.strip() for u in cfg('ALLOWED_USERS', '').split(',') if u.strip()}
if not ALLOWED_USERS:
    sys.exit(f'ALLOWED_USERS missing in {ENV_FILE}')

AGENT_NAME = cfg('AGENT_NAME', 'Animus')
OWNER_NAME = cfg('OWNER_NAME', 'Chefe')
OWNER_TELEGRAM_ID = cfg('OWNER_TELEGRAM_ID', next(iter(ALLOWED_USERS)))
COMPANY_NAME = cfg('COMPANY_NAME', AGENT_NAME)
PRODUCT_NAME = cfg('PRODUCT_NAME', f'{AGENT_NAME} Premium')
CLAUDE_TIMEOUT = int(cfg('CLAUDE_TIMEOUT', '180'))
CLAUDE_BIN = cfg('CLAUDE_BIN') or shutil.which('claude') or '/root/.local/bin/claude'

API = f'https://api.telegram.org/bot{TOKEN}'

SYSTEM_OVERRIDE = f"""\
CONTEXTO REAL DESTE AMBIENTE (sobrescreve qualquer instrucao conflitante do CLAUDE.md):

- Voce roda em um container Gradsky persistente com PM2 e Claude Code.
- Nao existem aqui: banco local obrigatorio, sessao terminal persistente, paths absolutos legados ou porta 3007.
- Cada mensagem do Chefe chega como subprocess STDIN. Voce e invocada por um bot Python externo via `claude -p`.
- Sua resposta em STDOUT e o que vai pro Telegram. Responda em texto direto.
- Nao tente executar protocolo de boot que dependa de psql local, porta 3007 ou paths absolutos legados.
- Nao faca getUpdates do Telegram e nao acesse diretorios de outro bot. O bot externo ja faz isso.
- Trate {OWNER_NAME} (Telegram user_id {OWNER_TELEGRAM_ID}) como "Chefe".
- Empresa: {COMPANY_NAME}. Produto: {PRODUCT_NAME}.
- Mantenha sua personalidade {AGENT_NAME}: orquestradora, PT-BR, sem travessoes, direta.

PAPEL FIXO: VOCE E ORQUESTRADORA, NUNCA EXECUTORA (REGRA ABSOLUTA):
- Voce nao escreve codigo, nao faz design, nao testa, nao faz copy, nao faz infra, nao mexe em banco e nao faz analise pesada quando houver especialista disponivel.
- Voce sempre delega via Task tool pro subagente certo.
- Os subagentes estao em {REPO_DIR}/.claude/agents/. Use a Task tool com subagent_type igual ao nome: atlas, helena, aegis, titan, sentinel, victor, apollo, oracle, felipe, gaby.
- Mapping obrigatorio:
    codigo / backend / frontend / API / debug / arquitetura / refactor -> atlas
    UI / UX / HTML / CSS / design / landing / responsivo -> helena
    seguranca / OWASP / auth / hardening / threat model / secrets -> aegis
    DevOps / deploy / Docker / CI/CD / PM2 / proxy / SSL / logs -> titan
    Gradsky API / PAT / service / env vars / dominio customizado -> titan + felipe, usando a skill gradsky-paas
    QA / testes / validacao / regressao / edge cases -> sentinel
    copy / VSL / oferta / CTA / headline / script -> victor
    SDR / prospeccao / CRM / outreach / Instagram / WhatsApp -> apollo
    BI / analytics / metricas / mercado / estrategia / decisao -> oracle
    fullstack senior + Gradsky / produto / observabilidade -> felipe
    atendimento do jogo / chat do SaaS / PIX de usuario / bonus / saldo / Agent API -> gaby
- Exemplo: "faz uma calculadora HTML" = delega pra atlas (codigo) ou helena (UI). Nao faca direto.
- Tarefas paralelas: dispare multiplos Task na mesma resposta quando fizer sentido.
- Nao escreva "Delegando pro X" antes do Task. O bot avisa o Chefe automaticamente quando voce invoca um subagente.
- Suas respostas chegam no Telegram em tempo real. Prefira pedacos naturais em vez de bloco gigante no final.
- Depois que os subagentes retornarem, consolide e responda o Chefe.
- Excecao unica: pode responder direto sem delegar apenas em cumprimento, confirmacao curta, pergunta sobre status do time ou duvida factual simples.

ANIMUS ORCHESTRATION OS:
- Para pedido complexo, ambiguo, multidisciplinar, operacional, repetitivo ou com varios especialistas, use a skill `animus-orchestration-os` antes de delegar.
- Crie ou resuma um Work Object: objetivo, escopo, dono, agentes, criterios de aceite, gates, riscos e proximo passo.
- Separe contexto em camadas: estrategica, tatica e operacional.
- Envie breadcrumb context especifico para cada agente; nao mande o briefing inteiro para todos.
- Defina quality gates antes de declarar pronto.
- Entregue status, evidencias, riscos e proximos passos.

GRADSKY PAAS:
- Para deploys, services, env vars, dominios ou migracao de deploy antigo para Gradsky, use a skill `gradsky-paas`.
- O token vem de `GRADSKY_TOKEN`. Nunca imprima, copie, resuma ou registre esse token.
- Antes de criar service, liste services do projeto. Antes de parar service, deletar env ou remover dominio, confirme com o Chefe.
- Nao invente endpoints Gradsky fora da lista documentada em `skills/gradsky-paas/API_ROUTES.md`.

APRENDIZADO CONTINUO (skill self-improvement):
- Existe a pasta `{REPO_DIR}/.learnings/` com 3 arquivos: LEARNINGS.md, ERRORS.md, FEATURE_REQUESTS.md.
- Antes de responder a algo tecnico/complexo, faca um grep rapido nesses arquivos para ver se ja existe licao relevante.
- Depois que o Chefe te corrigir, um comando falhar de jeito nao-obvio, ou o Chefe pedir algo que voce nao soube fazer, registre 1 entrada curta no arquivo certo.
- Formato: `[ID-YYYYMMDD-NNN] <titulo>\\n<o que aconteceu>\\n<o que fazer diferente>\\n`.
- Nunca logue secrets, tokens, env vars, ou trechos brutos de arquivos sensiveis.
- Quando uma licao se repetir 3+ vezes, promova pro CLAUDE.md do repo como regra permanente.

ENVIO DE ARQUIVOS PELO TELEGRAM:
- Pra entregar um arquivo no chat, inclua na sua resposta uma linha com o marcador:
    [[SEND_FILE:/caminho/absoluto/arquivo.ext]]
  ou com legenda opcional:
    [[SEND_FILE:/caminho/absoluto/arquivo.ext|legenda curta aqui]]
- O bot remove o marcador do texto e envia o arquivo como anexo. Limite: 50MB por arquivo.

PROTOCOLO DE ENTREGA DE PROJETO:
- Sempre que terminar de construir um projeto multi-arquivo, pergunte ao Chefe como ele quer receber:
    1) ZIP no Telegram
    2) Repositorio no GitHub
- Nao assuma. Pergunta curta.

Quando o Chefe escolher ZIP:
- Zipe excluindo lixo: `cd <raiz> && zip -r /tmp/<nome>.zip . -x 'node_modules/*' '.git/*' 'dist/*' '.next/*' '__pycache__/*' '*.pyc' '.venv/*' 'venv/*' '.env'`
- Entregue com o marcador: `[[SEND_FILE:/tmp/<nome>.zip|<nome> sem deps]]`

Quando o Chefe escolher GitHub:
- Use `gh` se estiver autenticado.
- Comandos:
    cd <raiz do projeto>
    git init -q && git add -A && git commit -q -m "initial commit by {AGENT_NAME}"
    gh repo create <nome-do-projeto> --private --source=. --remote=origin --push
- Capture a URL com `gh repo view --json url -q .url` e responda no chat com o link.
- Se `gh auth status` falhar, avise: "GitHub nao autenticado. Rode `gh auth login` no terminal do container."
"""

for d in (INBOX, SENT, STATE, LOGS):
    d.mkdir(parents=True, exist_ok=True)

logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s %(levelname)s %(message)s',
    handlers=[logging.FileHandler(LOGS / 'bot.log'), logging.StreamHandler()]
)
log = logging.getLogger(f'{AGENT_NAME.lower()}-bot')

typing_until = {}
typing_lock = threading.Lock()
running = True


def signal_handler(sig, _):
    global running
    log.info(f'signal {sig} - parando')
    running = False


for s in (signal.SIGTERM, signal.SIGINT, signal.SIGHUP):
    signal.signal(s, signal_handler)


def get_offset():
    f = STATE / 'last-update-id.txt'
    return int(f.read_text().strip()) + 1 if f.exists() else 0


def save_offset(uid):
    (STATE / 'last-update-id.txt').write_text(str(uid))


def send_message(chat_id, text, reply_to=None):
    if len(text) > 4000:
        text = text[:3990] + '...'
    payload = {'chat_id': chat_id, 'text': text}
    if reply_to:
        payload['reply_parameters'] = {'message_id': int(reply_to)}
    try:
        r = requests.post(f'{API}/sendMessage', json=payload, timeout=15)
        if r.status_code == 200 and r.json().get('ok'):
            return True
        log.warning(f'sendMessage falhou: {r.status_code} {r.text[:200]}')
    except Exception as e:
        log.error(f'sendMessage exception: {e}')
    return False


IMMEDIATE_ACKS = [
    "Anotado, chefe. Chamando o time.",
    "Boa. Deixa comigo, vou distribuir.",
    "Pegou. Ja vou organizar o pessoal.",
    "Entendi. Montando a equipe agora.",
    "Recebido. Vou acionar os agentes certos.",
    "Tranquilo, chefe. Time entrando em acao.",
    "Saquei. Ja chamo o pessoal certo pra isso.",
]

AGENT_LABEL = {
    'atlas': 'Atlas (eng)',
    'helena': 'Helena (UI/UX)',
    'aegis': 'Aegis (security)',
    'titan': 'Titan (DevOps)',
    'sentinel': 'Sentinel (QA)',
    'victor': 'Victor (copy)',
    'apollo': 'Apollo (growth)',
    'oracle': 'Oracle (data)',
    'felipe': 'Felipe (fullstack)',
}

SEND_FILE_RE = re.compile(r'\[\[SEND_FILE:([^\]|\n]+?)(?:\|([^\]\n]*))?\]\]')


def extract_files(text):
    files = []

    def repl(m):
        path = m.group(1).strip()
        caption = (m.group(2) or '').strip() or None
        files.append((path, caption))
        return ''

    cleaned = SEND_FILE_RE.sub(repl, text)
    cleaned = re.sub(r'\n{3,}', '\n\n', cleaned).strip()
    return cleaned, files


def send_document(chat_id, file_path, caption=None, reply_to=None):
    try:
        p = Path(file_path)
        if not p.exists() or not p.is_file():
            log.warning(f'send_document: arquivo nao existe: {file_path}')
            return False
        if p.stat().st_size > 50 * 1024 * 1024:
            log.warning(f'send_document: arquivo > 50MB: {file_path}')
            return False
        data = {'chat_id': chat_id}
        if caption:
            data['caption'] = caption[:1024]
        if reply_to:
            data['reply_parameters'] = json.dumps({'message_id': int(reply_to)})
        with p.open('rb') as fh:
            r = requests.post(f'{API}/sendDocument', data=data,
                              files={'document': (p.name, fh)}, timeout=60)
        if r.status_code == 200 and r.json().get('ok'):
            log.info(f'sendDocument ok: {file_path}')
            return True
        log.warning(f'sendDocument falhou: {r.status_code} {r.text[:200]}')
    except Exception as e:
        log.error(f'sendDocument exception: {e}')
    return False


def react(chat_id, msg_id, emoji=None):
    if not emoji:
        return False
    try:
        requests.post(f'{API}/setMessageReaction', json={
            'chat_id': chat_id, 'message_id': msg_id,
            'reaction': [{'type': 'emoji', 'emoji': emoji}]
        }, timeout=5)
    except Exception:
        pass


def start_typing(chat_id, duration=300):
    with typing_lock:
        typing_until[int(chat_id)] = time.time() + duration


def stop_typing(chat_id):
    with typing_lock:
        typing_until.pop(int(chat_id), None)


def typing_loop():
    while running:
        try:
            now = time.time()
            with typing_lock:
                active = [c for c, u in typing_until.items() if u > now]
                for c in [c for c, u in typing_until.items() if u <= now]:
                    typing_until.pop(c, None)
            for cid in active:
                try:
                    requests.post(f'{API}/sendChatAction',
                                  json={'chat_id': cid, 'action': 'typing'},
                                  timeout=3)
                except Exception:
                    pass
        except Exception:
            pass
        time.sleep(4)


def emit_text(chat_id, text, reply_to=None):
    cleaned, files = extract_files(text)
    if cleaned:
        send_message(chat_id, cleaned, reply_to=reply_to)
    for fpath, cap in files:
        send_document(chat_id, fpath, caption=cap)
    return bool(cleaned or files)


def stream_agent(text, user_name, msg_id, chat_id):
    prompt = f'[telegram from {user_name} msg_id={msg_id}] {text}'
    cmd = [CLAUDE_BIN, '-p', '--output-format', 'stream-json', '--verbose',
           '--permission-mode', 'auto',
           '--append-system-prompt', SYSTEM_OVERRIDE]
    if SESSION_MARKER.exists():
        cmd.insert(2, '-c')

    send_message(chat_id, random.choice(IMMEDIATE_ACKS), reply_to=msg_id)

    emitted_any = False
    final_ok = False
    proc = None

    def watchdog():
        time.sleep(CLAUDE_TIMEOUT)
        if proc and proc.poll() is None:
            log.warning(f'watchdog kill msg_id={msg_id}')
            try:
                proc.kill()
            except Exception:
                pass

    try:
        proc = subprocess.Popen(
            cmd,
            stdin=subprocess.PIPE,
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE,
            cwd=str(REPO_DIR),
            text=True,
            bufsize=1,
        )
        threading.Thread(target=watchdog, daemon=True).start()
        proc.stdin.write(prompt)
        proc.stdin.close()

        for line in proc.stdout:
            line = line.strip()
            if not line:
                continue
            try:
                ev = json.loads(line)
            except json.JSONDecodeError:
                continue

            t = ev.get('type')
            if t == 'assistant':
                content = ev.get('message', {}).get('content', [])
                for block in content:
                    bt = block.get('type')
                    if bt == 'text':
                        txt = (block.get('text') or '').strip()
                        if txt and emit_text(chat_id, txt):
                            emitted_any = True
                    elif bt == 'tool_use' and block.get('name') == 'Task':
                        inp = block.get('input', {}) or {}
                        agent = inp.get('subagent_type', '?')
                        desc = (inp.get('description') or '').strip()
                        label = AGENT_LABEL.get(agent, agent)
                        msg = f'{label} entrou na jogada: {desc}' if desc else f'{label} entrou na jogada.'
                        send_message(chat_id, msg)
                        emitted_any = True
            elif t == 'result':
                if ev.get('subtype') == 'success' and not ev.get('is_error'):
                    final_ok = True
                    if not emitted_any:
                        final = (ev.get('result') or '').strip()
                        if final and emit_text(chat_id, final, reply_to=msg_id):
                            emitted_any = True
                else:
                    err = ev.get('error') or ev.get('result') or 'erro desconhecido'
                    send_message(chat_id, f'(erro interno: {str(err)[:200]})')

        try:
            proc.wait(timeout=10)
        except subprocess.TimeoutExpired:
            proc.kill()

        if proc.returncode != 0 and not final_ok:
            stderr_snip = (proc.stderr.read() if proc.stderr else '')[:300]
            log.error(f'claude rc={proc.returncode} stderr={stderr_snip}')
            if not emitted_any:
                send_message(chat_id, f'(erro interno do agente - rc={proc.returncode})', reply_to=msg_id)

        if final_ok:
            SESSION_MARKER.touch()
        elif not emitted_any:
            send_message(chat_id, f'(timeout - mais de {CLAUDE_TIMEOUT}s sem resposta final)', reply_to=msg_id)

        return final_ok

    except Exception as e:
        log.exception(f'stream_agent error: {e}')
        send_message(chat_id, f'(erro: {e})', reply_to=msg_id)
        return False


def handle_update(update):
    msg = update.get('message') or update.get('edited_message')
    if not msg:
        return
    user_id = str(msg.get('from', {}).get('id', ''))
    msg_id = msg.get('message_id')
    chat_id = msg.get('chat', {}).get('id')
    text = msg.get('text') or msg.get('caption') or '(non-text)'
    user_name = msg.get('from', {}).get('first_name', user_id)

    if user_id not in ALLOWED_USERS:
        log.info(f'drop user nao autorizado id={user_id} name={user_name}')
        return

    log.info(f'msg recebida msg_id={msg_id} from={user_name}: {text[:100]}')

    inbox_data = {
        'msg_id': msg_id, 'chat_id': chat_id, 'user_id': user_id,
        'user_name': user_name, 'text': text,
        'received_at': datetime.now(timezone.utc).isoformat(),
    }
    (INBOX / f'{msg_id}.json').write_text(json.dumps(inbox_data, indent=2, ensure_ascii=False))

    react(chat_id, msg_id)
    start_typing(chat_id, duration=CLAUDE_TIMEOUT + 30)

    sent_ok = stream_agent(text, user_name, msg_id, chat_id)
    stop_typing(chat_id)

    (SENT / f'{msg_id}.json').write_text(json.dumps({
        **inbox_data,
        'mode': 'stream',
        'sent_ok': sent_ok,
        'sent_at': datetime.now(timezone.utc).isoformat(),
    }, indent=2, ensure_ascii=False))


def poll_loop():
    log.info('polling loop iniciado')
    backoff = 1
    while running:
        try:
            offset = get_offset()
            r = requests.get(f'{API}/getUpdates',
                             params={'offset': offset, 'timeout': 30, 'limit': 100},
                             timeout=40)
            if r.status_code != 200:
                log.warning(f'http {r.status_code}: {r.text[:200]}')
                time.sleep(backoff)
                backoff = min(backoff * 2, 60)
                continue
            data = r.json()
            if not data.get('ok'):
                log.warning(f'!ok: {data}')
                time.sleep(backoff)
                backoff = min(backoff * 2, 60)
                continue
            backoff = 1
            for update in data.get('result', []):
                try:
                    handle_update(update)
                finally:
                    save_offset(update['update_id'])
        except requests.exceptions.Timeout:
            continue
        except Exception as e:
            log.error(f'poll error: {e}')
            time.sleep(backoff)
            backoff = min(backoff * 2, 60)


if __name__ == '__main__':
    log.info(f'=== {AGENT_NAME} Telegram Bot iniciando ===')
    log.info(f'REPO_DIR={REPO_DIR}  BOT_DIR={BOT_DIR}  ENV={ENV_FILE}')
    try:
        r = requests.get(f'{API}/getMe', timeout=10)
        info = r.json().get('result', {})
        log.info(f'bot conectado: @{info.get("username")} ({info.get("first_name")})')
        log.info(f'ALLOWED_USERS={ALLOWED_USERS}  OWNER={OWNER_NAME} (id={OWNER_TELEGRAM_ID})')
        log.info(f'CLAUDE_BIN={CLAUDE_BIN}  CLAUDE_TIMEOUT={CLAUDE_TIMEOUT}s')
    except Exception as e:
        log.error(f'getMe falhou: {e}')
        sys.exit(1)

    threading.Thread(target=typing_loop, daemon=True).start()
    try:
        poll_loop()
    except KeyboardInterrupt:
        pass
    log.info('=== bot encerrado ===')
