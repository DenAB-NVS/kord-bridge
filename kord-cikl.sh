#!/data/data/com.termux/files/usr/bin/bash
# Кординапс — цикл моста v3 (телефон)
# Проверка заданий: каждые 30 секунд (задаёт kord-sluzhba.sh).
# Эхо: сразу при выполненном задании/изменении дозора; пульс здоровья — раз в 10 минут.
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
OUT="$ECHO/эхо/$TS.md"
mkdir -p "$ECHO/эхо"

if [ -d "$BRIDGE/телефон/задания" ]; then
  for z in "$BRIDGE"/телефон/задания/*.sh; do
    [ -e "$z" ] || continue
    name="$(basename "$z")"
    grep -qxF "$name" "$DONE" && continue
    {
      echo "# Эхо $TS"
      echo
      echo "## Задание: $name"
      echo '```'
      bash "$z" 2>&1
      echo '```'
    } > "$OUT"
    echo "$name" >> "$DONE"
    RAN=1
  done
fi

LAST_TS=0
[ -f "$LAST" ] && LAST_TS="$(cat "$LAST" 2>/dev/null || echo 0)"
PULSE=0
[ $((NOW - LAST_TS)) -ge 600 ] && PULSE=1

if [ "$PULSE" -eq 1 ]; then
  {
    echo "# Эхо $TS"
    echo
    echo "- время: $(date)"
    echo "- батарея: $(command -v termux-battery-status >/dev/null 2>&1 && termux-battery-status 2>/dev/null | tr -d '\n' | head -c 300 || echo 'недоступно')"
    echo "- диск: $(df -h "$HOME" 2>/dev/null | tail -1)"
    echo "- цикл: проверка заданий каждые 30 секунд; пульс каждые 10 минут"
  } > "$OUT"
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
