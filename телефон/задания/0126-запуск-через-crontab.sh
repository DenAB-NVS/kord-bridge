#!/data/data/com.termux/files/usr/bin/bash
echo '=== 0126 ЗАПУСК ЧЕРЕЗ CROND ==='
command -v crond >/dev/null || pkg install -y cronie >/dev/null 2>&1
mkdir -p ~/.cron 2>/dev/null
# "@reboot" в termux cronie не работает — но crond уже мог быть запущен; проверим
pgrep -x crond >/dev/null || { crond >/dev/null 2>&1; sleep 1; }
pgrep -x crond >/dev/null && echo 'crond жив' || echo 'crond не встал'
# строка каждую минуту: если циклов нет — поднять (идеальный сторож)
( crontab -l 2>/dev/null | grep -v kord-webtunnel; echo '* * * * * pgrep -f kord-webtunnel.sh >/dev/null || (setsid nohup $HOME/kord-webtunnel.sh >/dev/null 2>&1)' ) | crontab -
crontab -l | grep -c webtunnel | xargs echo 'строк webtunnel в crontab:'
sleep 70
pgrep -cf kord-webtunnel.sh | xargs echo 'циклов теперь:'
echo '=== КОНЕЦ 0126 ==='
