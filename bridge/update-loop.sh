#!/usr/bin/env bash
# Цикл моста: проверяем GitHub каждые 10 секунд
# Запуск под PM2: pm2 start bash --name kord-bridge-loop -- /root/kord-bridge/bridge/update-loop.sh
while true; do
  bash /root/kord-bridge/bridge/update.sh >> /var/log/kord-bridge.log 2>&1
  sleep 10
done
