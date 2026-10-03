#!/data/data/com.termux/files/usr/bin/bash
# Читаются только сетевые метаданные сессии; адрес в эхо не выводится.
echo '=== 0033 ТЕЛЕФОННЫЙ TCP DC ==='
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
if ! command -v curl >/dev/null 2>&1; then echo 'CURL_AVAILABLE no'; exit 0; fi
echo 'DC_META_VALID yes'
if curl -v --connect-timeout 6 --max-time 8 -o /dev/null "telnet://$HOST:$PORT" 2>&1 | grep -q 'Connected to'; then
 echo 'PHONE_DC_TCP yes'
else
 echo 'PHONE_DC_TCP no'
fi
echo '=== КОНЕЦ 0033 ==='
