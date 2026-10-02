#!/data/data/com.termux/files/usr/bin/bash
# 0010: ПОСТОЯННЫЙ ТУННЕЛЬ — ЛЕКАРСТВО ДЛЯ БОТОВ
# Тест 0009 прошёл (tunnel_http=302). Ставим навсегда:
# 1) вечный туннель с телефона (VPN) на сервер (127.0.0.1:443)
# 2) автозапуск туннеля вместе с рукой
# 3) сервер: api.telegram.org -> 127.0.0.1 в /etc/hosts, рестарт ботов, проверка

echo "--- 0010: ПОСТОЯННЫЙ ТУННЕЛЬ, $(date) ---"

echo "=== 1. Скрипт вечного туннеля на телефоне ==="
cat > "$HOME/kord-tunnel.sh" <<'TUNNEL'
#!/data/data/com.termux/files/usr/bin/bash
while true; do
  ssh -N -R 127.0.0.1:443:api.telegram.org:443 -o BatchMode=yes -o ExitOnForwardFailure=yes -o ServerAliveInterval=20 -o ServerAliveCountMax=3 -o StrictHostKeyChecking=accept-new root@45.152.198.192
  sleep 15
done
TUNNEL
chmod +x "$HOME/kord-tunnel.sh"
echo "kord-tunnel.sh создан"

echo "=== 2. Автозапуск в kord-boot ==="
mkdir -p "$HOME/.termux/boot"
BOOT="$HOME/.termux/boot/kord-boot.sh"
if [ -f "$BOOT" ]; then
  grep -q "kord-tunnel" "$BOOT" || echo 'nohup bash $HOME/kord-tunnel.sh >/dev/null 2>&1 &' >> "$BOOT"
  echo "kord-boot дополнен"
else
  printf '#!/data/data/com.termux/files/usr/bin/bash\ntermux-wake-lock\nnohup bash $HOME/kord-tunnel.sh >/dev/null 2>&1 &\n' > "$BOOT"
  chmod +x "$BOOT"
  echo "kord-boot создан"
fi

echo "=== 3. Старт туннеля ==="
pkill -f "kord-tunnel.sh" 2>/dev/null
sleep 1
nohup bash "$HOME/kord-tunnel.sh" >/dev/null 2>&1 &
sleep 12
pgrep -af "kord-tunnel|443:api" || echo "ПРОЦЕСС ТУННЕЛЯ НЕ НАЙДЕН"

echo "=== 4. Сервер: hosts + рестарт ботов ==="
ssh -o BatchMode=yes -o StrictHostKeyChecking=accept-new -o ConnectTimeout=15 root@45.152.198.192 '
if grep -q "api.telegram.org" /etc/hosts; then
  echo "hosts уже содержит запись"
else
  echo "127.0.0.1 api.telegram.org" >> /etc/hosts
  echo "запись добавлена: api.telegram.org -> 127.0.0.1"
fi
ss -tlnp 2>/dev/null | grep ":443 " || echo "ТУННЕЛЬ НЕ СЛУШАЕТСЯ НА СЕРВЕРЕ"
curl --resolve api.telegram.org:443:127.0.0.1 -s --max-time 10 -o /dev/null -w "tunnel_check=%{http_code}\n" https://api.telegram.org/ 2>&1 || echo TUNNEL_FAIL
pm2 restart leadgen-bot legal-bots shtraf-bot template-bot >/dev/null 2>&1
echo "боты перезапущены"
sleep 25
pm2 list
echo "=== ЛОГ LEGAL-BOTS ПОСЛЕ ЛЕЧЕНИЯ ==="
pm2 logs legal-bots --lines 6 --nostream 2>&1 | grep -vi redact
'
echo "--- КОНЕЦ ЛЕЧЕНИЯ ---"
