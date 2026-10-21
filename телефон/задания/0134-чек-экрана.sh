#!/data/data/com.termux/files/usr/bin/bash
echo '=== 0134 ЧЕК ЭКРАНА ==='
pgrep -f kord-ekran-tunnel.sh >/dev/null && echo 'цикл жив' || { setsid nohup "$HOME/kord-ekran-tunnel.sh" >/dev/null 2>&1 & echo 'цикл переподнят'; }
sleep 6
curl -s -o /dev/null -w 'localhost:6081: HTTP %{http_code}\n' --max-time 8 http://localhost:6081/vnc.html
echo '=== КОНЕЦ 0134 ==='
