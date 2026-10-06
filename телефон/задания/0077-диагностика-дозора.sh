#!/data/data/com.termux/files/usr/bin/bash
# Задание 0077 — ДИАГНОСТИКА ДОЗОРА: почему три канала заказов мертвы (ночь 07.10)
# Цель: понять — каналы переименованы/закрыты или парсер сломался. Только чтение, ничего не меняет.
# Решает денежную цепь: сигнал спроса — первое звено цепи заказов.

echo "== 0077: диагностика дозора =="

echo "-- жива ли петля дозора --"
pgrep -af "t.me/s" | head -3 || echo "петля дозора НЕ НАЙДЕНА"

echo "-- каналы по одному: http-код, размер, число постов, заголовок страницы --"
for ch in freelancetavern distantsiya it_freelance python_jobs_ru; do
  f="$TMPDIR/dz_$ch.html"
  code=$(curl -sL -m 20 -A "Mozilla/5.0 (Windows NT 10.0; Win64; x64)" -o "$f" -w '%{http_code}' "https://t.me/s/$ch")
  size=$(wc -c < "$f" 2>/dev/null || echo 0)
  posts=$(grep -c "tgme_widget_message_text" "$f" 2>/dev/null || echo 0)
  title=$(grep -o '<title>[^<]*' "$f" 2>/dev/null | head -1 | sed 's/<title>//')
  echo "$ch: http=$code bytes=$size posts=$posts | $title"
  rm -f "$f"
done

echo "-- расшифровка --"
echo "posts=0 при http=200: канал существует, но веб-превью пусто (ограничен/переименован/нет постов)"
echo "http=302 или title без имени канала: канал переименован или удалён"
echo "python_jobs_ru живой — если и он posts=0, сломан сам парсер, а не каналы"

echo "-- дата последнего ненулевого снимка каждого канала (по эху) --"
ls -la "$HOME/kord-echo/дозор/" 2>/dev/null

echo "== 0077: конец =="
