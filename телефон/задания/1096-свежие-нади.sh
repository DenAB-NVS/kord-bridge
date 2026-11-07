#!/data/data/com.termux/files/usr/bin/bash
# 1096 — СВЕЖИЕ кандидаты Нади 06–07.11: usernames и даты. Починка пуша в приватный дом.
echo "== 1096: свежие Нади =="
ssh -o BatchMode=yes -o ConnectTimeout=25 root@45.152.198.192 '
cd /root/kord-glubina/kordinaps-machine || exit 1
echo "-- remotes (замаскированы) --"
git remote -v | sed -E "s#(https?://)[^@/]+@#\1[ТОКЕН]@#"
R=$(git remote | head -1)
echo "-- pull --"; git pull "$R" main 2>&1 | tail -1
OUT="проекты/НАДИ-СВЕЖИЕ-2026-11-07.md"
{
echo "# СВЕЖИЕ КАНДИДАТЫ Нади — 06–07.11"
echo "## Досье scratch после 06.11 12:00 (полностью)"
for f in $(find /root/.hermes/cache/scratch -maxdepth 1 -type f -newermt "2026-11-06 12:00" -size -200k 2>/dev/null); do echo; echo "=== $f ==="; cat "$f"; done
echo
echo "## РЕАЛ-строки 06–07.11 (хвост 30)"
grep "РЕАЛ" /root/kord-glubina/reestr-live.md | grep -E "0[67]\.11" | tail -30
} > "$OUT"
git add "$OUT"
git commit -q -m "НАДИ-СВЕЖИЕ 06-07.11 (по слову владельца)" && echo "коммит: ок"
echo "-- push --"; git push "$R" main 2>&1 | tail -3
echo "строк: $(wc -l < "$OUT")"
echo "-- сразу в эхо: свежие РЕАЛ-строки --"
grep "РЕАЛ" /root/kord-glubina/reestr-live.md | grep -E "0[67]\.11" | tail -10 | cut -c1-400
echo "-- самое свежее досье --"
NEW=$(find /root/.hermes/cache/scratch -maxdepth 1 -type f -newermt "2026-11-06 12:00" -name "*kandidat*" 2>/dev/null | head -1)
[ -n "$NEW" ] && { echo "### $NEW"; cat "$NEW"; } || echo "новых досье кандидатов после 06.11 12:00 нет"
'
echo "== 1096: конец =="
