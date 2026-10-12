#!/data/data/com.termux/files/usr/bin/bash
set -u
HOST='root@45.152.198.192'
SSH=(ssh -o BatchMode=yes -o ConnectTimeout=20 -o ServerAliveInterval=20 "$HOST")
echo '=== 0101: остановить только Hermes, проверить OpenClaw ==='
"${SSH[@]}" 'bash -s' <<'REMOTE'
set -u
echo '=== A: остановка Hermes (служба не удаляется, .env и память не трогаются) ==='
systemctl --user stop hermes-gateway.service 2>&1
echo "stop_exit=$?"
sleep 3
systemctl --user show hermes-gateway.service --no-pager -p ActiveState,SubState,MainPID | sed 's/^/  /'
echo '=== B: OpenClaw — состояние ==='
openclaw gateway status --deep 2>&1 | head -30
echo '=== C: OpenClaw — свежие строки Telegram/ошибок за 10 минут ==='
for U in openclaw-gateway.service openclaw.service; do
  if systemctl --user cat "$U" >/dev/null 2>&1; then
    echo "unit=$U"
    systemctl --user show "$U" --no-pager -p ActiveState,SubState,MainPID | sed 's/^/  /'
    journalctl --user -u "$U" --since '10 minutes ago' --no-pager 2>/dev/null | grep -iE 'telegram|error|429|timed out|timeout|connect|ready|polling' | tail -20
  fi
done
echo '=== D: маршрут api.telegram.org через туннель (без токена) ==='
curl --noproxy '*' --resolve api.telegram.org:443:127.0.0.1 --connect-timeout 5 --max-time 15 -sS -o /dev/null -w 'http=%{http_code} ip=%{remote_ip} time=%{time_total}\n' https://api.telegram.org/ 2>&1
echo "curl_exit=$?"
echo '=== конец 0101 ==='
REMOTE
