#!/data/data/com.termux/files/usr/bin/bash
set -u
HOST='root@45.152.198.192'
SSH=(ssh -o BatchMode=yes -o ConnectTimeout=20 -o ServerAliveInterval=20 "$HOST")
echo '=== 0094: диагностика без изменений ==='
"${SSH[@]}" 'date -Is; hostname; uptime'
echo '=== процессы и сокеты ==='
"${SSH[@]}" 'ps -ef | grep -E "[h]ermes|[o]penclaw"; ss -lxnp | grep -E "hermes|openclaw" || true; ss -tlnp | grep :18789 || true'
echo '=== Hermes ==='
"${SSH[@]}" 'hermes gateway status 2>&1 || systemctl status hermes-agent --no-pager -l 2>&1 || true'
echo '=== OpenClaw ==='
"${SSH[@]}" 'openclaw gateway status --deep 2>&1 || systemctl status openclaw-gateway.service --no-pager -l 2>&1 || true'
echo '=== Telegram-туннель ==='
"${SSH[@]}" 'grep -n "api.telegram.org" /etc/hosts || true; ss -tlnp | grep :443 || true; curl --resolve api.telegram.org:443:127.0.0.1 -sS --max-time 15 -o /dev/null -w "telegram_http=%{http_code}\n" https://api.telegram.org/ || true'
echo '=== последние ошибки Hermes ==='
"${SSH[@]}" 'journalctl -u hermes-agent -n 120 --no-pager 2>&1 || true'
echo '=== последние ошибки OpenClaw ==='
"${SSH[@]}" 'openclaw logs --tail 120 2>&1 || journalctl -u openclaw-gateway.service -n 120 --no-pager 2>&1 || true'
echo '=== 0094: конец, никаких настроек не менялось ==='
