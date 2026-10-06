#!/data/data/com.termux/files/usr/bin/bash
# Задание 0074 — СТОРОЖ ВЕНЫ В АВТОЗАПУСКЕ (ночь 06→07.10.2026)
# Цель: vena-watchdog переживает перезагрузку телефона.
# Правка одного файла: ~/.termux/boot/kord-boot.sh — добавление строк в конец, с бэкапом.
# Ничего больше не трогает. Откат: cp kord-boot.sh.bak-0074 kord-boot.sh

echo "== 0074: сторож вены в автозапуск =="

BOOT="$HOME/.termux/boot/kord-boot.sh"

if [ ! -d "$HOME/.termux/boot" ]; then
  echo "~/.termux/boot не существует — Termux:Boot не настроен, стоп без создания"
  exit 1
fi
if [ ! -f "$BOOT" ]; then
  echo "kord-boot.sh не найден — стоп, не создавать с нуля"
  exit 1
fi

if grep -q "vena-watchdog" "$BOOT" 2>/dev/null; then
  echo "строка сторожа уже есть в boot — не дублируем"
else
  cp "$BOOT" "$BOOT.bak-0074"
  cat >> "$BOOT" <<'BEOF'

# сторож вены (задание 0073) — подъём с перезагрузкой, по слову ВОССТАНОВЛЕНИЯ-МОСТА v2.1
nohup bash -c 'while true; do bash "$HOME/vena-watchdog.sh"; sleep 300; done' >/dev/null 2>&1 &
BEOF
  echo "строка сторожа добавлена в kord-boot.sh (бэкап: $BOOT.bak-0074)"
fi

echo "-- конец kord-boot.sh --"
tail -5 "$BOOT"
echo "-- проверка синтаксиса --"
bash -n "$BOOT" && echo "синтаксис ok"
echo "откат: cp $BOOT.bak-0074 $BOOT"
echo "== 0074: конец =="
