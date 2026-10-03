#!/data/data/com.termux/files/usr/bin/bash
# Проба чтения на копии сессии; без сообщений, ключей и отправок.
echo '=== 0031 ПРОБА ЧТЕНИЯ КАНАЛА ==='
ssh -o BatchMode=yes -o StrictHostKeyChecking=accept-new -o ConnectTimeout=15 root@45.152.198.192 'python3 - 2>/dev/null' <<'PY'
import asyncio, json, logging, sqlite3, tempfile
from pathlib import Path
from telethon import TelegramClient
logging.disable(logging.CRITICAL)
b = Path('/root/рассылка')
session = b / 'sessions' / 'acc1.session'
if not session.is_file():
    print('ACC1_SESSION_FOUND False')
    raise SystemExit(0)
print('ACC1_SESSION_FOUND True')
conf = None
for p in list(b.rglob('*.json'))[:100]:
    try:
        if p.stat().st_size > 500000: continue
        obj = json.loads(p.read_text())
        if isinstance(obj, dict) and str(obj.get('api_id', '')).isdigit() and isinstance(obj.get('api_hash'), str) and len(obj['api_hash']) >= 10:
            conf = obj
            break
    except (OSError, ValueError, UnicodeError):
        pass
if conf is None:
    print('API_CONFIG_FOUND False')
    raise SystemExit(0)
print('API_CONFIG_FOUND True')
try:
    with tempfile.TemporaryDirectory(prefix='.chitalka-proba-', dir=b) as td:
        copy = Path(td) / 'acc1.session'
        src = sqlite3.connect('file:' + str(session) + '?mode=ro', uri=True)
        dst = sqlite3.connect(str(copy))
        try: src.backup(dst)
        finally: dst.close(); src.close()
        async def probe():
            client = TelegramClient(str(Path(td) / 'acc1'), int(conf['api_id']), conf['api_hash'], receive_updates=False, request_retries=1, connection_retries=1, timeout=10)
            try:
                await asyncio.wait_for(client.connect(), 25)
                authorized = await asyncio.wait_for(client.is_user_authorized(), 25)
                print('ACC1_AUTHORIZED', bool(authorized))
                if not authorized: return
                try:
                    entity = await asyncio.wait_for(client.get_entity('AI_NewsDailyTrends'), 25)
                    print('CHANNEL_ACCESSIBLE True')
                except Exception as exc:
                    print('CHANNEL_ACCESSIBLE False', type(exc).__name__)
                    return
                messages = await asyncio.wait_for(client.get_messages(entity, limit=1), 25)
                print('AT_LEAST_ONE_MESSAGE', bool(messages))
            finally:
                await client.disconnect()
        asyncio.run(probe())
except Exception as exc:
    print('PROBE_ERROR', type(exc).__name__)
PY
echo '=== КОНЕЦ 0031 ==='
