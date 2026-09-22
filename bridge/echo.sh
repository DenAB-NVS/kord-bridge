#!/usr/bin/env bash
# ЭХО — петля обратной связи от терминала.
# Ловит вывод команды, дописывает в echo/ответ-терминала.md
# и коммитит обратно в kord-bridge. Секретов не содержит.
#
# Использование:
#   ./bridge/echo.sh                 — самопроверка сервера
#   ./bridge/echo.sh "команда"       — вернуть вывод команды

set -uo pipefail
cd "$(dirname "${BASH_SOURCE[0]}")/.." || exit 1

ECHO_FILE="echo/ответ-терминала.md"
STAMP="$(date '+%Y-%m-%d %H:%M:%S %Z')"
CMD="${1:-}"
MAX_LINES=200

OUT="$(mktemp)"

if [ -n "$CMD" ]; then
  bash -c "$CMD" >"$OUT" 2>&1
else
  {
    echo "hostname: $(hostname)"
    echo "uptime:   $(uptime -p 2>/dev/null || uptime)"
    echo "диск:     $(df -h / | tail -n 1)"
    echo "ветка:    $(git branch --show-current)"
    echo "коммит:   $(git log -1 --oneline)"
    if command -v pm2 >/dev/null 2>&1; then
      echo "pm2:      $(pm2 jlist 2>/dev/null | head -c 300)"
    else
      echo "pm2:      не установлен"
    fi
  } >"$OUT" 2>&1
fi
CODE=$?

mkdir -p echo
{
  echo ""
  echo "## $STAMP — ${CMD:-самопроверка сервера}"
  echo ""
  echo "- код выхода: $CODE"
  echo ""
  echo '```'
  head -n "$MAX_LINES" "$OUT"
  echo '```'
} >>"$ECHO_FILE"

rm -f "$OUT"

git add "$ECHO_FILE"
if git commit -m "эхо: ${CMD:-самопроверка} @ $STAMP" >/dev/null 2>&1; then
  if git push origin HEAD >/dev/null 2>&1; then
    echo "эхо отправлено: $ECHO_FILE"
  else
    echo "эхо записано локально, push не прошёл — проверь ключ"
    exit 2
  fi
else
  echo "нечего коммитить — вывод пуст или нет изменений"
fi
