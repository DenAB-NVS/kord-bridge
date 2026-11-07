#!/data/data/com.termux/files/usr/bin/bash
# 1114 — повторное чтение it_ipoteka_chat (прокси упал в 1113): 3 попытки с паузами.
echo "== 1114: повтор it_ipoteka_chat =="
ssh -o BatchMode=yes -o StrictHostKeyChecking=accept-new -o ConnectTimeout=15 root@45.152.198.192 '
for i in 1 2 3; do
  echo "--- попытка $i ---"
  timeout 150 /root/kord-linza/venv/bin/python /root/kord-glubina/read-one-r1113.py 2>&1 | tail -210
  if ls /root/kord-glubina/kordinaps-machine/проекты/ЧТЕНИЕ-it_ipoteka_chat-2026-11-07.md >/dev/null 2>&1; then
    echo "читалка отработала — выходим из цикла"
    break
  fi
  sleep 20
done
echo "-- пуш в дом --"
cd /root/kord-glubina/kordinaps-machine || exit 1
git add "проекты/ЧТЕНИЕ-it_ipoteka_chat-2026-11-07.md" 2>/dev/null
git commit -q -m "ЧТЕНИЕ it_ipoteka_chat 07.11 повтор (по слову владельца)" 2>/dev/null
git push -q origin HEAD:main 2>&1 | tail -1
echo "пуш HEAD:main выполнен"
'
echo "== 1114: конец =="
