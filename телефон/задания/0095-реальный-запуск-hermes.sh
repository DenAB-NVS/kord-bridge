#!/data/data/com.termux/files/usr/bin/bash
set -u
HOST='root@45.152.198.192'
SSH=(ssh -o BatchMode=yes -o ConnectTimeout=20 -o ServerAliveInterval=20 "$HOST")
echo '=== 0095: Hermes, только диагностика ==='
"${SSH[@]}" 'set -u; PID=$(pgrep -o -f "hermes.*gateway run" || true); echo "pid=$PID"; if [ -n "$PID" ]; then ps -p "$PID" -o pid,ppid,user,lstart,etime,stat,args; echo "--- exe ---"; readlink -f "/proc/$PID/exe"; echo "--- cwd ---"; readlink -f "/proc/$PID/cwd"; echo "--- parent ---"; PPID=$(awk "/^PPid:/ {print \$2}" "/proc/$PID/status"); ps -p "$PPID" -o pid,ppid,user,lstart,etime,stat,args || true; echo "--- окружение без секретов ---"; tr "\0" "\n" < "/proc/$PID/environ" | grep -E "^(PATH|HERMES_HOME|HOME|PWD|VIRTUAL_ENV)=" || true; fi'
echo '=== файлы Hermes: только имена и время ==='
"${SSH[@]}" 'find /root/.hermes -maxdepth 3 -type f \( -name "*.log" -o -name "*.jsonl" -o -name "*.json" \) -printf "%TY-%Tm-%Td %TH:%TM %s %p\n" 2>/dev/null | sort | tail -80'
echo '=== последние строки файлов журнала без секретов ==='
"${SSH[@]}" 'find /root/.hermes -maxdepth 3 -type f \( -name "*.log" -o -name "*.jsonl" \) -printf "%T@ %p\n" 2>/dev/null | sort -nr | head -5 | cut -d" " -f2- | while IFS= read -r f; do echo "--- $f ---"; tail -80 "$f"; done'
echo '=== сокет Hermes ==='
"${SSH[@]}" 'ss -lxnp | grep "/root/.hermes/gateway.sock" || true; ls -l /root/.hermes/gateway.sock 2>&1 || true'
echo '=== 0095: конец, ничего не менялось ==='
