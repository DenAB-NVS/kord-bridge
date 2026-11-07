#!/data/data/com.termux/files/usr/bin/bash
# 1107 — чтение brok_credit: переключение читалки sed-атомом + чтение + пуш. Туннель и сторож уже на посту.
echo "== 1107: чтение brok_credit =="
ssh -o BatchMode=yes -o StrictHostKeyChecking=accept-new -o ConnectTimeout=15 root@45.152.198.192 '
sed "s/avtozalogrf/brok_credit/g" /root/kord-glubina/read-one-r1104.py > /root/kord-glubina/read-one-r1107.py
timeout 120 /root/kord-linza/venv/bin/python /root/kord-glubina/read-one-r1107.py 2>&1 | tail -90
echo "-- пуш в дом --"
cd /root/kord-glubina/kordinaps-machine || exit 1
git add "проекты/ЧТЕНИЕ-brok_credit-2026-11-07.md" 2>/dev/null
git commit -q -m "ЧТЕНИЕ brok_credit 07.11 (по слову владельца)" 2>/dev/null
git push -q origin HEAD:main 2>&1 | tail -1
echo "пуш HEAD:main выполнен"
'
echo "== 1107: конец =="
