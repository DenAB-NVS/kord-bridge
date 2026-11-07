#!/data/data/com.termux/files/usr/bin/bash
# 1093 — разведка полки Нади и потока realtystr на сервере. Только чтение, обезличенно.
# Правило: в эхо (публично) — только пути, размеры, счётчики, даты, ID. Без имён, телефонов, ссылок на людей.
echo "== 1093: разведка Нади/realtystr =="
S() { ssh -o BatchMode=yes -o ConnectTimeout=25 root@45.152.198.192 "$1"; }

echo "-- 1. Где живёт полка Нади и realtystr --"
S 'find /root /opt /srv /home -maxdepth 4 \( -iname "*nadi*" -o -iname "*realtystr*" \) -print 2>/dev/null | head -30'

echo "-- 2. Свежие файлы потока после 05.11 --"
S 'find /root -maxdepth 5 -type f -newermt "2026-11-05" 2>/dev/null | grep -viE "\.(log|pyc|tar\.gz)$" | head -40'

echo "-- 3. Сердце: kord-glubina, верхний уровень --"
S 'ls -la /root/kord-glubina/ 2>/dev/null | head -30'

echo "-- 4. Головы найденных файлов Нади (обезличенно, 15 строк) --"
S 'for f in $(find /root -maxdepth 4 -type f -iname "*nadi*" 2>/dev/null | head -5); do echo "### $f ($(wc -l < "$f") строк)"; head -15 "$f" | sed -E "s/[0-9+][0-9 -]{9,}/[ТЕЛЕФОН]/g; s/t\.me\/[A-Za-z0-9_]+/[ССЫЛКА]/g; s/@[A-Za-z0-9_]{3,}/[НИК]/g"; done'

echo "== 1093: конец =="
