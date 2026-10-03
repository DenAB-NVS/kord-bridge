#!/data/data/com.termux/files/usr/bin/bash
# Временный localhost-туннель и копия сессии; только булевы ответы, без сообщений.
echo '=== 0035 ЧИТАЛКА ЧЕРЕЗ ТУННЕЛЬ ==='
META=$(ssh -o BatchMode=yes -o StrictHostKeyChecking=accept-new -o ConnectTimeout=15 root@45.152.198.192 'python3 - 2>/dev/null' <<'PY'
import sqlite3
from pathlib import Path
try:
    p = Path('/root/рассылка/sessions/acc1.session')
    c = sqlite3.connect('file:' + str(p) + '?mode=ro', uri=True)
    row = c.execute('select server_address, port from sessions limit 1').fetchone()
    c.close()
    if row: print(row[0], row[1])
except Exception: pass
PY
)
read -r HOST PORT <<< "$META"
case "$HOST:$PORT" in *[!0-9.:]*) echo 'DC_META_VALID no'; exit 0;; esac
if [ -z "$HOST" ] || [ -z "$PORT" ]; then echo 'DC_META_VALID no'; exit 0; fi
ssh -N -R "127.0.0.1:17443:$HOST:$PORT" -o BatchMode=yes -o ExitOnForwardFailure=yes -o StrictHostKeyChecking=accept-new -o ConnectTimeout=15 root@45.152.198.192 >/dev/null 2>&1 &
TUN_PID=$!
trap 'kill "$TUN_PID" 2>/dev/null; wait "$TUN_PID" 2>/dev/null' EXIT
sleep 4
if ! kill -0 "$TUN_PID" 2>/dev/null; then echo 'TUNNEL_STARTED no'; exit 0; fi
echo 'TUNNEL_STARTED yes'
ssh -o BatchMode=yes -o StrictHostKeyChecking=accept-new -o ConnectTimeout=15 root@45.152.198.192 'python3 - 2>/dev/null' <<'PY'
import asyncio, json, logging, sqlite3, tempfile
from pathlib import Path
from telethon import TelegramClient
logging.disable(logging.CRITICAL)
b = Path('/root/рассылка')
session = b / 'sessions' / 'acc1.session'
conf = None
for p in list(b.rglob('*.json'))[:100]:
    try:
        if p.stat().st_size > 500000: continue
        obj = json.loads(p.read_text())
        if isinstance(obj, dict) and str(obj.get('api_id', '')).isdigit() and isinstance(obj.get('api_hash'), str) and len(obj['api_hash']) >= 10:
            conf = obj
            break
    except (OSError, ValueError, UnicodeError): pass
if conf is None or not session.is_file():
    print('PREREQUISITES_FOUND no')
    raise SystemExit(0)
print('PREREQUISITES_FOUND yes')
try:
    with tempfile.TemporaryDirectory(prefix='.chitalka-proba-', dir=b) as td:
        copy = Path(td) / 'acc1.session'
        src = sqlite3.connect('file:' + str(session) + '?mode=ro', uri=True)
        dst = sqlite3.connect(str(copy))
        try: src.backup(dst)
        finally: dst.close(); src.close()
        db = sqlite3.connect(str(copy))
        try:
            db.execute('update sessions set server_address=?, port=?', ('127.0.0.1', 17443))
            db.commit()
        finally: db.close()
        async def probe():
            client = TelegramClient(str(Path(td) / 'acc1'), int(conf['api_id']), conf['api_hash'], receive_updates=False, request_retries=1, connection_retries=1, timeout=10)
            try:
                await asyncio.wait_for(client.connect(), 25)
                print('CLIENT_CONNECTED yes')
                authorized = await asyncio.wait_for(client.is_user_authorized(), 25)
                print('ACC1_AUTHORIZED', 'yes' if authorized else 'no')
                if not authorized: return
                try:
                    entity = await asyncio.wait_for(client.get_entity('AI_NewsDailyTrends'), 25)
                    print('CHANNEL_RESOLVED yes')
                except Exception as exc:
                    print('CHANNEL_RESOLVED no', type(exc).__name__)
                    return
                messages = await asyncio.wait_for(client.get_messages(entity, limit=1), 25)
                print('AT_LEAST_ONE_MESSAGE', 'yes' if messages else 'no')
            finally: await client.disconnect()
        asyncio.run(probe())
except Exception as exc:
    print('PROBE_ERROR', type(exc).__name__)
PY
echo 'TUNNEL_WILL_CLOSE yes'
echo '=== КОНЕЦ 0035 ==='
