#!/data/data/com.termux/files/usr/bin/bash
# 0011: КОНТРОЛЬНЫЙ СНИМОК ПОСЛЕ ЛЕЧЕНИЯ — только чтение.
# Приговор: если счётчики рестартов всё ещё 645/625/645 — боты вылечены.

echo "--- 0011: КОНТРОЛЬ, $(date) ---"
ssh -o BatchMode=yes -o StrictHostKeyChecking=accept-new -o ConnectTimeout=15 root@45.152.198.192 '
echo "=== СЧЁТЧИКИ ==="
pm2 list
echo "=== ТУННЕЛЬ ЖИВ? ==="
ss -tlnp 2>/dev/null | grep ":443 " || echo "ТУННЕЛЬ УПАЛ"
curl --resolve api.telegram.org:443:127.0.0.1 -s --max-time 10 -o /dev/null -w "tunnel_check=%{http_code}\n" https://api.telegram.org/ 2>&1 || echo TUNNEL_FAIL
echo "=== ОШИБКИ LEGAL ПОСЛЕ ЛЕЧЕНИЯ (если есть новые) ==="
pm2 logs legal-bots --err --lines 8 --nostream 2>&1 | grep -vi redact
echo "=== СТАРТОВЫЙ ЛОГ SHTRAF ==="
pm2 logs shtraf-bot --lines 5 --nostream 2>&1 | grep -vi redact
'
echo "--- КОНЕЦ КОНТРОЛЯ ---"
