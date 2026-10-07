#!/data/data/com.termux/files/usr/bin/bash
# Задание 0087 — ДОЗОРНАЯ V3.1: не затирать старый снимок пустым (ночь 07.10, ~04:05)
# Заноза из волны 03:19: при неудачном fetch дозор затирал прежний снимок пустым файлом.
# Лечение: писать во временный файл, заменять рабочий только непустым. Свои логи — в kord-dozor.log.
# Откат: cp kord-dozor.sh.bak-v3 kord-dozor.sh; перезапуск петли как в 0080.

echo "== 0087: дозорная v3.1 =="

DZ="$HOME/kord-dozor.sh"
[ -f "$DZ" ] || { echo "дозора нет — стоп"; exit 1; }
cp "$DZ" "$DZ.bak-v3"
echo "бэкап: $DZ.bak-v3"

cat > "$DZ.new" <<'DZEOF'
#!/data/data/com.termux/files/usr/bin/bash
# Дозор v3.1 — 07.10: пустой fetch не затирает старый снимок. Пишет в ~/kord-echo/дозор/, лог — в kord-dozor.log.
# Порядок: фоновые уши первыми (разогрев холодного туннеля), главные (webfrl, digitaltender) — после.
while true; do
  curl -s -m 25 -A "Mozilla/5.0" "https://t.me/s/python_jobs_ru" >/dev/null 2>&1
  for ch in python_jobs_ru normrabota webfrl digitaltender; do
    f="$HOME/kord-echo/дозор/$ch.txt"
    t="$HOME/.dz-$ch.tmp"
    ok=0
    for try in 1 2; do
      curl -s -m 25 -A "Mozilla/5.0" "https://t.me/s/$ch" \
        | sed "s/></>\n</g" \
        | sed -n "/tgme_widget_message_text/,/<\/div>/p" \
        | sed "s/<[^>]*>//g" \
        | head -c 30000 > "$t" 2>/dev/null
      if [ -s "$t" ]; then mv "$t" "$f"; ok=1; break; fi
      sleep 3
    done
    if [ "$ok" -eq 0 ]; then
      rm -f "$t" 2>/dev/null
      echo "$(date '+%Y-%m-%d %H:%M:%S') $ch: снимок не получен, старый сохранён" >> "$HOME/kord-dozor.log"
    fi
  done
  sleep 300
done
DZEOF

echo "-- синтаксис --"
if bash -n "$DZ.new" 2>&1; then
  mv "$DZ.new" "$DZ"
  chmod +x "$DZ"
  echo "v3.1 установлена"
else
  echo "СИНТАКСИС ПЛОХОЙ — не ставим, старая целa"
  rm -f "$DZ.new"
  exit 1
fi

echo "-- перезапуск петли --"
pkill -f kord-dozor 2>/dev/null; sleep 1
nohup bash "$HOME/kord-dozor.sh" >/dev/null 2>&1 &
sleep 2
pgrep -f kord-dozor >/dev/null && echo "петля бежит (v3.1)" || echo "петля НЕ поднялась"

echo "-- дифф v3 → v3.1 --"
diff "$DZ.bak-v3" "$DZ" || true

echo "откат: cp $DZ.bak-v3 $DZ; pkill -f kord-dozor; nohup bash $DZ &"
echo "== 0087: конец =="
