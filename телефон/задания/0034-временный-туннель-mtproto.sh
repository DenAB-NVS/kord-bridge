#!/data/data/com.termux/files/usr/bin/bash
# Временный SSH -R только на loopback; закрыть при завершении теста.
echo '=== 0034 ВРЕМЕННЫЙ ТУННЕЛЬ MTPROTO ==='
META=$(ssh -o BatchMode=yes -o StrictHostKeyChecking=accept-new -o ConnectTimeout=15 root@45.152.198.192 'python3 - 2>/dev/null' <<'PY'
import sqlite3
from pathlib import Path
try:
    p = Path('/root/рассылка/sessions/acc1.session')
    c = sqlite3.connect('file:' + str(p) + '?mode=ro', uri=True)
    row = c.execute('select server_address, port from sessions limit 1').fetchone()
    c.close()
    if row: print(row[0], row[1])
except Exception: pass
PY
)
read -r HOST PORT <<< "$META"
case "$HOST:$PORT" in *[!0-9.:]*) echo 'DC_META_VALID no'; exit 0;; esac
if [ -z "$HOST" ] || [ -z "$PORT" ]; then echo 'DC_META_VALID no'; exit 0; fi
ssh -N -R "127.0.0.1:17443:$HOST:$PORT" -o BatchMode=yes -o ExitOnForwardFailure=yes -o StrictHostKeyChecking=accept-new -o ConnectTimeout=15 root@45.152.198.192 >/dev/null 2>&1 &
TUN_PID=$!
trap 'kill "$TUN_PID" 2>/dev/null; wait "$TUN_PID" 2>/dev/null' EXIT
sleep 4
if ! kill -0 "$TUN_PID" 2>/dev/null; then
 echo 'TUNNEL_STARTED no'
else
 echo 'TUNNEL_STARTED yes'
 ssh -o BatchMode=yes -o StrictHostKeyChecking=accept-new -o ConnectTimeout=15 root@45.152.198.192 'python3 - 2>/dev/null' <<'PY'
import socket
try:
    with socket.create_connection(('127.0.0.1', 17443), timeout=8): print('FORWARDED_DC_TCP yes')
except Exception: print('FORWARDED_DC_TCP no')
PY
fi
echo 'TUNNEL_WILL_CLOSE yes'
echo '=== КОНЕЦ 0034 ==='
