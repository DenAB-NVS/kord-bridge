#!/data/data/com.termux/files/usr/bin/bash
# 0003: ДОЗОР КАНАЛОВ v2 — под новую руку
# Каждые 5 минут снимает посты с веб-версий каналов и пишет прямо в эхо (~/kord-echo/дозор/).
# Цикл моста подхватывает и коммитит эти файлы в kord-echo — Кординапс читает их через патчи коммитов.

mkdir -p "$HOME/kord-echo/дозор"

PIDF="$HOME/kord-echo/дозор/дозор.pid"
if [ -f "$PIDF" ] && kill -0 "$(cat "$PIDF")" 2>/dev/null; then
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
      | head -c 15000 > "$HOME/kord-echo/дозор/$ch.txt" 2>/dev/null
  done
  sleep 300
done' > /dev/null 2>&1 &

echo $! > "$PIDF"
echo "дозор запущен: 4 канала, цикл 5 минут, пишет в kord-echo/дозор/"
