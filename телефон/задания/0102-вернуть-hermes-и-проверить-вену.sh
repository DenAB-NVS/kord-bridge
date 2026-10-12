#!/data/data/com.termux/files/usr/bin/bash
set -u
HOST='root@45.152.198.192'
SSH=(ssh -o BatchMode=yes -o ConnectTimeout=20 -o ServerAliveInterval=20 "$HOST")
echo '=== 0102: вернуть Hermes как было до 0099 + проверить вену ==='
echo '=== A: Telegram с самого телефона (VPN) ==='
curl --connect-timeout 5 --max-time 15 -sS -o /dev/null -w 'phone_http=%{http_code} time=%{time_total}\n' https://api.telegram.org/ 2>&1; echo "phone_exit=$?"
echo '=== B: туннель на телефоне ==='
pgrep -af kord-tunnel || echo 'kord-tunnel НЕ запущен'
"${SSH[@]}" 'bash -s' <<'REMOTE'
set -u
echo '=== C: вернуть .env из копии 0099 ==='
B=$(ls -1t /root/.hermes/.env.bak-* 2>/dev/null | head -1)
if [ -n "$B" ]; then install -m 600 "$B" /root/.hermes/.env && echo "восстановлен из $B"; else echo 'копия не найдена, .env не трогаю'; fi
grep -c '^HERMES_TELEGRAM_DISABLE_FALLBACK_IPS=' /root/.hermes/.env | sed 's/^/строк с параметром: /'
echo '=== D: запуск Hermes ==='
systemctl --user start hermes-gateway.service; echo "start_exit=$?"
sleep 20
systemctl --user show hermes-gateway.service -p ActiveState,SubState,MainPID | sed 's/^/  /'
systemctl --user show openclaw-gateway.service -p ActiveState,SubState | sed 's/^/  openclaw /'
echo '=== E: туннель с сервера ==='
curl --noproxy '*' --resolve api.telegram.org:443:127.0.0.1 --connect-timeout 5 --max-time 15 -sS -o /dev/null -w 'server_http=%{http_code}\n' https://api.telegram.org/ 2>&1; echo "server_exit=$?"
echo '=== конец 0102 ==='
REMOTE
