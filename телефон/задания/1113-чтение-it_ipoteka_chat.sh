#!/data/data/com.termux/files/usr/bin/bash
# 1113 — чтение it_ipoteka_chat (правильное имя) + пуш зависшего файла ipotekagroup.
echo "== 1113: чтение it_ipoteka_chat =="
ssh -o BatchMode=yes -o StrictHostKeyChecking=accept-new -o ConnectTimeout=15 root@45.152.198.192 '
sed "s/credity_zalogy/it_ipoteka_chat/g" /root/kord-glubina/read-one-r1110.py > /root/kord-glubina/read-one-r1113.py
timeout 150 /root/kord-linza/venv/bin/python /root/kord-glubina/read-one-r1113.py 2>&1 | tail -210
echo "-- пуш в дом (раздельные add — падение одного не роняет другое) --"
cd /root/kord-glubina/kordinaps-machine || exit 1
git add "проекты/ЧТЕНИЕ-it_ipoteka_chat-2026-11-07.md" 2>/dev/null
git add "проекты/ЧТЕНИЕ-ipotekagroup-2026-11-07.md" 2>/dev/null
git commit -q -m "ЧТЕНИЕ it_ipoteka_chat + ipotekagroup 07.11 (по слову владельца)" 2>/dev/null
git push -q origin HEAD:main 2>&1 | tail -1
echo "пуш HEAD:main выполнен"
'
echo "== 1113: конец =="
