#!/data/data/com.termux/files/usr/bin/bash
# 0013: ПОИСК ADMIN-БОТА — только чтение.
# Полка 7: admin — готовая основа пульта-кнопки из контуров. В PM2 его нет. Ищем следы.

echo "--- 0013: ПОИСК ADMIN, $(date) ---"
ssh -o BatchMode=yes -o StrictHostKeyChecking=accept-new -o ConnectTimeout=15 root@45.152.198.192 '
echo "=== ИМЕНА PM2 (без окружения) ==="
pm2 jlist 2>/dev/null | grep -oE "\"name\":\"[^\"]+\"" | sort -u
echo "=== DUMP PM2 ==="
grep -c admin /root/.pm2/dump.pm2 2>/dev/null || echo "в dump.pm2 нет admin"
echo "=== ПАПКИ В /root ==="
ls -d /root/*/ 2>/dev/null
echo "=== ПОИСК admin ФАЙЛОВ ==="
find /root -maxdepth 2 -iname "*admin*" 2>/dev/null | head -15
echo "=== ЧТО ЗАПУСКАЕТ kord-worker (/root/zapusk.sh) ==="
grep -viE "token|key|secret|password" /root/zapusk.sh 2>/dev/null | head -30 || echo "zapusk.sh не найден"
'
echo "--- КОНЕЦ ---"
