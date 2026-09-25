#!/usr/bin/env bash
# Задание моста: связка рассылки с тремя аккаунтами voen + сухой прогон
# Секреты в эхо НЕ печатаем — только факт нахождения
set -u
R="/root/рассылка"
mkdir -p "$R/sessions"

cp -f /root/voen/аккаунты/main.session   "$R/sessions/acc1.session" 2>/dev/null
cp -f /root/voen/аккаунты/второй.session "$R/sessions/acc2.session" 2>/dev/null
cp -f /root/voen/аккаунты/третий.session  "$R/sessions/acc3.session" 2>/dev/null
echo "— сессии связаны: $(ls "$R/sessions" 2>/dev/null | tr '\n' ' ')"

API_ID=""
API_HASH=""
for d in /root/voen /root/tg_insight; do
  [ -d "$d" ] || continue
  if [ -z "$API_ID" ]; then
    API_ID=$(grep -rhoE 'api_id[^0-9]{0,5}[0-9]+' "$d" --include='*.py' --include='*.json' --include='*.env' --include='*.txt' --include='*.sh' 2>/dev/null | grep -oE '[0-9]+' | head -1)
  fi
  if [ -z "$API_HASH" ]; then
    API_HASH=$(grep -rhoE 'api_hash[^a-f0-9]{0,5}[a-f0-9]{20,}' "$d" --include='*.py' --include='*.json' --include='*.env' --include='*.txt' --include='*.sh' 2>/dev/null | grep -oE '[a-f0-9]{20,}' | head -1)
  fi
done

if [ -n "$API_ID" ] && [ -n "$API_HASH" ]; then
  cat > "$R/конфиг.json" <<EOF
{"api_id": $API_ID, "api_hash": "$API_HASH", "sessions": ["acc1", "acc2", "acc3"], "pause": [240, 600]}
EOF
  chmod 600 "$R/конфиг.json"
  echo "— конфиг создан: ДА (api_id: $API_ID, api_hash скрыт)"
else
  echo "— конфиг НЕ создан: api_id=$API_ID, api_hash=$([ -n "$API_HASH" ] && echo найден || echo не найден). Спросить владельца."
fi

if [ -f "$R/конфиг.json" ]; then
  echo "— сухой прогон (без отправки):"
  cd "$R" && python3 otpravka.py --dry 2>&1 | head -20
else
  echo "— сухой прогон пропущен: нет конфига"
fi
