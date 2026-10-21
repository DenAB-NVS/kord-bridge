#!/data/data/com.termux/files/usr/bin/bash
echo '=== 0131 ЕДИНЫЙ ЦИКЛ (3 в одном, crond-сторож) ==='
cat > "$HOME/kord-webtunnel.sh" <<'WT'
#!/data/data/com.termux/files/usr/bin/bash
# Вечные веб-тоннели: 3 сайта одним супервайзером (сторож: crond, строка каждую минуту)
SRV="root@45.152.198.192"
OPTS="-o BatchMode=yes -o ExitOnForwardFailure=yes -o ServerAliveInterval=20 -o ServerAliveCountMax=3 -o ConnectTimeout=15 -o StrictHostKeyChecking=accept-new"
one() {
  while true; do
    ssh -N -R "$1:$2:443" $OPTS "$SRV" >/dev/null 2>&1
    sleep 15
  done
}
one "127.0.0.1:24430" "www.fl.ru" &
one "127.0.0.1:24431" "smartcaptcha.yandexcloud.net" &
one "127.0.0.1:24432" "kwork.ru" &
wait
WT
chmod +x "$HOME/kord-webtunnel.sh"
pkill -f kord-webtunnel 2>/dev/null; sleep 2
setsid nohup "$HOME/kord-webtunnel.sh" >/dev/null 2>&1 &
sleep 15
echo 'процессов: '"$(pgrep -cf kord-webtunnel)"
echo '=== КОНЕЦ 0131 ==='
