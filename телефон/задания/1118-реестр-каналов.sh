#!/data/data/com.termux/files/usr/bin/bash
# 1118 — РЕЕСТР НАКОПЛЕННЫХ КАНАЛОВ: список чатов из стека линзы (acc1–acc3) + шапки дампов Нади → один лёгкий файл в дом. Эхо — только счётчики и статус.
echo "== 1118: реестр каналов =="
ssh -o BatchMode=yes -o StrictHostKeyChecking=accept-new -o ConnectTimeout=15 root@45.152.198.192 '
cd /root/kord-glubina/kordinaps-machine || exit 1
R=$(git remote | head -1)
echo "-- pull --"; git pull "$R" main 2>&1 | tail -1
OUT="проекты/РЕЕСТР-КАНАЛОВ-2026-11-08.md"
{
echo "# РЕЕСТР НАКОПЛЕННЫХ КАНАЛОВ — срез 08.11 (по слову владельца)"
echo
echo "## Стек линзы: по одному чату на файл (acc1–acc3)"
for f in /root/kord-linza/стек/*.json; do
  [ -f "$f" ] || continue
  n=$(basename "$f")
  c=$(grep -m1 -o "\"chat\": \"[^\"]*\"" "$f" | sed "s/\"chat\": //; s/\"//g")
  cid=$(grep -m1 -o "\"chat_id\": -\?[0-9]*" "$f" | grep -o "\-\?[0-9]*$")
  cnt=$(grep -o "\"id\":" "$f" | wc -l)
  echo "- $c | $n | chat_id=$cid | сообщений=$cnt"
done
echo
echo "## Сверка: шапки из НАДИ-ПАКЕТ (50 МБ)"
grep -n "^# " "проекты/НАДИ-ПАКЕТ-2026-11-07.md" 2>/dev/null | head -300
echo
echo "## Сверка: шапки из НАДИ-СВЕЖИЕ (4,5 МБ)"
grep -n "^#" "проекты/НАДИ-СВЕЖИЕ-2026-11-07.md" 2>/dev/null | head -150
} > "$OUT"
echo "-- итог: строк в реестре: $(wc -l < "$OUT")"
echo "-- чатов в стеке: $(ls /root/kord-linza/стек/*.json 2>/dev/null | wc -l)"
git add "$OUT"
git commit -q -m "РЕЕСТР КАНАЛОВ 08.11: накопленный пул чатов стека + шапки дампов Нади (по слову владельца)" && echo "коммит: ок"
echo "-- push --"; git push "$R" main 2>&1 | tail -3
'
echo "== 1118: конец =="
