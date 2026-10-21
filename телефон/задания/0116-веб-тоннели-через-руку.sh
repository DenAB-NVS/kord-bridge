#!/data/data/com.termux/files/usr/bin/bash
# 0116 — ВЕБ-ТУННЕЛИ ЧЕРЕЗ РУКУ: FL.ru + Яндекс-капча + Kwork видят мобильный IP телефона
# (паттерн вены: серверный браузер выходит в интернет через Руку — легальный IP владельца).
# Идемпотентно: живые тоннели не трогает. Снятие: touch /root/kord-linza/СТОП-ВЕБ на сервере.
echo '=== 0116 ВЕБ-ТУННЕЛИ (фл.ру/капча/kwork через Руку) ==='

SRV="root@45.152.198.192"
SSH_OPTS="-o BatchMode=yes -o StrictHostKeyChecking=accept-new -o ConnectTimeout=15"

STOP=$(ssh $SSH_OPTS "$SRV" 'test -f /root/kord-linza/СТОП-ВЕБ && echo yes || echo no' 2>/dev/null)
if [ "$STOP" = "yes" ]; then
  pkill -f '127.0.0.2:443' 2>/dev/null
  echo 'STOP_FLAG yes — веб-тоннели сняты'
  echo '=== КОНЕЦ 0116 ==='
  exit 0
fi

# жив? (слушатель 127.0.0.2:443 на сервере)
ALIVE=$(ssh $SSH_OPTS "$SRV" "ss -tln | grep -c '127.0.0.2:443 '" 2>/dev/null)
if [ "$ALIVE" -ge 1 ]; then
  echo 'WEB_TUNNEL_STATUS up (уже жив, не трогаю)'
  echo '=== КОНЕЦ 0116 ==='
  exit 0
fi

pkill -f '127.0.0.2:443' 2>/dev/null
sleep 1

# постоянные форварды: 127.0.0.2→fl.ru, 127.0.0.3→smartcaptcha, 127.0.0.4→kwork
setsid nohup ssh -N \
  -R "127.0.0.2:443:www.fl.ru:443" \
  -R "127.0.0.3:443:smartcaptcha.yandexcloud.net:443" \
  -R "127.0.0.4:443:kwork.ru:443" \
  -o BatchMode=yes -o ExitOnForwardFailure=yes -o StrictHostKeyChecking=accept-new \
  -o ConnectTimeout=15 -o ServerAliveInterval=15 -o ServerAliveCountMax=3 \
  "$SRV" >/dev/null 2>&1 &
sleep 5

RES=$(ssh $SSH_OPTS "$SRV" 'ss -tln | grep -cE "127.0.0.[234]:443"')
echo "WEB_TUNNEL_STATUS new — слушателей: $RES/3"
echo '=== КОНЕЦ 0116 ==='
