#!/data/data/com.termux/files/usr/bin/bash
# 1111 — чтение P2P777KAR (до 200 постов): sed-переключение читалки + чтение + пуш.
echo "== 1111: чтение P2P777KAR =="
ssh -o BatchMode=yes -o StrictHostKeyChecking=accept-new -o ConnectTimeout=15 root@45.152.198.192 '
sed "s/credity_zalogy/P2P777KAR/g" /root/kord-glubina/read-one-r1110.py > /root/kord-glubina/read-one-r1111.py
timeout 150 /root/kord-linza/venv/bin/python /root/kord-glubina/read-one-r1111.py 2>&1 | tail -210
echo "-- пуш в дом --"
cd /root/kord-glubina/kordinaps-machine || exit 1
git add "проекты/ЧТЕНИЕ-P2P777KAR-2026-11-07.md" 2>/dev/null
git commit -q -m "ЧТЕНИЕ P2P777KAR 07.11 (по слову владельца)" 2>/dev/null
git push -q origin HEAD:main 2>&1 | tail -1
echo "пуш HEAD:main выполнен"
'
echo "== 1111: конец =="
