#!/data/data/com.termux/files/usr/bin/bash
# 0040: ПРОВЕРКА СЕРВЕРА И РЕСУРСОВ перед ночью памяти (OpenClaw/Hermes).
# Только чтение, ничего не меняем. Рука ходит по ключу (id_ed25519).
# Контекст: рука молчала с 06:52 МСК 04.10 — первое задание после подъёма руки.

echo "--- 0040: ПРОВЕРКА СЕРВЕРА И РЕСУРСОВ, $(date) ---"
echo "=== ТУННЕЛЬ НА ТЕЛЕФОНЕ ==="
pgrep -af kord-tunnel || echo "ТУННЕЛЬ НЕ НАЙДЕН"
ssh -o BatchMode=yes -o StrictHostKeyChecking=accept-new -o ConnectTimeout=15 root@45.152.198.192 '
echo "=== UPTIME ==="
uptime
echo "=== ПАМЯТЬ ==="
free -h
echo "=== ДИСК ==="
df -h /
echo "=== PM2 ==="
pm2 list
echo "=== ВЕРСИИ ==="
node -v 2>/dev/null; npm -v 2>/dev/null; git --version
echo "=== ТУННЕЛЬ-ПРОВЕРКА НА СЕРВЕРЕ (ожидаем 302) ==="
curl --resolve api.telegram.org:443:127.0.0.1 -s -o /dev/null -w "%{http_code}\n" --max-time 10 https://api.telegram.org/
' 2>&1
echo "--- КОНЕЦ 0040 ---"
