#!/data/data/com.termux/files/usr/bin/bash
set -u
HOST='root@45.152.198.192'
SSH=(ssh -o BatchMode=yes -o ConnectTimeout=20 -o ServerAliveInterval=20 "$HOST")
echo '=== 0098preflight: точное имя службы Hermes ==='
"${SSH[@]}" 'bash -s' <<'REMOTE'
set -u
PID=$(pgrep -o -f 'hermes.*gateway run' 2>/dev/null || true)
echo "pid=$PID"
if [ -n "$PID" ]; then
  echo '=== 0097D: cgroup и юнит systemd ==='
  echo "cgroup=$(cat /proc/$PID/cgroup 2>/dev/null | head -3 | tr '\n' ' ')"
  UNIT=$(cat /proc/$PID/cgroup 2>/dev/null | sed -n 's/.*-user-.*\.slice\/[^/]*\/\([^.]*\)\.service.*/\1/p' | head -1)
  echo "unit_candidate=$UNIT"
  if [ -n "$UNIT" ] && systemctl --user status "$UNIT" --no-pager >/dev/null 2>&1; then
    echo "unit_active=да"
    systemctl --user show "$UNIT" --no-pager -p MainPID,FragmentPath,ActiveState 2>/dev/null
  else
    echo "unit_active=нет, ищем все юниты hermes"
    systemctl --user list-units --all --no-pager 2>/dev/null | grep -i hermes | head -5
  fi
  echo '=== 0097E: как adapter.py читает параметр (только чтение) ==='
  sed -n '3065,3085p' /root/hermes-src/plugins/platforms/telegram/adapter.py 2>/dev/null
  echo '=== 0097F: launcher и загрузка .env (только чтение) ==='
  grep -Rsn 'load_dotenv' /root/hermes-src/hermes_cli 2>/dev/null | head -5
  echo '=== 0097G: параметр в окружении текущего процесса (только имя) ==='
  tr '\0' '\n' < "/proc/$PID/environ" 2>/dev/null | grep -E '^(HERMES_TELEGRAM|HERMES_HOME)=' | sed 's/=.*/=<set>/' | head -10
fi
echo '=== 0098preflight: конец, ничего не менялось ==='
REMOTE
