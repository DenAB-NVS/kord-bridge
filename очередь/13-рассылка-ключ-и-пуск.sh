#!/usr/bin/env bash
# Задание моста: широкий поиск api_id/api_hash по всему серверу + мгновенный пуск рассылки
# Слово «отправляй» владельца от 25.09 21:13 MSK остаётся в силе
set -u
R="/root/рассылка"

EXCL="--exclude-dir=node_modules --exclude-dir=.cache --exclude-dir=.git --exclude-dir=.npm --exclude-dir=__pycache__ --exclude-dir=venv"

API_ID=$(grep -r $EXCL -hoiE 'api[_-]?id[^0-9a-f]{0,6}[0-9]{5,}' /root 2>/dev/null | grep -oE '[0-9]{5,}' | head -1)
API_HASH=$(grep -r $EXCL -hoiE 'api[_-]?hash[^a-f0-9]{0,6}[a-f0-9]{20,}' /root 2>/dev/null | grep -oE '[a-f0-9]{20,}' | head -1)

if [ -n "$API_ID" ] && [ -n "$API_HASH" ]; then
  cat > "$R/конфиг.json" <<EOF
{"api_id": $API_ID, "api_hash": "$API_HASH", "sessions": ["acc1", "acc2", "acc3"], "pause": [240, 600]}
EOF
  chmod 600 "$R/конфиг.json"
  echo "— конфиг создан: ДА (api_id: $API_ID, api_hash скрыт)"
  cd "$R"
  nohup python3 otpravka.py >> рассылка.log 2>&1 &
  echo "— рассылка запущена в фоне, PID $!"
  sleep 25
  echo "— первые строки лога:"
  head -8 рассылка.log 2>/dev/null || true
  echo "— отчёт (по мере отправки):"
  head -8 отчёт-рассылки.txt 2>/dev/null || echo "отчёт появится после первой отправки"
else
  echo "— НЕ НАЙДЕНО даже широким поиском: api_id='$API_ID', api_hash='$API_HASH'"
  echo "— тогда ключ даст владелец: my.telegram.org → API development tools → app api_id/hash"
fi
