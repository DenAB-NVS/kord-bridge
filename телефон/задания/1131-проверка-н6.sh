#!/data/data/com.termux/files/usr/bin/bash
# 1131 — финальная проверка №6: жив ли процесс, что в логе, есть ли кандидаты;
# если файл появился — вторая сводка в «Звонок» (живые предвестники).
echo "== 1131: №6 финальная проверка =="
ssh -o BatchMode=yes -o StrictHostKeyChecking=accept-new -o ConnectTimeout=30 -o ServerAliveInterval=20 root@45.152.198.192 'bash -s' <<'REMOTE'
cd /root/kord-glubina/kordinaps-machine/Hermes/движок || exit 1
echo "--- процесс №6 жив? ---"
ps aux | grep -E "forvardy|06-" | grep -v grep | head -3 || echo "процесс завершился"
echo "--- лог №6 (полный размер + хвост) ---"
ls -la obkat-n6.log 2>&1
tail -30 obkat-n6.log 2>&1
echo "--- кандидаты? ---"
ls -la obkat-перенос.jsonl 2>&1
wc -l obkat-перенос.jsonl 2>/dev/null
echo "--- если кандидаты есть — вторая сводка в Звонок ---"
cat > otpravka2.py <<'PYEOF'
import asyncio, json, sqlite3, shutil, os
from telethon import TelegramClient
if not os.path.exists('obkat-перенос.jsonl'):
    print('файла нет — вторую сводку не шлём, №6 не успел за потолок')
    raise SystemExit(0)
cands = []
for line in open('obkat-перенос.jsonl', encoding='utf-8'):
    try:
        r = json.loads(line)
    except Exception:
        continue
    if r.get('is_candidate'):
        cands.append(r)
if not cands:
    print('кандидатов по правилу нет — вторую сводку не шлём')
    raise SystemExit(0)
cfg = json.load(open('/root/рассылка/конфиг.json', encoding='utf-8'))
API_ID, API_HASH = int(cfg['api_id']), cfg['api_hash']
BASE = '/root/kord-linza'
WORK = os.path.join(BASE, 'стек', '.work-zvonok2')
os.makedirs(WORK, exist_ok=True)
shutil.copyfile('/root/рассылка/sessions/acc1.session', os.path.join(WORK, 'acc1.session'))
db = sqlite3.connect(os.path.join(WORK, 'acc1.session'))
db.execute('update sessions set server_address=?, port=?', ('127.0.0.1', 17443))
db.commit(); db.close()
lines = ['КООРДИНАПС · ДВИЖОК · предвестники с живого потока (досылка)', '']
for c in cands[:15]:
    lines.append('• %s: %s → %s | эхо %d/%d ч | lift %s (lo %s)' %
                 (c['word'], c['from_chat'], c['to_chat'],
                  c['echo_sessions'], c['n_source_hours'], c['lift'], c['lift_lo']))
lines.append('')
lines.append('Это гипотезы (is_causal=false), не вердикты.')
TEXT = '\n'.join(lines)
print(TEXT)
async def main():
    client = TelegramClient(os.path.join(WORK, 'acc1'), API_ID, API_HASH,
                            receive_updates=False, request_retries=1, connection_retries=1, timeout=25)
    await asyncio.wait_for(client.connect(), 35)
    if not await client.is_user_authorized():
        print('acc1 НЕ авторизован'); await client.disconnect(); return
    ent = await client.get_entity(-1004473651001)
    await client.send_message(ent, TEXT, link_preview=False)
    print('ОТПРАВЛЕНО В ЗВОНОК (досылка)')
    await client.disconnect()
asyncio.run(main())
shutil.rmtree(WORK, ignore_errors=True)
PYEOF
timeout 240 /root/kord-linza/venv/bin/python otpravka2.py 2>&1 | tail -30
REMOTE
echo "== 1131: конец =="
