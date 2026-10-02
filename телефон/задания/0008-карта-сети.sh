#!/data/data/com.termux/files/usr/bin/bash
# 0008: КАРТА СЕТИ СЕРВЕРА — только чтение.
# Цель: развести две гипотезы: (A) IPv6-DNS без IPv6-маршрута; (B) мёртвый исходящий HTTPS.

echo "--- 0008: КАРТА СЕТИ kord-vps-01, $(date) ---"
ssh -o BatchMode=yes -o StrictHostKeyChecking=accept-new -o ConnectTimeout=15 root@45.152.198.192 '
echo "=== TELEGRAM ПРИНУДИТЕЛЬНО IPv4 ==="
curl -4 -s --max-time 8 -o /dev/null -w "tg_v4 http_code=%{http_code} time=%{time_total}s\n" https://api.telegram.org/ 2>&1 || echo TG_V4_FAIL
echo "=== TELEGRAM ПРИНУДИТЕЛЬНО IPv6 ==="
curl -6 -s --max-time 8 -o /dev/null -w "tg_v6 http_code=%{http_code} time=%{time_total}s\n" https://api.telegram.org/ 2>&1 || echo TG_V6_FAIL
echo "=== ОБЩИЙ ИСХОДЯЩИЙ HTTPS ==="
curl -4 -s --max-time 8 -o /dev/null -w "example_com http_code=%{http_code}\n" https://example.com/ 2>&1 || echo EXAMPLE_FAIL
curl -4 -s --max-time 8 -o /dev/null -w "github_com http_code=%{http_code}\n" https://github.com/ 2>&1 || echo GITHUB_FAIL
echo "=== DNS IPv4 ДЛЯ TELEGRAM ==="
getent ahostsv4 api.telegram.org | head -5
echo "=== АДРЕСА И МАРШРУТЫ ==="
ip -4 addr | grep inet
ip -6 addr | grep inet6
ip route
echo "=== /etc/gai.conf (приоритет адресов) ==="
grep -v "^#" /etc/gai.conf 2>/dev/null | grep -v "^$" || echo "gai.conf пуст"
echo "=== /etc/hosts ЗАПИСИ ==="
grep -i telegram /etc/hosts 2>/dev/null || echo "в hosts нет записей про telegram"
' 2>&1
echo "--- КОНЕЦ ---"
