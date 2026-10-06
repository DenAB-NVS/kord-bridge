#!/data/data/com.termux/files/usr/bin/bash
# Задание 0076 — ЦИКЛ V4: КАЖДОМУ ГОЛОСУ — СВОЙ ФАЙЛ (ночь 06→07.10)
# Лечит шов: в одном такте выживало только последнее задание (0055, 0066–0067, 0069, и сейчас 0074 — эхо съедено в такте 01-02-16).
# Хирургия: бэкап kord-cikl.sh → новый v4 → bash -n → на место. Откат: cp kord-cikl.sh.bak-v3 kord-cikl.sh
# Также верифицирует 0074 (boot-файл), чьё эхо съел шов.

echo "== 0076: цикл v4 =="

CIKL="$HOME/kord-cikl.sh"

 echo "-- верификация 0074 (эхо съедено швом в такте 01-02-16) --"
BOOT="$HOME/.termux/boot/kord-boot.sh"
if grep -q "vena-watchdog" "$BOOT" 2>/dev/null; then echo "0074 ОК: сторож в автозапуске есть"; else echo "0074 НЕ ВЫПОЛНЕН: строки в boot нет"; fi
bash -n "$BOOT" 2>/dev/null && echo "синтаксис boot ok"
tail -3 "$BOOT" 2>/dev/null

echo "-- бэкап цикла --"
cp "$CIKL" "$CIKL.bak-v3"
echo "бэкап: $CIKL.bak-v3 ($(wc -c < "$CIKL.bak-v3") байт)"

cat > "$CIKL.new" <<'CIKLEOF'
#!/data/data/com.termux/files/usr/bin/bash
# Кординапс — цикл моста v4 (телефон)
# Проверка заданий: каждые 30 секунд (задаёт kord-sluzhba.sh).
# Эхо v4: каждому заданию — СВОЙ файл (эхо/<TS>-<NNNN>-<имя>.md); пульс — отдельный файл в пульс/.
# Лечит шов, съедавший голоса: 0055, 0066–0067, 0069, 0074.
# Рука выполняет ТОЛЬКО телефон/задания/.

BRIDGE="$HOME/kord-bridge"
ECHO="$HOME/kord-echo"
DONE="$HOME/kord-vypolneno.txt"
LAST="$HOME/.kord-last-pulse"
TS="$(date +%Y-%m-%d_%H-%M-%S)"
NOW="$(date +%s)"

touch "$DONE"
command -v termux-wake-lock >/dev/null 2>&1 && termux-wake-lock

if [ -d "$BRIDGE/.git" ]; then
  git -C "$BRIDGE" fetch origin >/dev/null 2>&1
  BRANCH="$(git -C "$BRIDGE" rev-parse --abbrev-ref HEAD 2>/dev/null || echo main)"
  git -C "$BRIDGE" reset --hard "origin/$BRANCH" >/dev/null 2>&1
fi

RAN=0
mkdir -p "$ECHO/эхо" "$ECHO/пульс"

if [ -d "$BRIDGE/телефон/задания" ]; then
  for z in "$BRIDGE"/телефон/задания/*.sh; do
    [ -e "$z" ] || continue
    name="$(basename "$z")"
    grep -qxF "$name" "$DONE" && continue
    ZOUT="$ECHO/эхо/${TS}-${name%.sh}.md"
    {
      echo "# Эхо $TS"
      echo
      echo "## Задание: $name"
      echo '```'
      bash "$z" 2>&1
      echo '```'
    } > "$ZOUT"
    echo "$name" >> "$DONE"
    RAN=1
  done
fi

LAST_TS=0
[ -f "$LAST" ] && LAST_TS="$(cat "$LAST" 2>/dev/null || echo 0)"
PULSE=0
[ $((NOW - LAST_TS)) -ge 600 ] && PULSE=1

if [ "$PULSE" -eq 1 ]; then
  POUT="$ECHO/пульс/пульс-$TS.md"
  {
    echo "# Пульс $TS"
    echo
    echo "- время: $(date)"
    echo "- батарея: $(command -v termux-battery-status >/dev/null 2>&1 && termux-battery-status 2>/dev/null | tr -d '\n' | head -c 300 || echo 'недоступно')"
    echo "- диск: $(df -h "$HOME" 2>/dev/null | tail -1)"
    echo "- цикл v4: каждое задание — свой файл эха; пульс — свой файл"
  } > "$POUT"
  echo "$NOW" > "$LAST"
fi

if [ -d "$ECHO/.git" ]; then
  cd "$ECHO" || exit 0
  if [ -n "$(git status --porcelain 2>/dev/null)" ]; then
    git add -A >/dev/null 2>&1
    git commit -m "эхо $TS" >/dev/null 2>&1
    git pull --rebase >/dev/null 2>&1
    git push >/dev/null 2>&1
  fi
fi
CIKLEOF

echo "-- проверка синтаксиса нового цикла --"
if bash -n "$CIKL.new" 2>&1; then
  echo "синтаксис ok — ставим на место"
  mv "$CIKL.new" "$CIKL"
  echo "цикл v4 установлен: $(wc -c < "$CIKL") байт"
else
  echo "СИНТАКСИС ПЛОХОЙ — на место НЕ ставим, рабочий цикл не тронут"
  rm -f "$CIKL.new"
  exit 1
fi

echo "-- дифф со старым циклом --"
diff "$CIKL.bak-v3" "$CIKL" || true

echo "следующий такт (~30 сек) идёт уже на v4: каждое задание пишет свой файл, пульс — свой"
echo "откат: cp $CIKL.bak-v3 $CIKL"
echo "== 0076: конец =="
