#!/data/data/com.termux/files/usr/bin/bash
echo '=== 0127 ЧИСТЫЙ ЦИКЛ (без проверочного ssh) ==='
cat > "$HOME/kord-webtunnel.sh" <<'WT'
#!/data/data/com.termux/files/usr/bin/bash
# Вечные веб-тоннели v5: чистый паттерн kord-tunnel.sh (как вена — без проверок в цикле)
SRV="root@45.152.198.192"
OPTS="-o BatchMode=yes -o ExitOnForwardFailure=yes -o ServerAliveInterval=20 -o ServerAliveCountMax=3 -o ConnectTimeout=15 -o StrictHostKeyChecking=accept-new"
while true; do
  ssh -N -R "127.0.0.1:24430:www.fl.ru:443" $OPTS "$SRV" >/dev/null 2>&1
  sleep 15
done
WT
chmod +x "$HOME/kord-webtunnel.sh"
# второй и третий — отдельными скриптами (как три вены, если бы были)
for entry in "24431 smartcaptcha.yandexcloud.net" "24432 kwork.ru"; do
  set -- $entry
  cat > "$HOME/kord-webtunnel-$1.sh" <<WT2
#!/data/data/com.termux/files/usr/bin/bash
SRV="root@45.152.198.192"
OPTS="-o BatchMode=yes -o ExitOnForwardFailure=yes -o ServerAliveInterval=20 -o ServerAliveCountMax=3 -o ConnectTimeout=15 -o StrictHostKeyChecking=accept-new"
while true; do
  ssh -N -R "127.0.0.1:$1:$2:443" $OPTS "$SRV" >/dev/null 2>&1
  sleep 15
done
WT2
  chmod +x "$HOME/kord-webtunnel-$1.sh"
done
# перезапуск всех чистых циклов
pkill -f kord-webtunnel 2>/dev/null; sleep 2
setsid nohup "$HOME/kord-webtunnel.sh" >/dev/null 2>&1 &
setsid nohup "$HOME/kord-webtunnel-24431.sh" >/dev/null 2>&1 &
setsid nohup "$HOME/kord-webtunnel-24432.sh" >/dev/null 2>&1 &
sleep 15
pgrep -cf 'kord-webtunnel' | xargs echo 'процессов:'
echo '=== КОНЕЦ 0127 ==='
