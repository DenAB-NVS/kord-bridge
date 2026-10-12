#!/data/data/com.termux/files/usr/bin/bash
set -u
HOST='root@45.152.198.192'
SSH=(ssh -o BatchMode=yes -o ConnectTimeout=20 -o ServerAliveInterval=20 "$HOST")
echo '=== 0103: перезапуск зависшего туннеля ==='
"${SSH[@]}" 'bash -s' <<'REMOTE'
set -u
P=$(ss -tlnp 2>/dev/null | awk '$4=="127.0.0.1:443"' | grep -o 'pid=[0-9]*' | head -1 | cut -d= -f2)
echo "tunnel_pid=$P"
if [ -n "$P" ]; then kill "$P" && echo 'зависшее подключение туннеля оборвано'; else echo 'слушателя 443 нет'; fi
REMOTE
echo '--- ждём переподъёма туннеля телефоном ---'
sleep 45
pgrep -af 'ssh -N -R' || pgrep -af kord-tunnel
"${SSH[@]}" 'bash -s' <<'REMOTE'
set -u
ss -tlnp 2>/dev/null | awk '$4=="127.0.0.1:443"' | sed 's/^/listen: /'
curl --noproxy '*' --resolve api.telegram.org:443:127.0.0.1 --connect-timeout 5 --max-time 15 -sS -o /dev/null -w 'server_http=%{http_code} time=%{time_total}\n' https://api.telegram.org/ 2>&1; echo "server_exit=$?"
sleep 30
systemctl --user show hermes-gateway.service -p ActiveState | sed 's/^/hermes /'
systemctl --user show openclaw-gateway.service -p ActiveState | sed 's/^/openclaw /'
journalctl --user -u hermes-gateway.service --since '90 seconds ago' --no-pager 2>/dev/null | grep -E 'Telegram' | grep -vE 'python3 -I' | tail -8
echo '=== конец 0103 ==='
REMOTE
