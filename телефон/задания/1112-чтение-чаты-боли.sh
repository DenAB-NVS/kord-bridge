#!/data/data/com.termux/files/usr/bin/bash
# 1112 — чтение обоих чатов боли (ipotekagroup + it_ipoteca_chat, по 200 постов).
echo "== 1112: чтение чатов боли =="
ssh -o BatchMode=yes -o StrictHostKeyChecking=accept-new -o ConnectTimeout=15 root@45.152.198.192 '
echo "--- ipotekagroup ---"
sed "s/credity_zalogy/ipotekagroup/g" /root/kord-glubina/read-one-r1110.py > /root/kord-glubina/read-one-r1112a.py
timeout 150 /root/kord-linza/venv/bin/python /root/kord-glubina/read-one-r1112a.py 2>&1 | tail -210
echo ""
echo "--- it_ipoteca_chat ---"
sed "s/credity_zalogy/it_ipoteca_chat/g" /root/kord-glubina/read-one-r1110.py > /root/kord-glubina/read-one-r1112b.py
timeout 150 /root/kord-linza/venv/bin/python /root/kord-glubina/read-one-r1112b.py 2>&1 | tail -210
echo "-- пуш в дом --"
cd /root/kord-glubina/kordinaps-machine || exit 1
git add "проекты/ЧТЕНИЕ-ipotekagroup-2026-11-07.md" "проекты/ЧТЕНИЕ-it_ipoteca_chat-2026-11-07.md" 2>/dev/null
git commit -q -m "ЧТЕНИЕ чатов боли 07.11 (по слову владельца)" 2>/dev/null
git push -q origin HEAD:main 2>&1 | tail -1
echo "пуш HEAD:main выполнен"
'
echo "== 1112: конец =="
