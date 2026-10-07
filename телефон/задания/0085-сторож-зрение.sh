#!/data/data/com.termux/files/usr/bin/bash
# Задание 0085 — СТОРОЖУ ЗРЕНИЕ: HTTP-проверка интернета вместо ping (ночь 07.10)
# Рана из 0084: ping (ICMP) через VPN телефона не ходит — сторож считал живой интернет
# мёртвым и не будил при падении вены. Лечение: проверять интернет HTTP-запросом.
# Откат: cp vena-watchdog.sh.bak-v1 vena-watchdog.sh; перезапуск петли — как в 0073.

echo "== 0085: сторожу зрение =="

WD="$HOME/vena-watchdog.sh"
[ -f "$WD" ] || { echo "сторожа нет — стоп"; exit 1; }

cp "$WD" "$WD.bak-v1"
echo "бэкап: $WD.bak-v1"

cat > "$WD" <<'VENAEOF'
#!/data/data/com.termux/files/usr/bin/bash
# СТОРОЖ ВЕНЫ v1.1 — задание 0085. Пишет только в свои файлы.
# v1.1: интернет проверяется HTTP (example.com), не ping — ICMP через VPN не ходит (0084).
LOG="$HOME/vena-watchdog.log"
STATE="$HOME/.vena-watchdog-fails"
NOTIF="$HOME/.vena-watchdog-notified"
LIMIT=3
COOLDOWN=1800
ts() { date '+%Y-%m-%d %H:%M:%S'; }
code=$(curl -m 10 -s -o /dev/null -w '%{http_code}' https://api.telegram.org 2>/dev/null)
if [ -n "$code" ] && [ "$code" != "000" ]; then echo 0 > "$STATE"; exit 0; fi
net=$(curl -m 8 -s -o /dev/null -w '%{http_code}' https://example.com 2>/dev/null)
if [ -z "$net" ] || [ "$net" = "000" ]; then echo "$(ts) сам интернет лежит (HTTP-проверка) — не будим" >> "$LOG"; exit 0; fi
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
chmod +x "$WD"
bash -n "$WD" && echo "синтаксис ok" || { echo "СИНТАКСИС ПЛОХОЙ — откат"; cp "$WD.bak-v1" "$WD"; exit 1; }

echo "-- перезапуск петли сторожа --"
pkill -f vena-watchdog 2>/dev/null; sleep 1
nohup bash -c 'while true; do bash "$HOME/vena-watchdog.sh"; sleep 300; done' >/dev/null 2>&1 &
sleep 1
pgrep -f vena-watchdog >/dev/null && echo "петля сторожа бежит (v1.1)" || echo "петля НЕ поднялась"

echo "-- тест на живой вене --"
bash "$WD"; echo "exit=$?"
cat "$HOME/.vena-watchdog-fails" 2>/dev/null

echo "-- разница v1 → v1.1 --"
diff "$WD.bak-v1" "$WD" || true

echo "откат: cp $WD.bak-v1 $WD; pkill -f vena-watchdog; nohup bash -c 'while true; do bash \"\$HOME/vena-watchdog.sh\"; sleep 300; done' &"
echo "== 0085: конец =="
