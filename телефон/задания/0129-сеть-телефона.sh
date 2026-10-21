#!/data/data/com.termux/files/usr/bin/bash
echo '=== 0129 СЕТЬ ТЕЛЕФОНА ==='
# какой интерфейс с шлюзом по умолчанию (wifi = wlan0, мобильный = rmnet/ccmni)
ip route 2>/dev/null | head -3
echo '--- curl с явным SNI через текущую сеть ---'
curl -s -o /dev/null -w 'fl.ru: %{http_code}\n' --max-time 12 https://www.fl.ru/
curl -s -o /dev/null -w 'ya.ru (контроль): %{http_code}\n' --max-time 10 https://ya.ru/
echo '=== КОНЕЦ 0129 ==='
