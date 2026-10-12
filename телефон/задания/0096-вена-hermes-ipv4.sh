#!/data/data/com.termux/files/usr/bin/bash
set -u
HOST='root@45.152.198.192'
SSH=(ssh -o BatchMode=yes -o ConnectTimeout=20 -o ServerAliveInterval=20 "$HOST")
echo '=== 0096: точечное лечение IPv4 Telegram ==='
"${SSH[@]}" 'set -eu; IP=149.154.166.110; if ! command -v iptables >/dev/null 2>&1; then echo "iptables отсутствует; правило не менялось"; exit 10; fi; if iptables -t nat -C OUTPUT -p tcp -d "$IP" --dport 443 -j DNAT --to-destination 127.0.0.1:443 2>/dev/null; then echo "правило уже есть"; else iptables -t nat -A OUTPUT -p tcp -d "$IP" --dport 443 -j DNAT --to-destination 127.0.0.1:443; echo "правило добавлено"; fi; iptables -t nat -S OUTPUT | grep "$IP" || true; echo "--- проверка через прямой IPv4 ---"; curl -sS --max-time 20 --resolve api.telegram.org:443:"$IP" -o /dev/null -w "telegram_via_ipv4_http=%{http_code}\n" https://api.telegram.org/; echo "--- подождать восстановление Hermes ---"; sleep 35; tail -100 /root/.hermes/logs/gateway.log | grep -E "Telegram.*(recovered|error|polling)|IPv4 Telegram API IP" || true'
echo '=== 0096: конец ==='
