#!/data/data/com.termux/files/usr/bin/bash
# 1109 — чтение jir_chat (200 постов, окно ~12 часов): sed-переключение читалки + чтение + пуш.
echo "== 1109: чтение jir_chat =="
ssh -o BatchMode=yes -o StrictHostKeyChecking=accept-new -o ConnectTimeout=15 root@45.152.198.192 '
sed "s/realestate_invest/jir_chat/g; s/limit=70/limit=200/" /root/kord-glubina/read-one-r1108.py > /root/kord-glubina/read-one-r1109.py
timeout 150 /root/kord-linza/venv/bin/python /root/kord-glubina/read-one-r1109.py 2>&1 | tail -210
echo "-- пуш в дом --"
cd /root/kord-glubina/kordinaps-machine || exit 1
git add "проекты/ЧТЕНИЕ-jir_chat-2026-11-07.md" 2>/dev/null
git commit -q -m "ЧТЕНИЕ jir_chat 07.11, 200 постов (по слову владельца)" 2>/dev/null
git push -q origin HEAD:main 2>&1 | tail -1
echo "пуш HEAD:main выполнен"
'
echo "== 1109: конец =="
