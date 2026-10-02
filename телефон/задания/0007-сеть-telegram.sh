#!/data/data/com.termux/files/usr/bin/bash
# 0007: ПОЧЕМУ СЕРВЕР НЕ ВИДИТ TELEGRAM — только чтение.
# Проверяем связь до api.telegram.org, DNS и имена ключей .env у ботов.
# ВНИМАНИЕ: значения .env НЕ выводим — только имена ключей, секреты в эхо не попадают.

echo "--- 0007: СЕТЬ ДО TELEGRAM, $(date) ---"
ssh -o BatchMode=yes -o StrictHostKeyChecking=accept-new -o ConnectTimeout=15 root@45.152.198.192 '
echo "=== CURL api.telegram.org ==="
curl -s --max-time 10 -o /dev/null -w "http_code=%{http_code} time=%{time_total}s\n" https://api.telegram.org/ 2>&1 || echo CURL_FAIL
echo "=== DNS ==="
getent hosts api.telegram.org 2>/dev/null || echo DNS_FAIL
echo "=== PM2 CWD БОТОВ ==="
pm2 describe legal-bots 2>/dev/null | grep -E "cwd|script path"
pm2 describe leadgen-bot 2>/dev/null | grep -E "cwd|script path"
echo "=== ИМЕНА КЛЮЧЕЙ .env (без значений) ==="
find /root -maxdepth 2 -name ".env" 2>/dev/null | while read f; do echo "--- $f"; grep -oE "^[A-Za-z_0-9]+" "$f" 2>/dev/null; done
echo "=== LEADGEN OUT (8 строк) ==="
pm2 logs leadgen-bot --lines 8 --nostream 2>&1 | grep -v REDACT
' 2>&1
echo "--- КОНЕЦ ---"
