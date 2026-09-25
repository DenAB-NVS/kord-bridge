#!/usr/bin/env bash
# Задание моста: синхронизация пожарного монитора на сервер
set -u
BRIDGE="$(cd "$(dirname "$0")/.." && pwd)"
mkdir -p "$HOME/рассылка"
cp -f "$BRIDGE/рассылка/mon-pozhar.py" "$HOME/рассылка/" 2>/dev/null || true
echo "— монитор пожарного потока синхронизирован: $( [ -f "$HOME/рассылка/mon-pozhar.py" ] && echo ДА || echo НЕТ )"
