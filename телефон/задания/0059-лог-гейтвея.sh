#!/data/data/com.termux/files/usr/bin/bash
# 0059: лог гейтвея /tmp/openclaw/openclaw-2026-10-06.log — состояние телеграм-канала,
# пришедшие сообщения, ID группы и топика. Плюс повторный тест вены (три попытки).
# Токен не печатается.

ssh -o BatchMode=yes -o ConnectTimeout=15 root@45.152.198.192 '
echo "--- вена, три попытки:"
for i in 1 2 3; do
  curl -s -m 8 -o /dev/null -w "попытка $i: %{http_code}\n" https://api.telegram.org/
  sleep 3
done
echo
echo "--- хвост лога гейтвея (без токенов):"
tail -100 /tmp/openclaw/openclaw-2026-10-06.log 2>/dev/null | grep -vE "[0-9]{8,10}:AA" | tail -70
'
