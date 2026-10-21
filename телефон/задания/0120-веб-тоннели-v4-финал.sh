#!/data/data/com.termux/files/usr/bin/bash
# 0120 — ВЕБ-ТУННЕЛИ v4: высокие порты (sshd 10.2 не биндит 127.0.0.2:443 — remote forward failure),
# серверный socat перецепит 127.0.0.2-4:443 → 127.0.0.1:24430-32. Вечные циклы (паттерн вены).
echo '=== 0120 ВЕБ-ТУННЕЛИ v4 (высокие порты + socat) ==='

SRV="root@45.152.198.192"

# 1) вечный цикл на телефоне (высокие порты)
cat > "$HOME/kord-webtunnel.sh" <<'WT'
#!/data/data/com.termux/files/usr/bin/bash
# Вечные веб-тоннели v4: сервер 127.0.0.1:24430-32 → сайты. Стоп: СТОП-ВЕБ на сервере.
SRV="root@45.152.198.192"
OPTS="-o BatchMode=yes -o ExitOnForwardFailure=yes -o ServerAliveInterval=20 -o ConnectTimeout=15 -o StrictHostKeyChecking=accept-new"
loop() {
  while true; do
    if ssh $SRV 'test -f /root/kord-linza/СТОП-ВЕБ' 2>/dev/null; then exit 0; fi
    ssh -N -R "$1:$2:443" $OPTS "$SRV" >/dev/null 2>&1
    sleep 15
  done
}
loop fl     "127.0.0.1:24430" "www.fl.ru" &
loop capt   "127.0.0.1:24431" "smartcaptcha.yandexcloud.net" &
loop kwork  "127.0.0.1:24432" "kwork.ru" &
wait
WT
chmod +x "$HOME/kord-webtunnel.sh"

# 2) поднимаем циклы
pkill -f kord-webtunnel.sh 2>/dev/null; sleep 1
setsid nohup "$HOME/kord-webtunnel.sh" >/dev/null 2>&1 &
sleep 8

# 3) socat-мосты на сервере: 443 → высокие порты (идемпотентно)
ssh -o BatchMode=yes -o StrictHostKeyChecking=accept-new -o ConnectTimeout=15 "$SRV" 'bash -s' <<'REMOTE'
pkill -f 'socat.*TCP-LISTEN:443' 2>/dev/null
for pair in "2 24430" "3 24431" "4 24432"; do
  set -- $pair
  IPX=$1; PORT=$2
  if ! ss -tln | grep -q "127.0.0.$IPX:443 "; then
    setsid nohup socat TCP-LISTEN:443,bind=127.0.0.$IPX,fork,reuseaddr TCP:127.0.0.1:$PORT >/dev/null 2>&1 &
  fi
done
sleep 2
ss -tln | grep -E '127.0.0.[234]:443' | wc -l
REMOTE
echo '=== КОНЕЦ 0120 ==='
