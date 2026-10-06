#!/data/data/com.termux/files/usr/bin/bash
# 0057: где тонко — телефон руки сам до телеграма (тест VPN), гейтвей: порт/процессы/статус/логи.
# Только чтение. Токен не печатается.

echo "=== телефон руки сам до api.telegram.org (тест VPN) ==="
curl -s -m 10 -o /dev/null -w "%{http_code}\n" https://api.telegram.org/ || echo "нет ответа — похоже, VPN на телефоне выключен"

echo
echo "=== сервер: гейтвей ==="
ssh -o BatchMode=yes -o ConnectTimeout=15 root@45.152.198.192 '
echo "--- порт 18789:"
ss -tlnp | grep 18789 || echo "18789 не слушается"
echo
echo "--- процессы openclaw:"
ps aux | grep -i openclaw | grep -v grep || echo "процессов нет"
echo
echo "--- systemctl status openclaw-gateway:"
systemctl status openclaw-gateway --no-pager -l 2>&1 | head -30
echo
echo "--- journalctl openclaw-gateway:"
journalctl -u openclaw-gateway -n 30 --no-pager 2>&1 | tail -30
echo
echo "--- все файлы в logs/:"
ls -la /root/.openclaw/logs/ 2>/dev/null
for f in /root/.openclaw/logs/*; do
  [ -f "$f" ] && echo "--- $f ---" && tail -20 "$f" | grep -vE "[0-9]{8,10}:AA"
done
'
