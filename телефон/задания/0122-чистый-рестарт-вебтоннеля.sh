#!/data/data/com.termux/files/usr/bin/bash
echo '=== 0122 ЧИСТЫЙ РЕСТАРТ ==='
pkill -f kord-webtunnel.sh 2>/dev/null; sleep 1
pkill -f 'ssh -N -R 127.0.0.2' 2>/dev/null
pkill -f 'ssh -N -R 127.0.0.3' 2>/dev/null
pkill -f 'ssh -N -R 127.0.0.4' 2>/dev/null
sleep 2
echo 'убиты старые; остался только вена-туннель:'
pgrep -af 'ssh -N -R' | grep -v 244 | head -3
setsid nohup "$HOME/kord-webtunnel.sh" >/dev/null 2>&1 &
sleep 10
echo 'циклы подняты:'
pgrep -cf kord-webtunnel.sh
echo '=== КОНЕЦ 0122 ==='
