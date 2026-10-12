#!/data/data/com.termux/files/usr/bin/bash
set -u
HOST='root@45.152.198.192'
SSH=(ssh -o BatchMode=yes -o ConnectTimeout=20 -o ServerAliveInterval=20 "$HOST")
echo '=== 0093: начало ==='
echo '=== время и доступность ==='
"${SSH[@]}" 'date -Is; hostname; uptime'
echo '=== OpenClaw: статус до ==='
"${SSH[@]}" 'openclaw gateway status --deep 2>&1 || true'
echo '=== OpenClaw: штатный рестарт ==='
"${SSH[@]}" 'openclaw gateway restart 2>&1'
sleep 12
echo '=== OpenClaw: статус после ==='
"${SSH[@]}" 'openclaw gateway status --deep 2>&1 || true'
echo '=== Hermes: статус до ==='
"${SSH[@]}" 'hermes gateway status 2>&1 || systemctl status hermes-agent --no-pager -l 2>&1 || true'
echo '=== Hermes: штатный рестарт ==='
"${SSH[@]}" 'hermes gateway restart 2>&1 || systemctl restart hermes-agent 2>&1 || true'
sleep 12
echo '=== Hermes: статус после ==='
"${SSH[@]}" 'hermes gateway status 2>&1 || systemctl status hermes-agent --no-pager -l 2>&1 || true'
echo '=== последние журналы OpenClaw ==='
"${SSH[@]}" 'openclaw logs --tail 80 2>&1 || journalctl -u openclaw-gateway.service -n 80 --no-pager 2>&1 || true'
echo '=== последние журналы Hermes ==='
"${SSH[@]}" 'journalctl -u hermes-agent -n 80 --no-pager 2>&1 || true'
echo '=== 0093: конец ==='
