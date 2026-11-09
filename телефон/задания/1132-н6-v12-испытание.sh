#!/data/data/com.termux/files/usr/bin/bash
# 1132 — испытание №6 v1.2 на живой дороге: git pull, selftest с pymorphy3,
# живой прогон с замером времени, предвестники в «Звонок», перенос в дом.
echo "== 1132: №6 v1.2 — испытание =="
ssh -o BatchMode=yes -o StrictHostKeyChecking=accept-new -o ConnectTimeout=30 -o ServerAliveInterval=20 root@45.152.198.192 'bash -s' <<'REMOTE'
cd /root/kord-glubina/kordinaps-machine || exit 1
echo "--- git pull (подтянуть №6 v1.2) ---"
git pull -q origin main 2>&1 | tail -1
cd Hermes/движок || exit 1
PY=/root/kord-dvizhok-venv/bin/python
echo "--- selftest №6 v1.2 (с pymorphy3 — где дефект был пойман) ---"
timeout 300 $PY 06-forvardy-perenos-temy.py --selftest 2>&1 | tail -18
echo "--- живой прогон v1.2 (замер времени; до v1.2 — 15 минут тишины) ---"
time timeout 600 $PY -u 06-forvardy-perenos-temy.py run ../топливо/поток.jsonl --lag 6 --lift 1.5 --out obkat-перенос.jsonl 2>&1 | tail -45
echo "--- отправка предвестников в Звонок (otpravka2) ---"
timeout 240 /root/kord-linza/venv/bin/python otpravka2.py 2>&1 | tail -30
echo "--- пуш переноса в дом ---"
cd /root/kord-glubina/kordinaps-machine || exit 1
git add -f "Hermes/движок/obkat-перенос.jsonl" 2>&1 | tail -1
git commit -q -m "№6 v1.2 испытан на живом потоке: предвестники-кандидаты сохранены (09.11 ночь)" 2>&1 | tail -1
git push -q origin HEAD:main 2>&1 | tail -1
echo "пуш выполнен"
REMOTE
echo "== 1132: конец =="
