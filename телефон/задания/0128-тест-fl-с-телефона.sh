#!/data/data/com.termux/files/usr/bin/bash
echo '=== 0128 FL С ТЕЛЕФОНА ==='
curl -s -o /dev/null -w 'fl.ru напрямую с телефона: %{http_code}\n' --max-time 15 -A 'Mozilla/5.0' https://www.fl.ru/
curl -s --max-time 10 https://ifconfig.me 2>/dev/null | xargs echo 'внешний IP телефона:'
echo '=== КОНЕЦ 0128 ==='
