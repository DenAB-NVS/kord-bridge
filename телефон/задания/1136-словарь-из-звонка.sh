#!/data/data/com.termux/files/usr/bin/bash
# 1136 — словарь тем из «Звонка»: владелец кладёт CSV в группу, сервер
# скачивает его Telethon'ом (acc1), кладёт в проекты/ дома и гонит тест 18 тем.
echo "== 1136: словарь тем — из Звонка =="

ssh -o BatchMode=yes -o StrictHostKeyChecking=accept-new -o ConnectTimeout=30 -o ServerAliveInterval=20 root@45.152.198.192 'bash -s' <<'REMOTE'
cd /root/kord-linza || exit 1
echo "--- рецепт связи otpravka2 (секреты замаскированы) ---"
grep -nE "TelegramClient|proxy|MTProxy|Connection|session" *.py 2>/dev/null | sed -E 's/[0-9a-fA-F]{32}/СКРЫТО-хэш/g; s/[A-Za-z0-9_-]{35,}/СКРЫТО-токен/g' | head -20
ls *.session .env 2>/dev/null

cat > скачать-словарь.py <<'PYEOF'
import asyncio, glob, os, sys

def load_env():
    d = {}
    for p in ('/root/kord-linza/.env', '/root/.env'):
        if os.path.exists(p):
            for line in open(p, encoding='utf-8'):
                line = line.strip()
                if line and not line.startswith('#') and '=' in line:
                    k, v = line.split('=', 1)
                    d[k.strip().upper()] = v.strip().strip('"\'')
    return d

env = load_env()
api_id = int(env.get('API_ID', 0))
api_hash = env.get('API_HASH', '')
if not (api_id and api_hash):
    print('НЕТ API_ID/API_HASH; ключи .env:', sorted(env.keys()))
    sys.exit(2)

sessions = sorted(glob.glob('/root/kord-linza/*.session') + glob.glob('/root/*.session'))
if not sessions:
    print('СЕССИЯ НЕ НАЙДЕНА')
    sys.exit(2)
session = sessions[0].rsplit('.', 1)[0]
print('сессия:', os.path.basename(session))

from telethon import TelegramClient
GROUP = -1004473651001

async def main():
    client = TelegramClient(session, api_id, api_hash)
    await client.connect()
    if not await client.is_user_authorized():
        print('СЕССИЯ НЕ АВТОРИЗОВАНА')
        return 2
    async for msg in client.iter_messages(GROUP, limit=50):
        doc = getattr(msg, 'document', None)
        if doc:
            name = getattr(doc, 'name', '') or ''
            if name.lower().endswith('.csv'):
                path = await client.download_media(msg, file='/root/poisk_chatov_18_tem.csv')
                print('СКАЧАН:', path, os.path.getsize(path), 'байт')
                return 0
    print('CSV В ЗВОНКЕ НЕ НАЙДЕН (просмотрел 50 последних)')
    return 2

sys.exit(asyncio.run(main()))
PYEOF

VENV=/root/kord-linza/venv/bin/python
timeout 240 $VENV скачать-словарь.py || { echo "СКАЧИВАНИЕ НЕ ВЫШЛО"; exit 1; }
echo "--- словарь на сервере ---"

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
echo "== 1136: конец =="
