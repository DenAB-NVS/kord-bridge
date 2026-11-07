#!/data/data/com.termux/files/usr/bin/bash
# 1095 — досье кандидатов Нади в ПРИВАТНЫЙ дом (usernames, даты, контакты).
# В эхо (публично) — только статус. Полные данные — коммитом в kordinaps-machine.
echo "== 1095: досье Нади в приватный дом =="
ssh -o BatchMode=yes -o ConnectTimeout=25 root@45.152.198.192 '
cd /root/kord-glubina/kordinaps-machine || exit 1
git pull -q origin main 2>/dev/null
OUT="проекты/НАДИ-ПАКЕТ-2026-11-07.md"
{
echo "# ПАКЕТ ДЛЯ НАДИ — 07.11.2026, утро. Полные досье (приватный дом)."
echo
echo "## dlyanadi-bak-t41x53.md (полностью)"
cat /root/.hermes/cache/scratch/dlyanadi-bak-t41x53.md
echo
echo "## nadi-kandidat7-r387.txt (полностью)"
cat /root/.hermes/cache/scratch/nadi-kandidat7-r387.txt
echo
echo "## Досье по именам пакета (75205, arktikk, danilasita, vkusville)"
for u in 75205 arktikk danilasita vkusville; do
  grep -rl "$u" /root/.hermes/cache/scratch/ 2>/dev/null | while read f; do echo "### $f"; cat "$f"; echo; done
done
echo
echo "## Свежие РЕАЛ-строки реестра (последние 15)"
grep "РЕАЛ" /root/kord-glubina/reestr-live.md | tail -15
} > "$OUT"
git add "$OUT"
git commit -q -m "НАДИ-ПАКЕТ: полные досье кандидатов (приват, по слову владельца 07.11)" && echo "коммит прошёл" || echo "нет изменений"
git push -q origin main 2>/dev/null && echo "пуш прошёл" || echo "пуш не прошёл"
echo "строк в пакете: $(wc -l < "$OUT")"
'
echo "== 1095: конец =="
