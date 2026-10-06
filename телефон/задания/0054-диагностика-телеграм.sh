#!/data/data/com.termux/files/usr/bin/bash
# 0054: диагностика телеграм-канала OpenClaw — туннель, бот getMe, логи гейтвея.
# Токен не печатается: строки с токен-почерком вырезаются.

ssh -o BatchMode=yes root@45.152.198.192 '
echo "=== туннель: api.telegram.org через 127.0.0.1 ==="
curl -s -m 10 -o /dev/null -w "%{http_code}\n" https://api.telegram.org/ || echo "нет ответа"
echo
echo "=== бот: getMe (без печати токена) ==="
TOKEN=$(python3 -c "import json;print(json.load(open(\"/root/.openclaw/openclaw.json\"))[\"channels\"][\"telegram\"][\"botToken\"] )" 2>/dev/null)
if [ -n "$TOKEN" ]; then
  curl -s -m 10 "https://api.telegram.org/bot${TOKEN}/getMe" | head -c 300
  echo
else
  echo "токен в конфиге не найден"
fi
echo
echo "=== лог гейтвея (последние строки, без токенов) ==="
journalctl -u openclaw-gateway --no-pager -n 40 | grep -vE "[0-9]{8,10}:AA"
'
