#!/data/data/com.termux/files/usr/bin/bash
# 1138 — словарь тем из «Звонка»: CSV был загружен в 07:35 как
# poisk_chatov_18_tem(1).csv, но выпал из окна 50 сообщений ленты.
# Ищем среди ВСЕХ документов канала (серверный фильтр документов),
# не по позиции в ленте; подстраховка — серверный поиск по именам.
# Найдём — сразу полный прогон: словарь в дом, selftest 09, тест 18 тем.
echo "== 1138: словарь тем — поиск среди документов Звонка =="
ssh -o BatchMode=yes -o StrictHostKeyChecking=accept-new -o ConnectTimeout=30 -o ServerAliveInterval=20 root@45.152.198.192 'bash -s' <<'REMOTE'
cat > /root/kord-glubina/slovar-iz-zvonka3.py <<'PYEOF'
import asyncio, json, sqlite3, shutil, os, sys
from telethon import TelegramClient
from telethon.tl.types import PeerChannel, InputMessagesFilterDocument
cfg = json.load(open('/root/рассылка/конфиг.json', encoding='utf-8'))
API_ID, API_HASH = int(cfg['api_id']), cfg['api_hash']
BASE = '/root/kord-linza'
WORK = os.path.join(BASE, 'стек', '.work-slovar')
os.makedirs(WORK, exist_ok=True)
shutil.copyfile('/root/рассылка/sessions/acc1.session', os.path.join(WORK, 'acc1.session'))
db = sqlite3.connect(os.path.join(WORK, 'acc1.session'))
db.execute('update sessions set server_address=?, port=?', ('127.0.0.1', 17443))
db.commit(); db.close()
GROUP = PeerChannel(4473651001)
DEST = '/root/poisk_chatov_18_tem.csv'
async def main():
    client = TelegramClient(os.path.join(WORK,'acc1'), API_ID, API_HASH, receive_updates=False, request_retries=1, connection_retries=1, timeout=25)
    await asyncio.wait_for(client.connect(), 35)
    if not await client.is_user_authorized():
        print('acc1 НЕ авторизован'); await client.disconnect(); return 2
    ent = await client.get_entity(GROUP)
    print('группа найдена:', getattr(ent,'title','?'))
    found = False
    print('--- документы канала (новые сверху) ---')
    async for m in client.iter_messages(ent, limit=100, filter=InputMessagesFilterDocument()):
        doc = getattr(m, 'document', None)
        if not doc: continue
        name = (getattr(doc, 'name', '') or '')
        size = getattr(doc, 'size', 0) or 0
        when = m.date.strftime('%d.%m %H:%M') if m.date else '?'
        print('ДОК:', when, '|', name or '(без имени)', '|', size, 'байт')
        if (not found) and name.lower().endswith('.csv'):
            await client.download_media(m, file=DEST)
            print('СКАЧАН:', name, os.path.getsize(DEST), 'байт')
            found = True
    if not found:
        print('--- фильтр не дал CSV, пробуем серверный поиск ---')
        for q in ('poisk', 'csv'):
            async for m in client.iter_messages(ent, limit=30, search=q):
                doc = getattr(m, 'document', None)
                if not doc: continue
                name = (getattr(doc, 'name', '') or '')
                print('ПОИСК', q, '→', name)
                if name.lower().endswith('.csv'):
                    await client.download_media(m, file=DEST)
                    print('СКАЧАН:', name, os.path.getsize(DEST), 'байт')
                    found = True
                    break
            if found: break
    if not found:
        print('CSV СРЕДИ ДОКУМЕНТОВ КАНАЛА НЕТ')
    await client.disconnect()
    return 0 if found else 2
rc = asyncio.run(main())
shutil.rmtree(WORK, ignore_errors=True)
sys.exit(rc or 0)
PYEOF
echo "--- поиск и скачивание (до 4 минут; молчание руки — норма) ---"
timeout 240 /root/kord-linza/venv/bin/python /root/kord-glubina/slovar-iz-zvonka3.py 2>&1
[ -s /root/poisk_chatov_18_tem.csv ] || { echo "СЛОВАРЬ НЕ СКАЧАН — стоп"; exit 1; }
echo "--- словарь на сервере ---"
wc -c /root/poisk_chatov_18_tem.csv

cd /root/kord-glubina/kordinaps-machine || exit 1
echo "--- git pull (подтянуть 09-тест-словаря-тем) ---"
git pull -q origin main 2>&1 | tail -1

echo "--- словарь в проекты/ дома ---"
cp /root/poisk_chatov_18_tem.csv проекты/poisk_chatov_18_tem.csv
wc -c проекты/poisk_chatov_18_tem.csv
git add -f "проекты/poisk_chatov_18_tem.csv"
git commit -q -m "словарь тем: poisk_chatov_18_tem.csv — 3258 фраз, 18 тем (09.11, решение владельца)" 2>&1 | tail -1
git push -q origin HEAD:main 2>&1 | tail -1
echo "словарь в доме"

cd Hermes/движок || exit 1
PY=/root/kord-dvizhok-venv/bin/python
echo "--- selftest 09 (pymorphy3, ё→е) ---"
timeout 300 $PY 09-тест-словаря-тем.py --selftest 2>&1 | tail -10
echo "--- тест словаря тем на живом потоке (3893 сообщения) ---"
timeout 900 $PY -u 09-тест-словаря-тем.py --поток ../топливо/поток.jsonl --словарь /root/poisk_chatov_18_tem.csv --выборка 30 2>&1
echo "--- тест завершён: is_causal=false — качество топлива, не вердикт ---"
REMOTE
echo "== 1138: конец =="
