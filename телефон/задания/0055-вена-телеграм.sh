#!/data/data/com.termux/files/usr/bin/bash
# 0055: поднять вену к Telegram (туннель с телефона руки), проверка конец-в-конец,
# статус и настоящие логи гейтвея OpenClaw. Токен не печатается.

echo "=== вена на телефоне руки ==="
pkill -f kord-tunnel 2>/dev/null
pkill -f "443:api.telegram.org" 2>/dev/null
sleep 2
nohup bash ~/kord-tunnel.sh >/dev/null 2>&1 &
sleep 8
pgrep -af kord-tunnel || echo "вена не поднялась"

echo
echo "=== сервер: конец-в-конец ==="
ssh -o BatchMode=yes root@45.152.198.192 '
ss -tlnp | grep :443 || echo "443 на сервере не слушается"
echo
echo "код ответа api.telegram.org:"
curl -s -m 10 -o /dev/null -w "%{http_code}\n" https://api.telegram.org/ || echo "нет ответа"
echo
echo "=== статус гейтвея ==="
systemctl status openclaw-gateway --no-pager -l | head -25
echo
echo "=== файлы в /root/.openclaw ==="
ls -la /root/.openclaw/ | head -20
echo
echo "=== хвосты логов (без токенов) ==="
for f in /root/.openclaw/*.log; do
  [ -f "$f" ] && echo "--- $f ---" && tail -15 "$f" | grep -vE "[0-9]{8,10}:AA"
done
echo
echo "=== рестарт гейтвея (подхватить телеграм) ==="
openclaw gateway restart
'
