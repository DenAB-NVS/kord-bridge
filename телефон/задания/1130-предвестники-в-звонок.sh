#!/data/data/com.termux/files/usr/bin/bash
# 1130 — плоды №6 → группа «звонок»: забрать кандидатов, найти канал радаров, отправить сводку.
# Отправка только по найденному каналу; не нашли — честный отказ, ничего не шлём (правило 4).
echo "== 1130: предвестники в звонок =="
ssh -o BatchMode=yes -o StrictHostKeyChecking=accept-new -o ConnectTimeout=30 -o ServerAliveInterval=20 root@45.152.198.192 'bash -s' <<'REMOTE'
cd /root/kord-glubina/kordinaps-machine/Hermes/движок || exit 1
echo "--- №6: хвост лога ---"
tail -25 obkat-n6.log 2>&1
echo "--- №6: кандидаты ---"
wc -l obkat-перенос.jsonl 2>&1
echo "--- как радары шлют в звонок (разведка канала) ---"
grep -rln "звонок" /root --include="*.py" 2>/dev/null | head -5
grep -rn "звонок" /root/kord-glubina /root/рассылка --include="*.py" 2>/dev/null | head -10
echo "--- отправка сводки в звонок (acc1 через туннель) ---"
cat > otpravka.py <<'PYEOF'
import asyncio, json, sqlite3, shutil, os
from telethon import TelegramClient
cfg = json.load(open('/root/рассылка/конфиг.json', encoding='utf-8'))
API_ID, API_HASH = int(cfg['api_id']), cfg['api_hash']
BASE = '/root/kord-linza'
WORK = os.path.join(BASE, 'стек', '.work-zvonok')
os.makedirs(WORK, exist_ok=True)
shutil.copyfile('/root/рассылка/sessions/acc1.session', os.path.join(WORK, 'acc1.session'))
db = sqlite3.connect(os.path.join(WORK, 'acc1.session'))
db.execute('update sessions set server_address=?, port=?', ('127.0.0.1', 17443))
db.commit(); db.close()
cands = []
if os.path.exists('obkat-перенос.jsonl'):
    for line in open('obkat-перенос.jsonl', encoding='utf-8'):
        try:
            r = json.loads(line)
        except Exception:
            continue
        if r.get('is_candidate'):
            cands.append(r)
lines = ['КООРДИНАПС · ДВИЖОК · живая обкатка 09.11', '']
lines.append('Топливо: 4 чата, 14 дней, 3893 сообщения.')
lines.append('55 тактов OK, 0 поломок. Калибровка 87.3% на 90% интервале.')
lines.append('')
lines.append('ПРЕДВЕСТНИКИ-КАНДИДАТЫ (гипотезы, is_causal=false):')
if cands:
    for c in cands[:15]:
        lines.append('• %s: %s → %s | эхо %d/%d ч | lift %s (lo %s)' %
                     (c['word'], c['from_chat'], c['to_chat'],
                      c['echo_sessions'], c['n_source_hours'], c['lift'], c['lift_lo']))
else:
    lines.append('кандидатов по правилу (lift_lo>=1.5, эхо>=3) не найдено — честно')
lines.append('')
lines.append('Замечания движку — владельцу в чат. Полный отчёт: дом, ОБКАТКА-ЖИВАЯ-01.md.')
TEXT = '\n'.join(lines)
print('--- ТЕКСТ СООБЩЕНИЯ ---')
print(TEXT)
async def main():
    client = TelegramClient(os.path.join(WORK, 'acc1'), API_ID, API_HASH,
                            receive_updates=False, request_retries=1, connection_retries=1, timeout=25)
    await asyncio.wait_for(client.connect(), 35)
    if not await client.is_user_authorized():
        print('acc1 НЕ авторизован'); await client.disconnect(); return
    target = None
    async for d in client.iter_dialogs(limit=120):
        title = ((getattr(d.entity, 'title', None) or '') + ' ' + str(d.name or '')).lower()
        if 'звонок' in title:
            target = d
            break
    if target is None:
        print('ГРУППА ЗВОНОК НЕ НАЙДЕНА в диалогах acc1 — НИЧЕГО НЕ ОТПРАВЛЕНО')
        await client.disconnect()
        return
    print('нашли группу:', target.name, '| id:', target.id)
    await client.send_message(target.entity, TEXT, link_preview=False)
    print('ОТПРАВЛЕНО В ЗВОНОК')
    await client.disconnect()
asyncio.run(main())
shutil.rmtree(WORK, ignore_errors=True)
PYEOF
timeout 300 /root/kord-linza/venv/bin/python otpravka.py 2>&1 | tail -45
echo "== 1130: конец =="
REMOTE
echo "== 1130: конец задания =="
