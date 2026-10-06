#!/data/data/com.termux/files/usr/bin/bash
# 0058: вена после включения VPN — конец-в-конец, getMe, getUpdates (ID группы и топика), статус гейтвея.
# Токен не печатается: getUpdates/getMe не содержат его, вывод фильтруется.

ssh -o BatchMode=yes -o ConnectTimeout=15 root@45.152.198.192 '
echo "--- api.telegram.org (ждём 302):"
curl -s -m 10 -o /dev/null -w "%{http_code}\n" https://api.telegram.org/ || echo "нет ответа"
echo
echo "--- статус гейтвея:"
openclaw gateway status 2>&1 | head -20
echo
TOKEN=$(python3 -c "import json;print(json.load(open(\"/root/.openclaw/openclaw.json\"))[\"channels\"][\"telegram\"][\"botToken\"] )" 2>/dev/null)
echo "--- getMe:"
curl -s -m 10 "https://api.telegram.org/bot${TOKEN}/getMe" | head -c 300
echo
echo "--- getUpdates (последние, для ID группы):"
curl -s -m 10 "https://api.telegram.org/bot${TOKEN}/getUpdates?limit=3" | head -c 1500
echo
'
