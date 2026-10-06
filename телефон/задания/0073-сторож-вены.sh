#!/data/data/com.termux/files/usr/bin/bash
# Задание 0073 — СТОРОЖ ВЕНЫ v1 (ночь 06→07.10.2026)
# Цель: вена не умирает тихо. 3 молчания подряд (~15 минут) — будильник владельцу.
# Пишет ТОЛЬКО в свои файлы. Сервер не трогает. Одноразовое.
# Откат: pkill -f vena-watchdog; rm -f $HOME/vena-watchdog.sh $HOME/vena-watchdog.log $HOME/.vena-watchdog-*

echo "== 0073: сторож вены v1 =="

echo "-- разведка --"
if command -v termux-notification >/dev/null 2>&1; then echo "termux-notification: есть"; else echo "termux-notification: НЕТ (будильник деградирует до лога и тоста)"; fi
if command -v curl >/dev/null 2>&1; then echo "curl: есть"; else echo "curl: НЕТ — стоп, без него сторожу не жить"; exit 1; fi
if pgrep -f vena-watchdog >/dev/null 2>&1; then echo "сторож уже бежит — не ставим второй"; else echo "сторож не бежит — ставим"; fi

cat > "$HOME/vena-watchdog.sh" <<'VENAEOF'
#!/data/data/com.termux/files/usr/bin/bash
# СТОРОЖ ВЕНЫ v1 — из задания 0073. Пишет только в свои файлы.
LOG="$HOME/vena-watchdog.log"
STATE="$HOME/.vena-watchdog-fails"
NOTIF="$HOME/.vena-watchdog-notified"
LIMIT=3
COOLDOWN=1800
ts() { date '+%Y-%m-%d %H:%M:%S'; }
code=$(curl -m 10 -s -o /dev/null -w '%{http_code}' https://api.telegram.org 2>/dev/null)
if [ -n "$code" ] && [ "$code" != "000" ]; then echo 0 > "$STATE"; exit 0; fi
if ! ping -c 1 -W 5 1.1.1.1 >/dev/null 2>&1; then echo "$(ts) сам интернет лежит — не будим" >> "$LOG"; exit 0; fi
c=$(cat "$STATE" 2>/dev/null); c=${c:-0}; c=$((c+1)); echo "$c" > "$STATE"
echo "$(ts) вена молчит (проверка $c из $LIMIT)" >> "$LOG"
if [ "$c" -ge "$LIMIT" ]; then
  now=$(date +%s); last=$(cat "$NOTIF" 2>/dev/null); last=${last:-0}
  if [ $((now-last)) -ge $COOLDOWN ]; then
    echo "$(ts) ВЕНА ЛЕЖИТ — будим владельца" >> "$LOG"
    echo "$now" > "$NOTIF"
    termux-notification --title "СТОРОЖ ВЕНЫ: вена лежит" --content "api.telegram.org молчит ~15 минут. Включи VPN телефона; при необходимости перезапусти kord-tunnel." --priority high 2>>"$LOG" || termux-toast "ВЕНА ЛЕЖИТ — включи VPN" 2>>"$LOG"
  else
    echo "$(ts) будильник на кулдауне" >> "$LOG"
  fi
fi
VENAEOF
chmod +x "$HOME/vena-watchdog.sh"
echo "скрипт положен: $HOME/vena-watchdog.sh ($(wc -c < "$HOME/vena-watchdog.sh") байт)"

echo "-- тест на живой вене (ожидаем exit=0 и молчание) --"
bash "$HOME/vena-watchdog.sh"; echo "exit=$?"
echo "-- лог после теста --"
cat "$HOME/vena-watchdog.log" 2>/dev/null || echo "(лога нет — идеально тихо)"

if pgrep -f vena-watchdog >/dev/null 2>&1; then
  echo "цикл сторожа уже бежит"
else
  nohup bash -c 'while true; do bash "$HOME/vena-watchdog.sh"; sleep 300; done' >/dev/null 2>&1 &
  sleep 1
  echo "фоновый цикл запущен, каждые 5 минут"
fi

echo "-- примечания --"
echo "каденс: 5 минут; 3 молчания подряд = будильник; кулдаун будильника 30 минут"
echo "отличает мёртвую вену от мёртвого интернета"
echo "после перезагрузки телефона цикл поднимается заново (v2 — вписать в kord-sluzhba.sh)"
echo 'откат: pkill -f vena-watchdog; rm -f $HOME/vena-watchdog.sh $HOME/vena-watchdog.log $HOME/.vena-watchdog-*'
echo "== 0073: конец =="
