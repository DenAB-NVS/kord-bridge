#!/data/data/com.termux/files/usr/bin/bash
# Публичное эхо: только дата последнего поста, без текста и ссылок.
echo '=== 0037 ДАТА ПОСЛЕДНЕГО ПОСТА ==='
META=$(ssh -o BatchMode=yes -o StrictHostKeyChecking=accept-new -o ConnectTimeout=15 root@45.152.198.192 'python3 - 2>/dev/null' <<'PY'
import sqlite3
from pathlib import Path
try:
 p=Path('/root/рассылка/sessions/acc1.session')
 c=sqlite3.connect('file:'+str(p)+'?mode=ro',uri=True)
 row=c.execute('select server_address,port from sessions limit 1').fetchone();c.close()
 if row:print(row[0],row[1])
except Exception:pass
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
ssh -o BatchMode=yes -o StrictHostKeyChecking=accept-new -o ConnectTimeout=15 root@45.152.198.192 'python3 - 2>/dev/null' <<'PY'
import asyncio,json,logging,sqlite3,tempfile
from pathlib import Path
from zoneinfo import ZoneInfo
from telethon import TelegramClient
logging.disable(logging.CRITICAL)
b=Path('/root/рассылка');source=b/'sessions'/'acc1.session';conf=None
for p in list(b.rglob('*.json'))[:100]:
 try:
  if p.stat().st_size>500000:continue
  o=json.loads(p.read_text())
  if isinstance(o,dict) and str(o.get('api_id','')).isdigit() and isinstance(o.get('api_hash'),str) and len(o['api_hash'])>=10:conf=o;break
 except (OSError,ValueError,UnicodeError):pass
if not conf:print('CONFIG_FOUND no');raise SystemExit(0)
try:
 with tempfile.TemporaryDirectory(prefix='.chitalka-',dir=b) as td:
  copy=Path(td)/'acc1.session';src=sqlite3.connect('file:'+str(source)+'?mode=ro',uri=True);dst=sqlite3.connect(str(copy))
  try:src.backup(dst)
  finally:dst.close();src.close()
  db=sqlite3.connect(str(copy))
  try:db.execute('update sessions set server_address=?,port=?',('127.0.0.1',17443));db.commit()
  finally:db.close()
  async def probe():
   c=TelegramClient(str(Path(td)/'acc1'),int(conf['api_id']),conf['api_hash'],receive_updates=False,request_retries=1,connection_retries=1,timeout=10)
   try:
    await asyncio.wait_for(c.connect(),25)
    entity=await asyncio.wait_for(c.get_entity('AI_NewsDailyTrends'),25)
    msgs=await asyncio.wait_for(c.get_messages(entity,limit=1),25)
    print('LAST_POST_DAY_MSK',msgs[0].date.astimezone(ZoneInfo('Europe/Moscow')).date().isoformat() if msgs else 'none')
   finally:await c.disconnect()
  asyncio.run(probe())
except Exception as e:print('PROBE_ERROR',type(e).__name__)
PY
echo '=== КОНЕЦ 0037 ==='
