#!/data/data/com.termux/files/usr/bin/bash
# 1108 — чтение realestate_invest: sed-переключение читалки + чтение + пуш.
echo "== 1108: чтение realestate_invest =="
ssh -o BatchMode=yes -o StrictHostKeyChecking=accept-new -o ConnectTimeout=15 root@45.152.198.192 '
sed "s/brok_credit/realestate_invest/g" /root/kord-glubina/read-one-r1107.py > /root/kord-glubina/read-one-r1108.py
timeout 120 /root/kord-linza/venv/bin/python /root/kord-glubina/read-one-r1108.py 2>&1 | tail -90
echo "-- пуш в дом --"
cd /root/kord-glubina/kordinaps-machine || exit 1
git add "проекты/ЧТЕНИЕ-realestate_invest-2026-11-07.md" 2>/dev/null
git commit -q -m "ЧТЕНИЕ realestate_invest 07.11 (по слову владельца)" 2>/dev/null
git push -q origin HEAD:main 2>&1 | tail -1
echo "пуш HEAD:main выполнен"
'
echo "== 1108: конец =="
