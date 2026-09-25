#!/usr/bin/env bash
# Задание моста: установка модуля рассылки + инвентаризация для пульта
set -u
BRIDGE="$(cd "$(dirname "$0")/.." && pwd)"
HOME_DIR="$HOME"

mkdir -p "$HOME_DIR/рассылка"
cp -r "$BRIDGE/рассылка/." "$HOME_DIR/рассылка/" 2>/dev/null || true
chmod +x "$HOME_DIR/рассылка/старт.sh" "$HOME_DIR/рассылка/otpravka.py" 2>/dev/null || true

python3 -c "import telethon" 2>/dev/null || pip3 install --quiet telethon || pip3 install telethon

echo "— telethon: $(python3 -c 'import telethon; print(telethon.__version__)' 2>/dev/null || echo НЕ СТОИТ)"
echo "— модуль рассылки: $HOME_DIR/рассылка"
echo "— конфиг: $( [ -f "$HOME_DIR/рассылка/конфиг.json" ] && echo ЕСТЬ || echo НЕТ — создать по README )"
echo "— лидов в очереди: $(python3 -c "import json;print(len(json.load(open('$HOME_DIR/рассылка/лиды.json'))))" 2>/dev/null || echo 0)"
echo "— сессии (*.session) на этой машине:"
find "$HOME_DIR" -maxdepth 4 -name '*.session' 2>/dev/null | head -20 || true
echo "— PM2:"
pm2 ls 2>/dev/null | head -30 || echo pm2 недоступен
echo "— где живёт admin-бот (для пульта-кнопки):"
find "$HOME_DIR" -maxdepth 3 -type d \( -name 'admin*' -o -name '*pult*' \) 2>/dev/null | head -10 || true
