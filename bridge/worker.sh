#!/usr/bin/env bash
# kord-worker: исполняет команды из очередь/*.cmd, пишет результат в статус/<токен>/ЖУРНАЛ.md
export GIT_TERMINAL_PROMPT=0
cd "$(dirname "$0")/.."
TOKEN=$(cat bridge/.status-token 2>/dev/null || echo "notoken")
LOG="статус/$TOKEN/ЖУРНАЛ.md"
mkdir -p "статус/$TOKEN" очередь .worker
while true; do
  git checkout -q -- очередь/ 2>/dev/null
  git pull -q 2>/dev/null
  for cmd in очередь/*.cmd; do
    [ -e "$cmd" ] || continue
    name=$(basename "$cmd" .cmd)
    h=$(sha256sum "$cmd" | cut -d' ' -f1)
    if [ -f ".worker/$name" ] && [ "$(cat ".worker/$name")" = "$h" ]; then continue; fi
    cp "$cmd" "/tmp/kord-cmd-$$"
    {
      echo
      echo "## $name — $(date '+%F %T')"
      echo '```'
      OUT=$(bash "/tmp/kord-cmd-$$" 2>&1); CODE=$?
      printf '%s\nexit=%s\n' "$OUT" "$CODE"
      echo '```'
    } >> "$LOG"
    rm -f "/tmp/kord-cmd-$$"
    echo "$h" > ".worker/$name"
    git checkout -q -- очередь/ 2>/dev/null
  done
  tail -400 "$LOG" > "$LOG.tmp" 2>/dev/null && mv "$LOG.tmp" "$LOG"
  sleep 10
done
