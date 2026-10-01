#!/data/data/com.termux/files/usr/bin/bash
# Кординапс — цикл моста v2 (телефон)
# Рука выполняет ТОЛЬКО телефон/задания/ — очередь/ принадлежит серверу.
# Будильник каждый цикл, эхо напрямую в GitHub.
BRIDGE="$HOME/kord-bridge"
ECHO="$HOME/kord-echo"
DONE="$HOME/kord-vypolneno.txt"
TS="$(date +%Y-%m-%d_%H-%M-%S)"

touch "$DONE"
command -v termux-wake-lock >/dev/null 2>&1 && termux-wake-lock

if [ -d "$BRIDGE/.git" ]; then
  git -C "$BRIDGE" fetch origin >/dev/null 2>&1
  BRANCH="$(git -C "$BRIDGE" rev-parse --abbrev-ref HEAD 2>/dev/null || echo main)"
  git -C "$BRIDGE" reset --hard "origin/$BRANCH" >/dev/null 2>&1
fi

OUT="$ECHO/эхо/$TS.md"
mkdir -p "$ECHO/эхо"
{
  echo "# Эхо $TS"
  echo
  echo "- время: $(date)"
  echo "- батарея: $(command -v termux-battery-status >/dev/null 2>&1 && termux-battery-status 2>/dev/null | tr -d '\n' | head -c 300 || echo 'недоступно')"
  echo "- диск: $(df -h "$HOME" 2>/dev/null | tail -1)"
  echo
} > "$OUT"

if [ -d "$BRIDGE/телефон/задания" ]; then
  for z in "$BRIDGE"/телефон/задания/*.sh; do
    [ -e "$z" ] || continue
    name="$(basename "$z")"
    grep -qxF "$name" "$DONE" && continue
    {
      echo "## Задание: $name"
      echo '```'
      bash "$z" 2>&1
      echo '```'
      echo
    } >> "$OUT"
    echo "$name" >> "$DONE"
  done
fi

if [ -d "$ECHO/.git" ]; then
  cd "$ECHO" || exit 0
  git add -A >/dev/null 2>&1
  git commit -m "эхо $TS" >/dev/null 2>&1
  git pull --rebase >/dev/null 2>&1
  git push >/dev/null 2>&1
fi
