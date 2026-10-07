#!/data/data/com.termux/files/usr/bin/bash
# Задание 0083 — READ-ONLY: туннель и leadgen-bot — жив ли туннель, почему петля (ночь 07.10)
# Контекст 0082: curl через 127.0.0.1:443 с сервера = 000; leadgen-bot launching, счётчик 162.
# Только чтение. Ничего не перезапускаем — лечение утром по факту и слову владельца.

echo "== 0083: туннель и leadgen-bot (read-only) =="

echo "-- на телефоне: жив ли процесс туннеля --"
pgrep -af kord-tunnel || echo "ПРОЦЕСС ТУННЕЛЯ НЕ НАЙДЕН — туннель мёртв"

echo "-- на телефоне: доходит ли сам телефон до api.telegram.org (вена, для сравнения) --"
curl -m 10 -s -o /dev/null -w '%{http_code}\n' https://api.telegram.org/ 2>/dev/null || echo 000

echo "-- на сервере: слушается ли 127.0.0.1:443 --"
ssh -o BatchMode=yes root@45.152.198.192 'ss -tlnp 2>/dev/null | grep -E ":443\b" || echo "ПОРТ 443 НЕ СЛУШАЕТСЯ — туннель до сервера не дошёл"'

echo "-- на сервере: последние 15 строк лога leadgen-bot (без токенов) --"
ssh -o BatchMode=yes root@45.152.198.192 'pm2 logs leadgen-bot --lines 15 --nostream 2>/dev/null | tail -18'

echo "-- на сервере: /etc/hosts содержит строку туннеля? --"
ssh -o BatchMode=yes root@45.152.198.192 'grep -n "api.telegram.org" /etc/hosts || echo "СТРОКИ НЕТ — боты ходят напрямую, блокировка вернётся"'

echo "== 0083: конец (только чтение) =="
