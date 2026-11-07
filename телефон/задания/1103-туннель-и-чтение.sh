#!/data/data/com.termux/files/usr/bin/bash
# 1103 — туннель MTProto вверх (паттерн 0114) + чтение zalogzaym + выровненный пуш HEAD:main.
echo "== 1103: туннель + чтение =="
SRV="root@45.152.198.192"
O="-o BatchMode=yes -o StrictHostKeyChecking=accept-new -o ConnectTimeout=15"

echo "-- 1. стоп-флаг туннеля --"
STOP=$(ssh $O "$SRV" 'test -f /root/kord-linza/СТОП-ТУННЕЛЬ && echo yes || echo no')
echo "СТОП-ТУННЕЛЬ: $STOP"

echo "-- 2. DC из сессии acc1 --"
META=$(ssh $O "$SRV" 'python3 - 2>/dev/null' <<'PY'
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
echo "DC: $HOST:$PORT"
case "$HOST:$PORT" in *[!0-9.:]*) echo "DC невалиден — стоп"; echo "== 1103: конец =="; exit 0;; esac

echo "-- 3. туннель жив? --"
ALIVE=$(ssh $O "$SRV" "ss -tln | grep -c ':17443 '")
echo "жив: $ALIVE"
if [ "$ALIVE" -lt 1 ]; then
  pkill -f '127.0.0.1:17443' 2>/dev/null
  sleep 1
  setsid nohup ssh -N -R "127.0.0.1:17443:$HOST:$PORT" -o BatchMode=yes -o ExitOnForwardFailure=yes -o StrictHostKeyChecking=accept-new -o ConnectTimeout=15 -o ServerAliveInterval=15 -o ServerAliveCountMax=3 "$SRV" >/dev/null 2>&1 &
  sleep 7
fi
CHK=$(ssh $O "$SRV" "ss -tln | grep ':17443 ' | head -1")
echo "слушатель: ${CHK:-НЕТ}"

echo "-- 4. чтение zalogzaym (до 70 постов) --"
ssh $O "$SRV" 'timeout 120 /root/kord-linza/venv/bin/python /root/kord-glubina/read-one-r1102.py 2>&1 | tail -90'

echo "-- 5. пуш в дом (HEAD:main) --"
ssh $O "$SRV" 'cd /root/kord-glubina/kordinaps-machine && git add "проекты/ЧТЕНИЕ-zalogzaym-2026-11-07.md" 2>/dev/null; git commit -q -m "ЧТЕНИЕ zalogzaym 07.11 (по слову владельца)" 2>/dev/null; git push -q origin HEAD:main 2>&1 | tail -1; echo "пуш HEAD:main выполнен"'
echo "== 1103: конец =="
