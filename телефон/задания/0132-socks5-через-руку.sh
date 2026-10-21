#!/data/data/com.termux/files/usr/bin/bash
# 0132 — SOCKS5-ПРОКСИ ЧЕРЕЗ РУКУ: termux microsocks + ssh -R 24433.
# Chrome сервера ходит socks5://127.0.0.1:24433 → телефон → Яндекс/сайты с мобильного IP.
# Лечит MTU-обрыв TLS-ClientHello в ssh -R канале (большие ClientHello Chrome умирали).
echo '=== 0132 SOCKS5 ЧЕРЕЗ РУКУ ==='
command -v microsocks >/dev/null || pkg install -y microsocks >/dev/null 2>&1
command -v microsocks >/dev/null || { echo 'microsocks не ставится'; exit 0; }
# прокси на телефоне (127.0.0.1:1080), вечный
if ! pgrep -x microsocks >/dev/null; then
  setsid nohup microsocks -i 127.0.0.1 -p 1080 >/dev/null 2>&1 &
  echo 'microsocks поднят (:1080)'
else
  echo 'microsocks жив'
fi
# вечный ssh -R 24433 → телефонный 1080 (чистый паттерн вены)
cat > "$HOME/kord-socks.sh" <<'SK'
#!/data/data/com.termux/files/usr/bin/bash
SRV="root@45.152.198.192"
OPTS="-o BatchMode=yes -o ExitOnForwardFailure=yes -o ServerAliveInterval=20 -o ServerAliveCountMax=3 -o ConnectTimeout=15 -o StrictHostKeyChecking=accept-new"
while true; do
  ssh -N -R "127.0.0.1:24433:127.0.0.1:1080" $OPTS "$SRV" >/dev/null 2>&1
  sleep 15
done
SK
chmod +x "$HOME/kord-socks.sh"
if ! pgrep -f kord-socks.sh >/dev/null; then
  setsid nohup "$HOME/kord-socks.sh" >/dev/null 2>&1 &
  echo 'socks-цикл поднят'
else
  echo 'socks-цикл жив'
fi
# автозапуск вместе с webtunnel
BOOT="$HOME/.termux/boot/kord-boot.sh"
grep -q kord-socks "$BOOT" 2>/dev/null || cat >> "$BOOT" <<'AB'
pgrep -x microsocks >/dev/null || (setsid nohup microsocks -i 127.0.0.1 -p 1080 >/dev/null 2>&1 &)
pgrep -f kord-socks.sh >/dev/null || nohup bash "$HOME/kord-socks.sh" >/dev/null 2>&1 &
AB
sleep 10
ssh -o BatchMode=yes root@45.152.198.192 'ss -tln | grep -c 24433' 2>/dev/null | xargs echo 'слушатель 24433 на сервере:'
echo '=== КОНЕЦ 0132 ==='
