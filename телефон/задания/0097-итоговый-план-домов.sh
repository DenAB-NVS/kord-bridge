#!/data/data/com.termux/files/usr/bin/bash
set -u
HOST='root@45.152.198.192'
SSH=(ssh -o BatchMode=yes -o ConnectTimeout=20 -o ServerAliveInterval=20 "$HOST")
echo '=== 0097: диагностика, без изменений ==='
"${SSH[@]}" 'bash -s' <<'REMOTE'
set -u
IP=149.154.166.110
echo '=== 0097A: наличие NAT-правила (только чтение) ==='
if command -v iptables >/dev/null 2>&1; then
  if iptables -t nat -C OUTPUT -p tcp -d "$IP" --dport 443 -j DNAT --to-destination 127.0.0.1:443 2>/dev/null; then
    echo 'наличие_правила_0096=да'
  else
    echo 'наличие_правила_0096=нет'
  fi
  iptables -t nat -S OUTPUT 2>/dev/null | grep -F "$IP" | sed 's/^/строка_правила: /' || echo 'строк_в_nat_не_найдено'
else
  echo 'iptables не установлен'
fi
echo '=== 0097B: поддержка HERMES_TELEGRAM_DISABLE_FALLBACK_IPS ==='
grep -Rsn --exclude='*.pyc' 'HERMES_TELEGRAM_DISABLE_FALLBACK_IPS' /root/hermes-src 2>/dev/null | sed -n '1,20p'
grep -Rsn --exclude='*.pyc' 'HERMES_TELEGRAM_DISABLE_FALLBACK_IPS' /root/.hermes/.env 2>/dev/null || echo 'в .env параметр отсутствует'
echo '=== 0097C: реальный запуск Hermes ==='
PID=$(pgrep -o -f 'hermes.*gateway run' 2>/dev/null || true)
echo "pid=$PID"
if [ -n "$PID" ]; then
  PARENT_PID=$(awk '/^PPid:/ {print $2}' "/proc/$PID/status" 2>/dev/null || true)
  echo "parent_pid=$PARENT_PID"
  if [ -n "$PARENT_PID" ] && [ -d "/proc/$PARENT_PID" ]; then
    echo "parent_comm=$(cat /proc/$PARENT_PID/comm 2>/dev/null || true)"
    echo "parent_cmdline_first=$(tr '\0' '\n' < "/proc/$PARENT_PID/cmdline" 2>/dev/null | head -3 | tr '\n' ' ')"
  fi
  echo "exe=$(readlink -f "/proc/$PID/exe" 2>/dev/null)"
  echo "cwd=$(readlink -f "/proc/$PID/cwd" 2>/dev/null)"
fi
echo '=== 0097: конец, ничего не менялось ==='
REMOTE
