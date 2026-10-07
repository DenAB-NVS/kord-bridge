#!/data/data/com.termux/files/usr/bin/bash
# Задание 0088 — ГАЗЕТА-100: снимок истории 10 каналов владельца для разбора по полкам (07.10, вечер)
# Слово владельца 21:01: каналы перечислены, 100 дней на канал достаточно.
# История через веб-превью t.me/s пагинацией ?before=ID (та же дверь, что у дозорной).
# Законы: прогрев холодного туннеля; 2 попытки на страницу; писать во временный файл —
# пустой fetch не затирает прежний (закон 0087); паузы между страницами 3с.
# Выход: ~/kord-echo/газета/<канал>.md (## дата + текст поста) + лог kord-gazeta.log.
# Цикл v4 сам унесёт файлы в эхо. Откат: rm -rf ~/kord-echo/газета

echo "== 0088: газета-100 =="

D="$HOME/kord-echo/газета"
mkdir -p "$D"
LOG="$HOME/kord-gazeta.log"

CUTOFF=$(date -d '100 days ago' +%s 2>/dev/null || echo 0)
echo "окно: 100 дней, cutoff=$CUTOFF ($(date -d '100 days ago' '+%Y-%m-%d' 2>/dev/null))"

# прогрев холодного туннеля (закон ночи 07.10)
curl -s -m 25 -A "Mozilla/5.0" "https://t.me/s/AI_NewsDailyTrends" >/dev/null 2>&1

CHANNELS="AI_NewsDailyTrends Getitrussia notboring_tech NeuralProfit sudoteach data_secrets ai_newz vibecoding_tg denissexy whackdoor"

for ch in $CHANNELS; do
  f="$D/$ch.md"
  t="$HOME/.gz-$ch.tmp"
  : > "$t"
  before=""
  pages=0
  while [ $pages -lt 40 ]; do
    url="https://t.me/s/$ch"
    [ -n "$before" ] && url="$url?before=$before"
    page=""
    for try in 1 2; do
      page=$(curl -s -m 25 -A "Mozilla/5.0" "$url")
      [ -n "$page" ] && break
      sleep 3
    done
    [ -n "$page" ] || { echo "$(date '+%H:%M:%S') $ch: страница не получена (стр.$pages), стоп канала" >> "$LOG"; break; }

    ids=$(echo "$page" | grep -o 'data-post="[^"]*"' | sed 's/data-post="[^\/]*\///;s/"//' | sort -n)
    [ -n "$ids" ] || break
    newbefore=$(echo "$ids" | head -1)
    { [ -z "$newbefore" ] || [ "$newbefore" = "$before" ]; } && break
    before=$newbefore
    pages=$((pages+1))

    echo "$page" | sed 's/></>\n</g' | awk '
      /<time datetime=/ {
        match($0, /datetime="[^"]*"/); d=substr($0, RSTART+10, RLENGTH-11);
        if (buf != "") { printf "\n## %s\n%s", d, buf; buf="" }
        next
      }
      /tgme_widget_message_text/ { intext=1; sub(/^[^>]*>/, ""); if ($0 != "") buf=buf $0 "\n"; next }
      intext && /<\/div>/ { intext=0; next }
      intext { gsub(/<[^>]*>/, ""); buf=buf $0 "\n" }
    ' >> "$t"

    # старейшая дата на странице — стоп при выходе за окно 100 дней
    old=$(echo "$page" | grep -o 'datetime="[^"]*"' | sed 's/datetime="//;s/"//' | head -1)
    if [ -n "$old" ] && [ "$CUTOFF" -gt 0 ]; then
      oe=$(date -d "$old" +%s 2>/dev/null || echo 0)
      [ "$oe" -gt 0 ] && [ "$oe" -lt "$CUTOFF" ] && { echo "$(date '+%H:%M:%S') $ch: дошли до края окна ($old)" >> "$LOG"; break; }
    fi

    # потолок размера на канал — 400 КБ
    [ "$(wc -c < "$t")" -gt 400000 ] && { echo "$(date '+%H:%M:%S') $ch: потолок 400КБ, стоп канала" >> "$LOG"; break; }

    sleep 3
  done

  if [ -s "$t" ]; then
    mv "$t" "$f"
    sz=$(wc -c < "$f"); cnt=$(grep -c '^## ' "$f" 2>/dev/null || echo 0)
    echo "$(date '+%Y-%m-%d %H:%M:%S') $ch: $cnt постов, $sz байт, $pages страниц" | tee -a "$LOG"
  else
    rm -f "$t"
    echo "$(date '+%Y-%m-%d %H:%M:%S') $ch: ПУСТО — канал закрыт/недоступен, прежний снимок (если был) цел" | tee -a "$LOG"
  fi
done

rm -f "$HOME"/.gz-*.tmp
echo "-- итог по папке --"
ls -la "$D" 2>/dev/null | tail -12
echo "откат: rm -rf $D ; лог: $LOG"
echo "== 0088: конец =="
