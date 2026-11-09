#!/data/data/com.termux/files/usr/bin/bash
# 1142 — фикс selftest 10: build_rows ждёт ts_dt, который ставит только
# load_flow; синтетика selftest шла напрямую с ts → KeyError 'ts_dt'.
# Фикс: ts_dt или parse_ts(ts) — одна строка, логика рядов не меняется.
echo "== 1142: фикс selftest 10-ряды-цепочек =="
ssh -o BatchMode=yes -o StrictHostKeyChecking=accept-new -o ConnectTimeout=30 -o ServerAliveInterval=20 root@45.152.198.192 'bash -s' <<'REMOTE'
cd /root/kord-glubina/kordinaps-machine || exit 1
echo "--- git pull ---"
git pull -q origin main 2>&1 | tail -1
echo "--- фикс build_rows ---"
sed -i 's|hour = hour_floor(rec\["ts_dt"\])|hour = hour_floor(rec.get("ts_dt") or parse_ts(rec.get("ts")))|' Hermes/движок/10-ряды-цепочек.py
grep -n 'hour_floor(rec' Hermes/движок/10-ряды-цепочек.py
echo "--- selftest (ожидаем 6/6) ---"
timeout 300 /root/kord-dvizhok-venv/bin/python Hermes/движок/10-ряды-цепочек.py --selftest 2>&1
echo "--- коммит ---"
git add Hermes/движок/10-ряды-цепочек.py
git commit -q -m "10 v1.1: фикс selftest — build_rows принимает ts напрямую (ts_dt или parse_ts(ts)); ряды без изменений (09.11)" 2>&1 | tail -1
if git push -q origin HEAD:main 2>/tmp/1142-push.err; then echo "пуш ок"; else echo "пуш отбит — rebase и повтор"; git pull -q --rebase origin main 2>&1 | tail -1; git push -q origin HEAD:main 2>&1 | tail -1 && echo "пуш после rebase ок"; fi
REMOTE
echo "== 1142: конец =="
