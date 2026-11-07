#!/data/data/com.termux/files/usr/bin/bash
# 1115 — газета: пробный сбор сырья с 9 каналов владельца (ручной тест прежде крона, канон ЗАДАНИЕ-КРОН-ГАЗЕТЫ-v1).
echo "== 1115: газета-сбор =="
ssh -o BatchMode=yes -o StrictHostKeyChecking=accept-new -o ConnectTimeout=15 root@45.152.198.192 '
S=/root/kord-glubina/газета-сбор-2026-11-07.txt
: > "$S"
for CH in NeuralProfit ai_newz vibecoding_tg notboring_tech data_secrets AI_NewsDailyTrends Getitrussia whackdoor denissexy; do
  for i in 1 2; do
    echo "--- канал $CH, попытка $i ---"
    sed "s/credity_zalogy/$CH/g" /root/kord-glubina/read-one-r1110.py > /root/kord-glubina/read-one-r1115.py
    if timeout 100 /root/kord-linza/venv/bin/python /root/kord-glubina/read-one-r1115.py >> "$S" 2>&1; then
      echo "$CH: ок"
      break
    fi
    echo "$CH: повтор через 15с"
    sleep 15
  done
  sleep 5
done
cd /root/kord-glubina/kordinaps-machine || exit 1
mkdir -p "проекты/ГАЗЕТА-сборы"
cp "$S" "проекты/ГАЗЕТА-сборы/2026-11-07-сырьё.md"
git add "проекты/ГАЗЕТА-сборы/2026-11-07-сырьё.md"
git commit -q -m "ГАЗЕТА пробный сбор сырья 9 каналов 07.11 (по слову владельца)"
git push -q origin HEAD:main 2>&1 | tail -1
echo "пуш HEAD:main выполнен"
'
echo "== 1115: конец =="
