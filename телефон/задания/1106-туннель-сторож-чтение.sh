#!/data/data/com.termux/files/usr/bin/bash
# 1106 — прямой подъём туннеля (паттерн 1103) + сторож через heredoc с bash -n и логом + чтение avtozalogrf.
echo "== 1106: туннель, сторож, чтение =="
SRV="root@45.152.198.192"
O="-o BatchMode=yes -o StrictHostKeyChecking=accept-new -o ConnectTimeout=15"
W="$HOME/kord-mtproto-storozh.sh"
L="$HOME/kord-mtproto-storozh.log"

cat > "$W" <<'EOF'
#!/data/data/com.termux/files/usr/bin/bash
# сторож MTProto-туннеля: цикл 30 с; снятие - файл СТОП-ТУННЕЛЬ на сервере
SRV="root@45.152.198.192"
O="-o BatchMode=yes -o StrictHostKeyChecking=accept-new -o ConnectTimeout=15"
while true; do
  STOP=$(ssh $O "$SRV" 'test -f /root/kord-linza/СТОП-ТУННЕЛЬ && echo yes || echo no' 2>/dev/null)
  if [ "$STOP" = "yes" ]; then pkill -f '127.0.0.1:17443' 2>/dev/null; sleep 30; continue; fi
  ALIVE=$(ssh $O "$SRV" "ss -tln | grep -c ':17443 '" 2>/dev/null)
  if [ "${ALIVE:-0}" -lt 1 ]; then
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
    case "$HOST:$PORT" in *[!0-9.:]*) sleep 30; continue;; esac
    pkill -f '127.0.0.1:17443' 2>/dev/null
    sleep 1
    setsid nohup ssh -N -R "127.0.0.1:17443:$HOST:$PORT" -o BatchMode=yes -o ExitOnForwardFailure=yes -o StrictHostKeyChecking=accept-new -o ConnectTimeout=15 -o ServerAliveInterval=15 -o ServerAliveCountMax=3 "$SRV" >> "$HOME/kord-mtproto-storozh.log" 2>&1 &
  fi
  sleep 30
done
EOF
chmod +x "$W"
bash -n "$W" && echo "синтаксис сторожа: ок" || echo "синтаксис сторожа: БИТЫЙ"

ALIVE=$(ssh $O "$SRV" "ss -tln | grep -c ':17443 '" 2>/dev/null)
echo "туннель до подъёма: $ALIVE"
if [ "${ALIVE:-0}" -lt 1 ]; then
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
  case "$HOST:$PORT" in *[!0-9.:]*) echo "DC невалиден"; exit 0;; esac
  pkill -f '127.0.0.1:17443' 2>/dev/null
  sleep 1
  ssh -N -R "127.0.0.1:17443:$HOST:$PORT" -o BatchMode=yes -o ExitOnForwardFailure=yes -o StrictHostKeyChecking=accept-new -o ConnectTimeout=15 -o ServerAliveInterval=15 -o ServerAliveCountMax=3 "$SRV" >> "$L" 2>&1 &
  sleep 8
fi
CHK=$(ssh $O "$SRV" "ss -tln | grep ':17443 ' | head -1")
echo "слушатель: ${CHK:-НЕТ}"

if pgrep -f 'kord-mtproto-storozh.sh' >/dev/null 2>&1; then
  echo "сторож уже жив"
else
  setsid nohup bash "$W" >> "$L" 2>&1 &
  echo "сторож запущен"
fi

echo "-- чтение avtozalogrf --"
ssh $O "$SRV" 'timeout 120 /root/kord-linza/venv/bin/python /root/kord-glubina/read-one-r1104.py 2>&1 | tail -90'

echo "-- пуш в дом --"
ssh $O "$SRV" 'cd /root/kord-glubina/kordinaps-machine && git add "проекты/ЧТЕНИЕ-avtozalogrf-2026-11-07.md" 2>/dev/null; git commit -q -m "ЧТЕНИЕ avtozalogrf 07.11 (по слову владельца)" 2>/dev/null; git push -q origin HEAD:main 2>&1 | tail -1; echo "пуш выполнен"'

echo "-- хвост лога сторожа --"
tail -8 "$L" 2>/dev/null || echo "лог пуст"
echo "== 1106: конец =="
