#!/data/data/com.termux/files/usr/bin/bash
# 0056: проверить вену и гейтвей после 0055 (его вывод потерялся под пульсом — шов цикла v3).
# Только чтение. Токен не печатается.

echo "=== вена на телефоне руки ==="
pgrep -af kord-tunnel || echo "туннель не жив"

echo
echo "=== сервер ==="
ssh -o BatchMode=yes -o ConnectTimeout=15 root@45.152.198.192 '
echo "--- api.telegram.org (ждём 302):"
curl -s -m 10 -o /dev/null -w "%{http_code}\n" https://api.telegram.org/ || echo "нет ответа"
echo
echo "--- 443 слушается:"
ss -tlnp | grep :443 || echo "нет"
echo
echo "--- статус openclaw-gateway:"
systemctl is-active openclaw-gateway
echo
echo "--- файлы .openclaw:"
ls /root/.openclaw/
echo
echo "--- логи (без токенов):"
for f in /root/.openclaw/*.log /root/.openclaw/logs/*.log; do
  [ -f "$f" ] && echo "--- $f ---" && tail -25 "$f" | grep -vE "[0-9]{8,10}:AA"
done
'
