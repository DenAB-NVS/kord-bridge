#!/data/data/com.termux/files/usr/bin/bash
echo '=== 0125 ДИАГ STDERR ЦИКЛА ==='
timeout 20 ssh -N -R "127.0.0.1:24430:www.fl.ru:443" -o BatchMode=yes -o ExitOnForwardFailure=yes -o ServerAliveInterval=20 -o ConnectTimeout=15 root@45.152.198.192 2>/tmp/wt-err.log &
sleep 8
echo 'ssh жив: '"$(pgrep -cf 'ssh -N -R 127.0.0.1:24430')"
cat /tmp/wt-err.log | head -5
ssh -o BatchMode=yes root@45.152.198.192 'ss -tln | grep -c 24430' 2>/dev/null | xargs echo 'слушатель 24430 на сервере:'
wait
echo '=== КОНЕЦ 0125 ==='
