#!/data/data/com.termux/files/usr/bin/bash
# 1125 — сбор живого топлива для движка: 9 болевых чатов, 14 дней (336 ч),
# формат поток.jsonl (chat / ts unix / text / forward_from), пуш в приватный дом.
# Механизм — как у read-one-r1110: конфиг + рабочая копия acc1.session + 127.0.0.1:17443.
# Секреты (api_id/api_hash/сессия) остаются на сервере, в мост и эхо не попадают.
echo "== 1125: сбор топлива =="
ssh -o BatchMode=yes -o StrictHostKeyChecking=accept-new -o ConnectTimeout=30 root@45.152.198.192 'bash -s' <<'REMOTE'
cat > /root/kord-glubina/sbor-topliva.py <<'PYEOF'
import asyncio, json, sqlite3, shutil, os
from telethon import TelegramClient
from datetime import datetime, timedelta, timezone
cfg = json.load(open('/root/рассылка/конфиг.json', encoding='utf-8'))
API_ID, API_HASH = int(cfg['api_id']), cfg['api_hash']
BASE = '/root/kord-linza'
WORK = os.path.join(BASE, 'стек', '.work-toplivo')
os.makedirs(WORK, exist_ok=True)
shutil.copyfile('/root/рассылка/sessions/acc1.session', os.path.join(WORK, 'acc1.session'))
db = sqlite3.connect(os.path.join(WORK, 'acc1.session'))
db.execute('update sessions set server_address=?, port=?', ('127.0.0.1', 17443))
db.commit(); db.close()
CHATS = ['credity_zalogy','zalogzaym','avtozalogrf','brok-credit','realestate-invest','jir-chat','p2p777kar','ipotekagroup','it_ipoteca_chat']
HOURS = 336
LIMIT = 20000
OUTDIR = '/root/kord-glubina/kordinaps-machine/Hermes/топливо'
OUT = os.path.join(OUTDIR, 'поток.jsonl')
os.makedirs(OUTDIR, exist_ok=True)
async def main():
    client = TelegramClient(os.path.join(WORK,'acc1'), API_ID, API_HASH, receive_updates=False, request_retries=1, connection_retries=1, timeout=25)
    await asyncio.wait_for(client.connect(), 35)
    if not await client.is_user_authorized():
        print('acc1 НЕ авторизован'); await client.disconnect(); return
    since = datetime.now(timezone.utc) - timedelta(hours=HOURS)
    total = 0
    with open(OUT, 'w', encoding='utf-8') as fh:
        for ch in CHATS:
            try:
                ent = await client.get_entity(ch)
                name = getattr(ent,'username',None) or getattr(ent,'title',None) or str(getattr(ent,'id',ch))
            except Exception as e:
                print('ЧАТ НЕ НАЙДЕН:', ch, repr(e)[:100]); continue
            n = 0
            try:
                async for m in client.iter_messages(ent, offset_date=since, reverse=True, limit=LIMIT):
                    if m is None or m.date is None: continue
                    text = (getattr(m,'text','') or '').strip()
                    if not text: continue
                    rec = {'chat': name, 'ts': int(m.date.replace(tzinfo=timezone.utc).timestamp()), 'text': text}
                    fwd = getattr(m,'forward',None)
                    if fwd is not None:
                        src = getattr(fwd,'chat',None) or getattr(fwd,'sender',None)
                        if src is not None:
                            rec['forward_from'] = getattr(src,'username',None) or getattr(src,'title',None) or str(getattr(src,'id','?'))
                    fh.write(json.dumps(rec, ensure_ascii=False) + '\n')
                    n += 1
            except Exception as e:
                print('ОШИБКА ЧАТА:', ch, repr(e)[:100])
            total += n
            print('чат', ch, '→', n, 'сообщений')
    await client.disconnect()
    print('ИТОГО:', total)
asyncio.run(main())
shutil.rmtree(WORK, ignore_errors=True)
print('конец сбора')
PYEOF
echo "--- git pull дома ---"
cd /root/kord-glubina/kordinaps-machine || exit 1
git pull -q origin main 2>&1 | tail -1 || true
echo "--- сбор (до 10 минут, молчание руки в это время — норма) ---"
timeout 900 /root/kord-linza/venv/bin/python /root/kord-glubina/sbor-topliva.py 2>&1 | tail -25
D="Hermes/топливо/поток.jsonl"
echo "--- контроль файла ---"
wc -l "$D"
ls -la Hermes/топливо/ 2>&1 | tail -2
head -2 "$D"
echo '...'
tail -2 "$D"
echo "--- пуш в дом ---"
git add "$D"
git commit -q -m "Топливо: поток.jsonl — 9 болевых чатов, 14 дней живой истории (09.11, ночь)" 2>&1 | tail -1
git push -q origin HEAD:main 2>&1 | tail -1
echo "пуш выполнен"
REMOTE
echo "== 1125: конец =="
