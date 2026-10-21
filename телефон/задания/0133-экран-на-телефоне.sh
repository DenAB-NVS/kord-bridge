#!/data/data/com.termux/files/usr/bin/bash
# 0133 — ЭКРАН ДОСТУПЕН С ТЕЛЕФОНА: порт сервера 6081 (noVNC) проброшен на localhost:6081 телефона.
# Денис открывает в Chrome телефона http://localhost:6081/vnc.html — видит серверный браузер,
# проходит капчу пальцем. Пароль VNC ему сообщает Hermes в чате.
echo '=== 0133 ЭКРАН НА ТЕЛЕФОНЕ ==='
cat > "$HOME/kord-ekran-tunnel.sh" <<'ET'
#!/data/data/com.termux/files/usr/bin/bash
SRV="root@45.152.198.192"
OPTS="-o BatchMode=yes -o ExitOnForwardFailure=yes -o ServerAliveInterval=20 -o ServerAliveCountMax=3 -o ConnectTimeout=15 -o StrictHostKeyChecking=accept-new"
while true; do
  ssh -N -L "6081:127.0.0.1:6081" $OPTS "$SRV" >/dev/null 2>&1
  sleep 15
done
ET
chmod +x "$HOME/kord-ekran-tunnel.sh"
if ! pgrep -f kord-ekran-tunnel.sh >/dev/null; then
  setsid nohup "$HOME/kord-ekran-tunnel.sh" >/dev/null 2>&1 &
  echo 'туннель экрана поднят (вечный цикл)'
else
  echo 'туннель экрана уже жив'
fi
# автозапуск
BOOT="$HOME/.termux/boot/kord-boot.sh"
grep -q kord-ekran-tunnel "$BOOT" 2>/dev/null || echo 'pgrep -f kord-ekran-tunnel.sh >/dev/null || nohup bash "$HOME/kord-ekran-tunnel.sh" >/dev/null 2>&1 &' >> "$BOOT"
sleep 8
curl -s -o /dev/null -w 'localhost:6081 с телефона: HTTP %{http_code}\n' --max-time 8 http://localhost:6081/vnc.html
echo '=== КОНЕЦ 0133 ==='
