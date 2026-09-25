#!/usr/bin/env bash
# Задание моста: обновление списка лидов на сервере (волна 2, 10 лидов)
set -u
BRIDGE="$(cd "$(dirname "$0")/.." && pwd)"
mkdir -p "$HOME/рассылка"
cp -r "$BRIDGE/рассылка/." "$HOME/рассылка/" 2>/dev/null || true
echo "— лиды на сервере обновлены: $(python3 -c "import json;print(len(json.load(open('$HOME/рассылка/лиды.json'))))" 2>/dev/null || echo ошибка)"
