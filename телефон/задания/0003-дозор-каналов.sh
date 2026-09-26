#!/data/data/com.termux/files/usr/bin/bash
# 0003: ДОЗОР КАНАЛОВ — ловим заказы до подписи контракта
# Каждые 5 минут снимает свежие посты с веб-версий каналов и кладёт в вывод.
# Эхо унесёт их в kord-echo — Кординапс читает через патч коммита и готовит ответы.

mkdir -p ~/пульт/вывод

if [ -f ~/пульт/вывод/0003-дозор.pid ] && kill -0 "$(cat ~/пульт/вывод/0003-дозор.pid)" 2>/dev/null; then
  echo "дозор уже работает"
  exit 0
fi

nohup bash -c '
while true; do
  for ch in freelancetavern distantsiya it_freelance python_jobs_ru; do
    curl -s -m 20 -A "Mozilla/5.0" "https://t.me/s/$ch" \
      | sed "s/></>\n</g" \
      | sed -n "/tgme_widget_message_text/,/<\/div>/p" \
      | sed "s/<[^>]*>//g" \
      | head -c 15000 > ~/пульт/вывод/0003-дозор-$ch.txt 2>/dev/null
  done
  sleep 300
done' > /dev/null 2>&1 &

echo $! > ~/пульт/вывод/0003-дозор.pid
echo "дозор запущен: 4 канала, цикл 5 минут"
