#!/data/data/com.termux/files/usr/bin/bash
# 0014: ОСМОТР BANKROTSTVO-BOTS ПЕРЕД ЗАПУСКОМ ADMIN — только чтение.
# Секреты фильтруются: token|key|secret|password|bot[0-9] не попадают в эхо.

echo "--- 0014: ОСМОТР, $(date) ---"
ssh -o BatchMode=yes -o StrictHostKeyChecking=accept-new -o ConnectTimeout=15 root@45.152.198.192 '
echo "=== СОСТАВ bankrotstvo-bots ==="
ls -la /root/bankrotstvo-bots/ | head -25
echo "=== ИМЕНА КЛЮЧЕЙ .env (без значений) ==="
grep -oE "^[A-Za-z_0-9]+" /root/bankrotstvo-bots/.env 2>/dev/null || echo "нет .env"
echo "=== НАЧАЛО admin.js (без секретов) ==="
grep -viE "token|key|secret|password" /root/bankrotstvo-bots/admin.js 2>/dev/null | head -25
echo "=== СВЕРКА КАНОНА ==="
python3 /root/sverka.py bankrotstvo-bots 2>&1 | head -10 || true
cd /root/bankrotstvo-bots && node --check admin.js 2>&1 && echo "синтаксис admin.js ОК" || echo "синтаксис НЕ ПРОШЁЛ"
'
echo "--- КОНЕЦ ---"
