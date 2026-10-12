#!/data/data/com.termux/files/usr/bin/bash
set -u
HOST='root@45.152.198.192'
SSH=(ssh -o BatchMode=yes -o ConnectTimeout=20 -o ServerAliveInterval=20 "$HOST")
echo '=== 0100: проверка стабилизации после лечения 0099 ==='
"${SSH[@]}" 'bash -s' <<'REMOTE'
set -u
UNIT='hermes-gateway.service'
systemctl --user status "$UNIT" --no-pager -p MainPID,ActiveState | sed 's/^/  /'
SINCE=$(date -Is -d '3 minutes ago' 2>/dev/null || date -Is)
echo "=== свежие строки Telegram за последние 3 минуты ==="
journalctl --user -u "$UNIT" --since "$SINCE" --no-pager 2>/dev/null | grep -E 'Telegram|fallback|ConnectError|recovered|polling|gateway' | tail -60 || echo '  новых строк Telegram не найдено'
echo '=== проверка доступа к api.telegram.org через /etc/hosts ==='
grep -n 'api.telegram.org' /etc/hosts || echo '  api.telegram.org не в /etc/hosts'
ss -tlnp 2>/dev/null | grep -E ':443' || echo '  порт 443 не занят туннелем'
echo '=== конец 0100 ==='
REMOTE
