#!/data/data/com.termux/files/usr/bin/bash
# 0117 — ВЕБ-ТОННЕЛИ v2: три отдельных ssh (по одному на сайт) — отказ одного не роняет остальные.
# Идемпотентно: живые не трогает. Снятие: touch /root/kord-linza/СТОП-ВЕБ на сервере.
echo '=== 0117 ВЕБ-ТУННЕЛИ v2 ==='

SRV="root@45.152.198.192"
SSH_OPTS="-o BatchMode=yes -o StrictHostKeyChecking=accept-new -o ConnectTimeout=15"

STOP=$(ssh $SSH_OPTS "$SRV" 'test -f /root/kord-linza/СТОП-ВЕБ && echo yes || echo no' 2>/dev/null)
if [ "$STOP" = "yes" ]; then
  pkill -f '127.0.0.2:443' 2>/dev/null; pkill -f '127.0.0.3:443' 2>/dev/null; pkill -f '127.0.0.4:443' 2>/dev/null
  echo 'STOP_FLAG yes — сняты'
  echo '=== КОНЕЦ 0117 ==='
  exit 0
fi

start_tunnel() {  # $1=локальный ip:порт  $2=целевой хост
  ALIVE=$(ssh $SSH_OPTS "$SRV" "ss -tln | grep -c '$1 '" 2>/dev/null)
  [ "$ALIVE" -ge 1 ] && { echo "TUNNEL $1 up (жив)"; return 0; }
  pkill -f "$1" 2>/dev/null; sleep 1
  setsid nohup ssh -N -R "$1:$2:443" \
    -o BatchMode=yes -o StrictHostKeyChecking=accept-new \
    -o ConnectTimeout=15 -o ServerAliveInterval=15 -o ServerAliveCountMax=3 \
    "$SRV" >/dev/null 2>&1 &
  sleep 4
  NOW=$(ssh $SSH_OPTS "$SRV" "ss -tln | grep -c '$1 '" 2>/dev/null)
  echo "TUNNEL $1 → $2: ${NOW}/1"
}

start_tunnel "127.0.0.2:443" "www.fl.ru"
start_tunnel "127.0.0.3:443" "smartcaptcha.yandexcloud.net"
start_tunnel "127.0.0.4:443" "kwork.ru"
echo '=== КОНЕЦ 0117 ==='
