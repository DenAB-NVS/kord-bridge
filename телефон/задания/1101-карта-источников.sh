#!/data/data/com.termux/files/usr/bin/bash
# 1101 — разведка: список всех источников (20+) + состояние туннеля MTProto + стек. Только чтение.
echo "== 1101: карта источников =="
ssh -o BatchMode=yes -o ConnectTimeout=25 root@45.152.198.192 '
M() { sed -E "s/[0-9+][0-9 -]{9,}/[ТЕЛЕФОН]/g"; }
echo "-- 1. Где лежит список источников (файлы, знающие zalogzaym) --"
grep -rl "zalogzaym" /root/radar/ /root/kord-linza/ /root/kord-glubina/ 2>/dev/null | grep -E "\.(json|py|md|txt)$" | grep -v ".bak" | head -12
echo
echo "-- 2. Конфиги-кандидаты (головы) --"
for f in $(grep -rl "zalogzaym" /root/radar/ /root/kord-linza/ 2>/dev/null | grep -E "\.json$" | grep -v ".bak" | head -3); do
  echo "### $f"; head -60 "$f" | M
done
echo
echo "-- 3. Чаты, которые уже читаются (стек, имена) --"
ls /root/kord-linza/стек/*.json 2>/dev/null | sed "s|.*/||" | head -40
echo
echo "-- 4. Туннель: слушает ли порт 17443 и 443 --"
ss -tlnp 2>/dev/null | grep -E ":17443|:443" | M
echo
echo "-- 5. Стоп-флаги и журнал читалки --"
ls /root/kord-linza/STOP /root/kord-linza/СТОП-ТУННЕЛЬ 2>/dev/null || echo "стоп-флагов нет"
tail -6 /root/kord-linza/журнал/chitka-2026-11-0[67].log 2>/dev/null | M
'
echo "== 1101: конец =="
