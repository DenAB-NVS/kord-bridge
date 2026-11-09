#!/data/data/com.termux/files/usr/bin/bash
# 1134 — словарь тем в дом и тест на живом потоке: найти CSV на телефоне,
# передать на сервер, положить в проекты/ дома, selftest 09, тест 18 тем на 3893 сообщениях.
echo "== 1134: словарь тем — в дом и тест =="

CSV=""
for p in ~/storage/downloads/poisk_chatov_18_tem*.csv ~/storage/shared/Download/poisk_chatov_18_tem*.csv ~/poisk_chatov_18_tem*.csv; do
  if [ -f "$p" ]; then CSV="$p"; break; fi
done
if [ -z "$CSV" ]; then
  echo "CSV НЕ НАЙДЕН на телефоне (искал: storage/downloads, storage/shared/Download, дом termux)"
  echo "положи poisk_chatov_18_tem.csv в Загрузки телефона и запусти задание снова"
  exit 1
fi
echo "найден: $CSV ($(wc -c < "$CSV") байт)"
scp -o BatchMode=yes -o StrictHostKeyChecking=accept-new -o ConnectTimeout=30 "$CSV" root@45.152.198.192:/root/poisk_chatov_18_tem.csv || exit 1
echo "передан на сервер"

ssh -o BatchMode=yes -o StrictHostKeyChecking=accept-new -o ConnectTimeout=30 -o ServerAliveInterval=20 root@45.152.198.192 'bash -s' <<'REMOTE'
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
echo "== 1134: конец =="
