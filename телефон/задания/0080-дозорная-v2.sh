#!/data/data/com.termux/files/usr/bin/bash
# Задание 0080 — ДОЗОРНАЯ V2: живые каналы заказов (ночь 07.10)
# Замена мёртвой петли (freelancetavern/distantsiya/it_freelance — пустые или превью закрыто).
# Новые главные уши: webfrl, digitaltender — заказы под ключ. Фон: python_jobs_ru, normrabota.
# Откат: pkill -f kord-dozor; запустить старую петлю невозможно (её список мёртв) — v2 и есть откат-путь.

echo "== 0080: дозорная v2 =="

echo "-- снимать старую петлю --"
OLD=$(pgrep -f "freelancetavern" || true)
if [ -n "$OLD" ]; then pkill -f "freelancetavern"; sleep 1; echo "старая петля снята (PID $OLD)"; else echo "старой петли не найдено"; fi

cat > "$HOME/kord-dozor.sh" <<'DZEOF'
#!/data/data/com.termux/files/usr/bin/bash
# Дозор v2 — каналы заказов (задание 0080, 07.10). Пишет только в ~/kord-echo/дозор/.
# Главные уши: webfrl, digitaltender (заказы под ключ). Фон: python_jobs_ru, normrabota.
while true; do
  for ch in webfrl digitaltender python_jobs_ru normrabota; do
    curl -s -m 20 -A "Mozilla/5.0" "https://t.me/s/$ch" \
      | sed "s/></>\n</g" \
      | sed -n "/tgme_widget_message_text/,/<\/div>/p" \
      | sed "s/<[^>]*>//g" \
      | head -c 30000 > "$HOME/kord-echo/дозор/$ch.txt" 2>/dev/null
  done
  sleep 300
done
DZEOF
chmod +x "$HOME/kord-dozor.sh"
echo "дозор v2 положен: $(wc -c < "$HOME/kord-dozor.sh") байт"

nohup bash "$HOME/kord-dozor.sh" >/dev/null 2>&1 &
sleep 1
pgrep -f kord-dozor >/dev/null && echo "новая петля бежит" || echo "петля НЕ поднялась"

BOOT="$HOME/.termux/boot/kord-boot.sh"
if [ -f "$BOOT" ]; then
  if grep -q "kord-dozor" "$BOOT"; then echo "в boot уже есть"; else
    cp "$BOOT" "$BOOT.bak-0080"
    cat >> "$BOOT" <<'BEOF'

# дозорная v2 (задание 0080) — уши спроса поднимаются с перезагрузкой
nohup bash "$HOME/kord-dozor.sh" >/dev/null 2>&1 &
BEOF
    echo "добавлена строка дозора в boot (бэкап .bak-0080)"
  fi
else
  echo "boot-файла нет — дозор после ребута поднимется вручную"
fi

echo "-- ждём первый снимок (50 сек) --"
sleep 50
ls -la "$HOME/kord-echo/дозор/" 2>/dev/null

echo "-- хвост digitaltender --"
tail -12 "$HOME/kord-echo/дозор/digitaltender.txt" 2>/dev/null | head -10

echo "-- хвост webfrl --"
tail -12 "$HOME/kord-echo/дозор/webfrl.txt" 2>/dev/null | head -10

echo "откат: pkill -f kord-dozor"
echo "== 0080: конец =="
