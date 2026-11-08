#!/data/data/com.termux/files/usr/bin/bash
# 1123 — диагностика молчания сервера: ssh не прошёл (banner timeout в 1122).
# Проверяем с телефона: туннель, пинг, порт 22, ретрай ssh с таймаутом 30.
# Ничего не лечим — сначала картина (правило 4 моста).
echo "== 1123: диагностика молчания сервера =="
echo "--- туннель (жив? возраст процесса) ---"
pgrep -af kord-tunnel || echo "ТУННЕЛЬ НЕ РАБОТАЕТ"
echo ""
echo "--- ping 45.152.198.192 ---"
ping -c 3 -W 5 45.152.198.192 2>&1 | tail -3
echo ""
echo "--- порт 22 ---"
timeout 20 bash -c 'echo > /dev/tcp/45.152.198.192/22' 2>&1 && echo "порт 22 ОТКРЫТ" || echo "порт 22 закрыт/таймаут"
echo ""
echo "--- ретрай ssh (ConnectTimeout=30, лёгкие команды) ---"
ssh -o BatchMode=yes -o StrictHostKeyChecking=accept-new -o ConnectTimeout=30 root@45.152.198.192 'echo SSH-ЖИВ; uptime; pm2 list 2>/dev/null | head -14; echo ---443---; ss -tlnp 2>/dev/null | grep :443; df -h / 2>/dev/null | tail -1' 2>&1
echo "== 1123: конец =="
