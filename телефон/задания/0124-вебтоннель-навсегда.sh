#!/data/data/com.termux/files/usr/bin/bash
echo '=== 0124 ВЕБТУННЕЛЬ НАВСЕГДА ==='
# 1) автозапуск вместе с веной (boot)
BOOT="$HOME/.termux/boot/kord-boot.sh"
grep -q kord-webtunnel "$BOOT" 2>/dev/null || cat >> "$BOOT" <<'AB'
# веб-тоннели (fl.ru/капча/kwork через IP руки) — вечные циклы
pkill -f kord-webtunnel.sh 2>/dev/null
nohup bash "$HOME/kord-webtunnel.sh" >/dev/null 2>&1 &
AB
echo "boot: $(grep -c webtunnel "$BOOT") строк(и)"
# 2) поднять сейчас (не трогая, если живо)
if ! pgrep -f kord-webtunnel.sh >/dev/null; then
  setsid nohup "$HOME/kord-webtunnel.sh" >/dev/null 2>&1 &
  echo 'циклы подняты сейчас'
else
  echo 'циклы уже живы'
fi
sleep 12
pgrep -cf kord-webtunnel.sh | xargs echo 'процессов цикла:'
echo '=== КОНЕЦ 0124 ==='
