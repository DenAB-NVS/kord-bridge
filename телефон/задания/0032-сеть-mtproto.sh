#!/data/data/com.termux/files/usr/bin/bash
# Только сетевой TCP тест к адресу DC из метаданных сессии; без ключей и сообщений.
echo '=== 0032 СЕТЬ MTPROTO ==='
META=$(ssh -o BatchMode=yes -o StrictHostKeyChecking=accept-new -o ConnectTimeout=15 root@45.152.198.192 'python3 - 2>/dev/null' <<'PY'
import sqlite3
from pathlib import Path
p = Path('/root/рассылка/sessions/acc1.session')
try:
    con = sqlite3.connect('file:' + str(p) + '?mode=ro', uri=True)
    row = con.execute('select server_address, port from sessions limit 1').fetchone()
    con.close()
    if row: print(row[0], row[1])
except Exception:
    pass
PY
)
read -r DC_HOST DC_PORT <<< "$META"
if [ -z "$DC_HOST" ] || [ -z "$DC_PORT" ]; then
 echo 'DC_META_AVAILABLE no'
else
 echo 'DC_META_AVAILABLE yes'
 DC_HOST="$DC_HOST" DC_PORT="$DC_PORT" python3 - <<'PY'
import ipaddress, os, socket
try:
    host = str(ipaddress.ip_address(os.environ['DC_HOST']))
    port = int(os.environ['DC_PORT'])
    if not 1 <= port <= 65535: raise ValueError()
    def reachable():
        try:
            with socket.create_connection((host, port), timeout=6): return 'yes'
        except (OSError, TimeoutError): return 'no'
    print('PHONE_DC_TCP', reachable())
except (ValueError, KeyError):
    print('DC_META_VALID no')
PY
 ssh -o BatchMode=yes -o StrictHostKeyChecking=accept-new -o ConnectTimeout=15 root@45.152.198.192 'python3 - 2>/dev/null' <<'PY'
import sqlite3, socket
from pathlib import Path
try:
    p = Path('/root/рассылка/sessions/acc1.session')
    con = sqlite3.connect('file:' + str(p) + '?mode=ro', uri=True)
    host, port = con.execute('select server_address, port from sessions limit 1').fetchone()
    con.close()
    with socket.create_connection((host, int(port)), timeout=6):
        print('SERVER_DC_TCP yes')
except Exception:
    print('SERVER_DC_TCP no')
PY
fi
echo '=== КОНЕЦ 0032 ==='
