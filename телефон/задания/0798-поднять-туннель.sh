#!/data/data/com.termux/files/usr/bin/bash
# 0114 — ПОСТОЯННЫЙ ТУННЕЛЬ MTPROTO: закрытые чаты → линза юрис-конвейера
# По слову владельца «да» 19.10. Держит ssh -R 127.0.0.1:17443 → DC Telegram (данные из сессии acc1).
# Самовосстановление: цикл (30 с) проверяет; туннель жив — ничего; умер — поднимает заново.
# Кипалайвы по C-cure: ServerAliveInterval 15 × 3 — полумёртвый умирает за ~45 с, цикл поднимет свежий.
# Не трогает: вена-туннель (443), openclaw, pm2 — только свой процесс с уникальной строкой 17443.
# Снятие: на сервере touch /root/kord-linza/СТОП-ТУННЕЛЬ — следующий круг уберёт туннель и не поднимет.
echo '=== 0798 ПОДНЯТЬ ТУННЕЛЬ (dc-watch) ==='

SRV="root@45.152.198.192"
SSH_OPTS="-o BatchMode=yes -o StrictHostKeyChecking=accept-new -o ConnectTimeout=15"

# 1) стоп-флаг на сервере — снять туннель и выйти
STOP=$(ssh $SSH_OPTS "$SRV" 'test -f /root/kord-linza/СТОП-ТУННЕЛЬ && echo yes || echo no' 2>/dev/null)
if [ "$STOP" = "yes" ]; then
  pkill -f '127.0.0.1:17443' 2>/dev/null
  echo 'STOP_FLAG yes — туннель снят, не поднимаю'
  echo '=== КОНЕЦ 0798 ==='
  exit 0
fi

# 2) DC из сессии acc1 (проверенный паттерн 0034, read-only)
META=$(ssh $SSH_OPTS "$SRV" 'python3 - 2>/dev/null' <<'PY'
import sqlite3
try:
    c = sqlite3.connect('file:/root/рассылка/sessions/acc1.session?mode=ro', uri=True)
    row = c.execute('select server_address, port from sessions limit 1').fetchone()
    c.close()
    if row: print(row[0], row[1])
except Exception: pass
PY
)
read -r HOST PORT <<< "$META"
case "$HOST:$PORT" in *[!0-9.:]*) echo 'DC_META_VALID no'; echo '=== КОНЕЦ 0798 ==='; exit 0;; esac
if [ -z "$HOST" ] || [ -z "$PORT" ]; then echo 'DC_META_VALID no'; echo '=== КОНЕЦ 0798 ==='; exit 0; fi
echo "DC_META_VALID yes ($HOST:$PORT)"

# 3) туннель уже жив? (слушатель на сервере)
ALIVE=$(ssh $SSH_OPTS "$SRV" "ss -tln | grep -c ':17443 '" 2>/dev/null)
if [ "$ALIVE" -ge 1 ]; then
  echo 'TUNNEL_STATUS up (уже жив, не трогаю)'
  echo '=== КОНЕЦ 0798 ==='
  exit 0
fi

# 4) мёртвый хвост мог остаться у нас — прибить перед новым
pkill -f '127.0.0.1:17443' 2>/dev/null
sleep 1

# 5) поднять постоянный туннель (переживает выход задания)
setsid nohup ssh -N -R "127.0.0.1:17443:$HOST:$PORT" \
  -o BatchMode=yes -o ExitOnForwardFailure=yes -o StrictHostKeyChecking=accept-new \
  -o ConnectTimeout=15 -o ServerAliveInterval=15 -o ServerAliveCountMax=3 \
  "$SRV" >/dev/null 2>&1 &
sleep 5

# 6) проверка с сервера: слушатель + сквозной TCP
RES=$(ssh $SSH_OPTS "$SRV" 'python3 - 2>/dev/null' <<'PY'
import socket
lst = tcp = 'no'
try:
    with open('/proc/net/tcp') as f:
        for line in f:
            if ':4413' in line.split()[1]:  # 17443 = 0x4413
                lst = 'yes'; break
except Exception: pass
try:
    with socket.create_connection(('127.0.0.1', 17443), timeout=8):
        tcp = 'yes'
except Exception: pass
print(f'LISTEN {lst} FORWARDED_DC_TCP {tcp}')
PY
)
echo "TUNNEL_STATUS new — $RES"
echo '=== КОНЕЦ 0798 ==='
