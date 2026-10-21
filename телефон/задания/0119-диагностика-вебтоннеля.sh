#!/data/data/com.termux/files/usr/bin/bash
echo '=== 0119 ДИАГНОСТИКА ВЕБТУННЕЛЯ ==='
pgrep -af 'kord-webtunnel|ssh -N -R' | head -6
echo '--- проба одного форварда с выводом ошибок (5 сек) ---'
timeout 5 ssh -v -N -R "127.0.0.2:443:www.fl.ru:443" -o BatchMode=yes -o ExitOnForwardFailure=yes -o ConnectTimeout=10 root@45.152.198.192 2>&1 | grep -iE 'forward|listen|remote|error|fail|refused' | head -8
echo '=== КОНЕЦ 0119 ==='
