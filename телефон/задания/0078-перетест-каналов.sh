#!/data/data/com.termux/files/usr/bin/bash
# Задание 0078 — ПЕРЕТЕСТ КАНАЛОВ (исправленный путь вывода). Ночь 07.10.
# 0077 писало в несуществующий TMPDIR — http=000 был моей ошибкой, не диагнозом каналов.
# Только чтение. Кандидатов на замену не трогаем — отдельным заданием.

echo "== 0078: перетест каналов (путь исправлен) =="

for ch in freelancetavern distantsiya it_freelance; do
  f="$HOME/.dz-test-$ch.html"
  code=$(curl -sL -m 20 -A "Mozilla/5.0 (Windows NT 10.0; Win64; x64)" -o "$f" -w '%{http_code}' "https://t.me/s/$ch")
  size=$(wc -c < "$f" 2>/dev/null || echo 0)
  posts=$(grep -c "tgme_widget_message_text" "$f" 2>/dev/null || echo 0)
  title=$(grep -o '<title>[^<]*' "$f" 2>/dev/null | head -1 | sed 's/<title>//')
  echo "$ch: http=$code bytes=$size posts=$posts | $title"
  if [ "$posts" -gt 0 ] 2>/dev/null; then
    echo "  первые строки последнего поста:"
    sed 's/></>\n</g' "$f" | sed -n '/tgme_widget_message_text/,/<\/div>/p' | sed 's/<[^>]*>//g' | tail -8 | head -6
  fi
  rm -f "$f"
done

echo "== 0078: конец =="
