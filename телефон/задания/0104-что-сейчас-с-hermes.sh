#!/data/data/com.termux/files/usr/bin/bash
set -u
HOST='root@45.152.198.192'
SSH=(ssh -o BatchMode=yes -o ConnectTimeout=20 -o ServerAliveInterval=20 "$HOST")
echo '=== 0104: только чтение ==='
pgrep -af 'ssh -N -R' || echo 'туннель на телефоне НЕ запущен'
"${SSH[@]}" 'bash -s' <<'REMOTE'
set -u
ss -tlnp 2>/dev/null | awk '$4=="127.0.0.1:443"' | sed 's/^/listen: /'
curl --noproxy '*' --resolve api.telegram.org:443:127.0.0.1 --connect-timeout 5 --max-time 15 -sS -o /dev/null -w 'server_http=%{http_code} time=%{time_total}\n' https://api.telegram.org/ 2>&1; echo "server_exit=$?"
systemctl --user show hermes-gateway.service -p ActiveState,MainPID | sed 's/^/hermes /'
systemctl --user show openclaw-gateway.service -p ActiveState | sed 's/^/openclaw /'
M=$(systemctl --user show hermes-gateway.service -p MainPID --value)
echo '--- что сейчас исполняет Hermes (дочерние процессы, первые 120 символов) ---'
[ -n "$M" ] && ps --ppid "$M" -o pid,etime,args --no-headers 2>/dev/null | cut -c1-120
echo '--- последние строки Telegram/агента Hermes ---'
journalctl --user -u hermes-gateway.service --since '20 minutes ago' --no-pager 2>/dev/null | grep -E 'Telegram|approval|tool|error|ERROR' | grep -v 'python3 -I' | tail -15 | cut -c1-220
echo '=== конец 0104 ==='
REMOTE
