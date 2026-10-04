#!/data/data/com.termux/files/usr/bin/bash
# 0052: LEADGEN-BOT — read-only диагностика петли перезапуска (по снимку 0051: 159+ рестартов, launching).
# Только чтение: describe и логи, без лечения. Не перезапускать, не обновлять npm, не менять конфиги.

echo "--- 0052: LEADGEN-BOT READ-ONLY ДИАГНОСТИКА, $(date) ---"
ssh -o BatchMode=yes -o StrictHostKeyChecking=accept-new -o ConnectTimeout=15 root@45.152.198.192 '
echo "=== 1. PM2 DESCRIBE LEADGEN ==="
pm2 describe leadgen-bot 2>&1 | head -30
echo "=== 2. ПОСЛЕДНИЕ ЛОГИ (30 строк) ==="
timeout 60 pm2 logs leadgen-bot --lines 30 --nostream 2>&1 | tail -40
echo "=== 3. ПУТЬ ИСПОЛНЯЕМОГО ФАЙЛА (без окружения и секретов) ==="
pm2 jlist 2>/dev/null | grep -o "\"pm_exec_path\":\"[^\"]*\"" | head -5
echo "=== 4. СОСТОЯНИЕ СЕЙЧАС ==="
pm2 list | grep -E "leadgen|status" 
echo "=== КОНЕЦ 0052 ==="
' 2>&1
echo "--- КОНЕЦ 0052 ---"
