#!/data/data/com.termux/files/usr/bin/bash
# Задание 0086 — READ-ONLY: поднялся ли leadgen-bot после возвращения вены (ночь 07.10)
# Вена вернулась в 03:27 (302). PM2 перезапускал leadgen сам — теперь проверяем, держится ли он.
# Только чтение.

echo "== 0086: leadgen после вены (read-only) =="

echo "-- вена сейчас (контроль) --"
curl -m 10 -s -o /dev/null -w '%{http_code}\n' https://api.telegram.org/ 2>/dev/null; echo "(302 = жива)"

echo "-- leadgen-bot в PM2 (статус, uptime, счётчик) --"
ssh -o BatchMode=yes root@45.152.198.192 'pm2 list 2>/dev/null | grep -E "name|leadgen"'

echo "-- сосед-свидетель: 5 последних строк лога leadgen (без токенов) --"
ssh -o BatchMode=yes root@45.152.198.192 'pm2 logs leadgen-bot --lines 5 --nostream 2>/dev/null | tail -8'

echo "-- сторож v1.1: молчит ли на живой вене (новых строк с 03:31 быть не должно) --"
tail -3 "$HOME/vena-watchdog.log" 2>/dev/null

echo "== 0086: конец (только чтение) =="
