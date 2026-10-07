#!/data/data/com.termux/files/usr/bin/bash
# Задание 0081 — ДОЗОРНАЯ V3: прогрев туннеля + повторы (ночь 07.10)
# Диагноз по ночным тестрам: после 5 минут покоя VPN первые 1–2 запроса падают (000),
# дальше туннель тёплый. В v2 главные уши (webfrl, digitaltender) стояли первыми — и гибли.
# Лечение: разогревочный запрос перед кругом + каждому каналу 2 попытки с паузой.

echo "== 0081: дозорная v3 =="

echo "-- снять v2 --"
pkill -f kord-dozor 2>/dev/null; sleep 1
pgrep -f kord-dozor >/dev/null && echo "НЕ снялась" || echo "v2 снята"

cat > "$HOME/kord-dozor.sh" <<'DZEOF'
#!/data/data/com.termux/files/usr/bin/bash
# Дозор v3 — 07.10: прогрев + повторы. Пишет только в ~/kord-echo/дозор/.
# Порядок: фоновые уши первыми (разогрев), главные уши (webfrl, digitaltender) — после.
while true; do
  curl -s -m 25 -A "Mozilla/5.0" "https://t.me/s/python_jobs_ru" >/dev/null 2>&1
  for ch in python_jobs_ru normrabota webfrl digitaltender; do
    for try in 1 2; do
      curl -s -m 25 -A "Mozilla/5.0" "https://t.me/s/$ch" \
        | sed "s/></>\n</g" \
        | sed -n "/tgme_widget_message_text/,/<\/div>/p" \
        | sed "s/<[^>]*>//g" \
        | head -c 30000 > "$HOME/kord-echo/дозор/$ch.txt" 2>/dev/null
      [ -s "$HOME/kord-echo/дозор/$ch.txt" ] && break
      sleep 3
    done
  done
  sleep 300
done
DZEOF
chmod +x "$HOME/kord-dozor.sh"
echo "v3 положена: $(wc -c < "$HOME/kord-dozor.sh") байт (boot-строка без изменений — то же имя)"

nohup bash "$HOME/kord-dozor.sh" >/dev/null 2>&1 &
sleep 2
pgrep -f kord-dozor >/dev/null && echo "v3 бежит" || echo "v3 НЕ поднялась"

echo "-- ждём полный круг (75 сек) --"
sleep 75
ls -la "$HOME/kord-echo/дозор/" | grep -E "webfrl|digitaltender|python_jobs_ru|normrabota"

echo "-- хвост digitaltender (первые 12 строк) --"
head -12 "$HOME/kord-echo/дозор/digitaltender.txt" 2>/dev/null

echo "-- хвост webfrl (первые 12 строк) --"
head -12 "$HOME/kord-echo/дозор/webfrl.txt" 2>/dev/null

echo "откат: pkill -f kord-dozor"
echo "== 0081: конец =="
