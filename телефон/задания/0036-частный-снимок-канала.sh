#!/data/data/com.termux/files/usr/bin/bash
# В публичное эхо выводятся только дата, число сообщений, статус; тексты сохраняются только на сервере.
echo '=== 0036 ЧАСТНЫЙ СНИМОК КАНАЛА ==='
META=$(ssh -o BatchMode=yes -o StrictHostKeyChecking=accept-new -o ConnectTimeout=15 root@45.152.198.192 'python3 - 2>/dev/null' <<'PY'
import sqlite3
from pathlib import Path
try:
    p=Path('/root/рассылка/sessions/acc1.session')
    c=sqlite3.connect('file:'+str(p)+'?mode=ro',uri=True)
    row=c.execute('select server_address,port from sessions limit 1').fetchone()
    c.close()
    if row: print(row[0],row[1])
except Exception: pass
PY
)
read -r HOST PORT <<< "$META"
case "$HOST:$PORT" in *[!0-9.:]*) echo 'DC_META_VALID no'; exit 0;; esac
if [ -z "$HOST" ] || [ -z "$PORT" ]; then echo 'DC_META_VALID no'; exit 0; fi
ssh -N -R "127.0.0.1:17443:$HOST:$PORT" -o BatchMode=yes -o ExitOnForwardFailure=yes -o ServerAliveInterval=15 -o StrictHostKeyChecking=accept-new -o ConnectTimeout=15 root@45.152.198.192 >/dev/null 2>&1 &
TUN_PID=$!
trap 'kill "$TUN_PID" 2>/dev/null; wait "$TUN_PID" 2>/dev/null' EXIT
sleep 4
if ! kill -0 "$TUN_PID" 2>/dev/null; then echo 'TUNNEL_STARTED no'; exit 0; fi
echo 'TUNNEL_STARTED yes'
ssh -o BatchMode=yes -o StrictHostKeyChecking=accept-new -o ConnectTimeout=15 root@45.152.198.192 'python3 - 2>/dev/null' <<'PY'
import asyncio, json, logging, os, sqlite3, tempfile
from pathlib import Path
from datetime import datetime, timedelta, time, timezone
from zoneinfo import ZoneInfo
from telethon import TelegramClient
logging.disable(logging.CRITICAL)
b=Path('/root/рассылка')
source=b/'sessions'/'acc1.session'
zone=ZoneInfo('Europe/Moscow')
day=datetime.now(zone).date()-timedelta(days=1)
start=datetime.combine(day,time.min,tzinfo=zone).astimezone(timezone.utc)
end=datetime.combine(day+timedelta(days=1),time.min,tzinfo=zone).astimezone(timezone.utc)
outdir=b/'приватная-газета'
target=outdir/(day.isoformat()+'.json')
print('DAY_MSK',day.isoformat())
if target.exists(): print('SNAPSHOT_ALREADY_EXISTS yes'); raise SystemExit(0)
conf=None
for p in list(b.rglob('*.json'))[:100]:
    try:
        if p.stat().st_size>500000: continue
        obj=json.loads(p.read_text())
        if isinstance(obj,dict) and str(obj.get('api_id','')).isdigit() and isinstance(obj.get('api_hash'),str) and len(obj['api_hash'])>=10:
            conf=obj;break
    except (OSError,ValueError,UnicodeError): pass
if conf is None or not source.is_file(): print('PREREQUISITES_FOUND no'); raise SystemExit(0)
try:
    with tempfile.TemporaryDirectory(prefix='.chitalka-',dir=b) as td:
        copy=Path(td)/'acc1.session'
        src=sqlite3.connect('file:'+str(source)+'?mode=ro',uri=True)
        dst=sqlite3.connect(str(copy))
        try: src.backup(dst)
        finally: dst.close();src.close()
        db=sqlite3.connect(str(copy))
        try:
            db.execute('update sessions set server_address=?,port=?',('127.0.0.1',17443));db.commit()
        finally: db.close()
        async def read_day():
            client=TelegramClient(str(Path(td)/'acc1'),int(conf['api_id']),conf['api_hash'],receive_updates=False,request_retries=1,connection_retries=1,timeout=10)
            try:
                await asyncio.wait_for(client.connect(),25)
                if not await asyncio.wait_for(client.is_user_authorized(),25):
                    print('AUTHORIZED no');return
                entity=await asyncio.wait_for(client.get_entity('AI_NewsDailyTrends'),25)
                rows=[];limit=501
                async for msg in client.iter_messages(entity,offset_date=end,limit=limit):
                    if msg.date<start:break
                    if start<=msg.date<end:
                        rows.append({'id':msg.id,'date_utc':msg.date.isoformat(),'text':msg.raw_text or ''})
                print('MESSAGES_CAPTURED',len(rows))
                print('LIMIT_REACHED','yes' if len(rows)>=limit else 'no')
                outdir.mkdir(mode=0o700,parents=True,exist_ok=True)
                os.chmod(outdir,0o700)
                fd,tmp=tempfile.mkstemp(prefix='.snapshot-',dir=outdir)
                try:
                    with os.fdopen(fd,'w',encoding='utf-8') as f:
                        json.dump({'day_msk':day.isoformat(),'source':'AI_NewsDailyTrends','messages':rows},f,ensure_ascii=False,indent=2)
                    os.chmod(tmp,0o600)
                    if target.exists(): os.unlink(tmp);print('SNAPSHOT_ALREADY_EXISTS yes');return
                    os.replace(tmp,target)
                    print('PRIVATE_SNAPSHOT_WRITTEN yes')
                finally:
                    if os.path.exists(tmp):os.unlink(tmp)
            finally:await client.disconnect()
        asyncio.run(read_day())
except Exception as exc:
    print('SNAPSHOT_ERROR',type(exc).__name__)
PY
echo 'TUNNEL_WILL_CLOSE yes'
echo '=== КОНЕЦ 0036 ==='
