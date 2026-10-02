#!/data/data/com.termux/files/usr/bin/bash
# 0015: ЗАПУСК ADMIN-БОТА (пульт из полки 7) в PM2.
# Синтаксис ОК (0014), туннель жив, токены в cities/*.json на сервере.
# Admin отвечает только на adminIds — рассылка не автоматическая.

echo "--- 0015: ЗАПУСК ADMIN, $(date) ---"
ssh -o BatchMode=yes -o StrictHostKeyChecking=accept-new -o ConnectTimeout=15 root@45.152.198.192 '
echo "=== ecosystem.config.js (без секретов) ==="
grep -viE "token|key|secret|password" /root/bankrotstvo-bots/ecosystem.config.js
cd /root/bankrotstvo-bots
pm2 delete admin-bot >/dev/null 2>&1
pm2 start admin.js --name admin-bot --time >/dev/null 2>&1
pm2 save >/dev/null 2>&1
echo "=== ОЖИДАНИЕ 20 СЕК ==="
sleep 20
echo "=== PM2 ==="
pm2 list
echo "=== ЛОГ ADMIN ==="
pm2 logs admin-bot --lines 12 --nostream 2>&1 | grep -viE "redact"
'
echo "--- КОНЕЦ ---"
