#!/data/data/com.termux/files/usr/bin/bash
set -u
HOST='root@45.152.198.192'
SSH=(ssh -o BatchMode=yes -o ConnectTimeout=20 -o ServerAliveInterval=20 "$HOST")
echo '=== 0099: лечение Telegram Hermes — обратимый пакет ==='
"${SSH[@]}" 'bash -s' <<'REMOTE'
set -u
HOST_ENV='/root/.hermes/.env'
IP=149.154.166.110
BACKUP="/root/.hermes/.env.bak-$(date +%Y%m%d-%H%M%S)"
UNIT='hermes-gateway.service'

echo '=== 0099A: предварительные проверки ==='
if ! systemctl --user status "$UNIT" --no-pager >/dev/null 2>&1; then
  echo "ОШИБКА: $UNIT не найдена, изменения не применяются"
  exit 10
fi
systemctl --user show "$UNIT" --no-pager -p MainPID,ActiveState | sed 's/^/  /'
if [ ! -f "$HOST_ENV" ]; then
  echo "ОШИБКА: $HOST_ENV не найден, изменения не применяются"
  exit 11
fi
NAT_PRESENT='no'
if command -v iptables >/dev/null 2>&1 && iptables -t nat -C OUTPUT -p tcp -d "$IP" --dport 443 -j DNAT --to-destination 127.0.0.1:443 2>/dev/null; then
  NAT_PRESENT='yes'
fi
echo "  наличие NAT-правила 0096: $NAT_PRESENT"

echo '=== 0099B: резервная копия .env (не в эхо) ==='
install -m 600 -o root -g root "$HOST_ENV" "$BACKUP"
echo "  backup создан: $BACKUP (содержимое не выводится)"

echo '=== 0099C: добавление HERMES_TELEGRAM_DISABLE_FALLBACK_IPS ==='
if grep -qE '^HERMES_TELEGRAM_DISABLE_FALLBACK_IPS=' "$HOST_ENV"; then
  echo '  параметр уже присутствует, новая строка не добавляется'
else
  printf '\n# added by 0099: prevent Telegram fallback IPs to keep tunnel path\nHERMES_TELEGRAM_DISABLE_FALLBACK_IPS=true\n' >> "$HOST_ENV"
  echo '  параметр добавлен'
fi
grep -c '^' "$HOST_ENV" | sed 's/^/  всего строк в .env: /'

echo '=== 0099D: перезапуск службы ==='
if systemctl --user restart "$UNIT" 2>&1; then
  echo '  перезапуск выполнен'
else
  echo 'ОШИБКА: перезапуск не удался, .env откатываем'
  mv "$BACKUP" "$HOST_ENV"
  systemctl --user restart "$UNIT" || true
  exit 12
fi

echo '=== 0099E: удаление NAT-правила 0096 (только совпавшее) ==='
if [ "$NAT_PRESENT" = 'yes' ]; then
  if iptables -t nat -D OUTPUT -p tcp -d "$IP" --dport 443 -j DNAT --to-destination 127.0.0.1:443 2>&1; then
    echo '  правило удалено'
  else
    echo 'ОШИБКА: не удалось удалить правило, откатываем .env'
    mv "$BACKUP" "$HOST_ENV"
    systemctl --user restart "$UNIT" || true
    exit 13
  fi
else
  echo '  правила нет, удаление не требуется'
fi

echo '=== 0099F: подождать стабилизацию и проверить новые журналы ==='
sleep 45
systemctl --user status "$UNIT" --no-pager -p MainPID,ActiveState | sed 's/^/  /'
SINCE=$(date -Is -d '50 seconds ago' 2>/dev/null || date -Is)
journalctl --user -u "$UNIT" --since "$SINCE" --no-pager 2>/dev/null | tail -80 | grep -E 'Telegram|fallback|ConnectError|recovered|polling' | head -40 || echo '  новых строк Telegram не найдено'

echo '=== 0099: конец ==='
echo "Итог: .env изменён (HERMES_TELEGRAM_DISABLE_FALLBACK_IPS=true), NAT-правило 0096 удалено, служба перезапущена. Backup: $BACKUP"
REMOTE
