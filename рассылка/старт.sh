#!/usr/bin/env bash
# Кординапс — одна кнопка рассылки
# bash старт.sh      — отправка в фоне
# bash старт.sh тест — сухой прогон без отправки
set -u
cd "$(dirname "$0")"

if [ "${1:-}" = "тест" ]; then
  python3 otpravka.py --dry
else
  mkdir -p sessions
  [ -f конфиг.json ] || { echo 'НЕТ конфиг.json — см. README (создаётся на сервере, не в репо)'; exit 1; }
  nohup python3 otpravka.py >> рассылка.log 2>&1 &
  echo "Рассылка запущена в фоне, PID $!. Лог: рассылка.log, отчёт: отчёт-рассылки.txt"
fi
