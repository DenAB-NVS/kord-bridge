#!/data/data/com.termux/files/usr/bin/bash
echo '=== 0123 ДИАГ v4 ==='
timeout 6 ssh -v -N -R "127.0.0.1:24430:www.fl.ru:443" -o BatchMode=yes -o ExitOnForwardFailure=yes -o ConnectTimeout=10 root@45.152.198.192 2>&1 | grep -iE 'forward|listen|fail|refus|error' | head -6
echo '=== КОНЕЦ 0123 ==='
