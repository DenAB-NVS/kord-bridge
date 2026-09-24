#!/data/data/com.termux/files/usr/bin/bash
# Кординапс — цикл моста: задания из очереди -> исполнение -> эхо
BRIDGE="$HOME/kord-bridge"
ECHO="$HOME/kord-echo"
DONE="$HOME/kord-vypolneno.txt"
TS="$(date +%Y-%m-%d_%H-%M-%S)"

touch "$DONE"

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

if [ -d "$BRIDGE/очередь" ]; then
  for z in "$BRIDGE"/очередь/*.sh; do
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
  git push >/dev/null 2>&1
fi
