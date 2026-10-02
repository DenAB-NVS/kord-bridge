#!/data/data/com.termux/files/usr/bin/bash
# 0006: ДИАГНОСТИКА СЕРВЕРА kord-vps-01 — только чтение.
# Причина: legal-bots / shtraf-bot / template-bot в петле перезапуска (600+ рестартов).
# Рука ходит по ключу (id_ed25519), пароль не нужен. На сервере ничего не меняем.

echo "--- ДИАГНОСТИКА kord-vps-01, $(date) ---"
ssh -o BatchMode=yes -o StrictHostKeyChecking=accept-new -o ConnectTimeout=15 root@45.152.198.192 '
echo "=== LEGAL-BOTS (последние 20 строк) ==="
pm2 logs legal-bots --lines 20 --nostream
echo "=== SHTRAF-BOT (10) ==="
pm2 logs shtraf-bot --lines 10 --nostream
echo "=== TEMPLATE-BOT (10) ==="
pm2 logs template-bot --lines 10 --nostream
echo "=== KORD-WORKER (10) ==="
pm2 logs kord-worker --lines 10 --nostream
echo "=== ЖУРНАЛ ИСПОЛНЕННОГО /root/kord-vypolneno.txt ==="
tail -25 /root/kord-vypolneno.txt 2>/dev/null || echo "файл не найден"
' 2>&1
echo "--- КОНЕЦ ДИАГНОСТИКИ ---"
