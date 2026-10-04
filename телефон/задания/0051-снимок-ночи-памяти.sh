#!/data/data/com.termux/files/usr/bin/bash
# 0051: СНЯТОК НОЧИ ПАМЯТИ — read-only состояние перед звеном «openclaw onboard» (РОДНЫЕ-ЗАДАЧИ, ночь 04→05.10).
# Только чтение. Ничего не устанавливает, не останавливает, не меняет. Секреты и токены не выводятся.

echo "--- 0051: СНЯТОК НОЧИ ПАМЯТИ, $(date) ---"
ssh -o BatchMode=yes -o StrictHostKeyChecking=accept-new -o ConnectTimeout=15 root@45.152.198.192 '
echo "=== 1. UPTIME ==="
uptime
echo "=== 2. PM2 LIST (счётчики рестартов) ==="
pm2 list
echo "=== 3. ТУННЕЛЬ :443 ==="
ss -tlnp | grep :443
echo "=== 4. OPENCLAW ВЕРСИЯ ==="
timeout 60 openclaw --version 2>&1 | head -5
echo "=== 5. OPENCLAW СТАТУС (готовность к onboard) ==="
timeout 90 openclaw status 2>&1 | head -25
echo "=== 6. КАТАЛОГ OPENCLAW (только имена, без содержимого) ==="
ls -la /root/.openclaw/ 2>/dev/null
ls /root/.openclaw/workspace/ 2>/dev/null
echo "=== 7. DREAMING (расписание) ==="
crontab -l 2>/dev/null | grep -i dream
echo "=== 8. HERMES СРЕДА ==="
ls -la /root/hermes-src/scripts/run-in-hermes-env 2>/dev/null
echo "=== 9. ДИСК ==="
df -h / | tail -1
echo "=== КОНЕЦ 0051 ==="
' 2>&1
echo "--- КОНЕЦ 0051 ---"
