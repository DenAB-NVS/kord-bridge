#!/data/data/com.termux/files/usr/bin/bash
# 0009: ТЕСТ ЛЕЧЕНИЯ — туннель телефона к Telegram. Временный, снимается в конце.
# Ничего постоянного: только проверка, что схема работает.

echo "--- 0009: ТЕСТ ТУННЕЛЯ, $(date) ---"
echo "=== 1. Телефон сам видит Telegram (через VPN)? ==="
curl -s --max-time 10 -o /dev/null -w "phone_tg http_code=%{http_code} time=%{time_total}s\n" https://api.telegram.org/ 2>&1 || echo PHONE_TG_FAIL
echo "=== 2. Поднимаем временный туннель ==="
ssh -f -N -R 127.0.0.1:443:api.telegram.org:443 -o BatchMode=yes -o ExitOnForwardFailure=yes -o ServerAliveInterval=15 root@45.152.198.192 && echo "туннель поднят"
sleep 5
echo "=== 3. Проверка с сервера через туннель ==="
ssh -o BatchMode=yes -o StrictHostKeyChecking=accept-new -o ConnectTimeout=15 root@45.152.198.192 '
ss -tlnp 2>/dev/null | grep ":443 " || echo "порт 443 не слушается"
curl --resolve api.telegram.org:443:127.0.0.1 -s --max-time 10 -o /dev/null -w "tunnel_http=%{http_code} time=%{time_total}s\n" https://api.telegram.org/ 2>&1 || echo TUNNEL_CURL_FAIL
'
echo "=== 4. Снимаем временный туннель ==="
pkill -f "127.0.0.1:443:api.telegram.org" 2>/dev/null
echo "туннель снят"
echo "--- КОНЕЦ ---"
