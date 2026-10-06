#!/data/data/com.termux/files/usr/bin/bash
# Задание 0079 — КАНДИДАТЫ В ДОЗОР: проверка живых каналов заказов (ночь 07.10)
# Цель: заменить мёртвые/закрытые уши спроса. Только чтение, ничего не подписывает и не пишет.
# Кандидаты из свежих сводок (leadradar, partnerkin, lpmotor, pikabu — 09–10.2026).

echo "== 0079: кандидаты в дозор =="

for ch in zakazy_it webprogrammists Solfreelance freelance_in_telegram poiskfreelance webfrl digitaltender normrabota chooseajob; do
  f="$HOME/.dz-cand-$ch.html"
  code=$(curl -sL -m 20 -A "Mozilla/5.0 (Windows NT 10.0; Win64; x64)" -o "$f" -w '%{http_code}' "https://t.me/s/$ch")
  size=$(wc -c < "$f" 2>/dev/null || echo 0)
  posts=$(grep -c "tgme_widget_message_text" "$f" 2>/dev/null || echo 0)
  title=$(grep -o '<title>[^<]*' "$f" 2>/dev/null | head -1 | sed 's/<title>//')
  echo "$ch: http=$code bytes=$size posts=$posts | $title"
  if [ "$posts" -gt 0 ] 2>/dev/null; then
    echo "  хвост последнего поста:"
    sed 's/></>\n</g' "$f" | sed -n '/tgme_widget_message_text/,/<\/div>/p' | sed 's/<[^>]*>//g' | tail -5 | head -4
  fi
  rm -f "$f"
done

echo "== 0079: конец =="
