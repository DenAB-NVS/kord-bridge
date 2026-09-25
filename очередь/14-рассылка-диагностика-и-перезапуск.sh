#!/usr/bin/env bash
# Задание моста: диагностика сети Telegram + прокси из кода + перезапуск рассылки при необходимости
set -u
R="/root/рассылка"

echo "— процесс рассылки жив? $(pgrep -f otpravka.py >/dev/null && echo ДА || echo НЕТ)"
echo "— последние 12 строк лога:"
tail -12 "$R/рассылка.log" 2>/dev/null || echo "лога нет"
echo "— отчёт:"
cat "$R/отчёт-рассылки.txt" 2>/dev/null || echo "отчёт пуст"

echo "— сеть до Telegram DC:"
timeout 5 bash -c 'cat < /dev/null > /dev/tcp/149.154.167.51/443' 2>/dev/null && echo "DC2:443 ОТКРЫТ" || echo "DC2:443 ЗАКРЫТ"
timeout 5 bash -c 'cat < /dev/null > /dev/tcp/149.154.175.53/443' 2>/dev/null && echo "DC4:443 ОТКРЫТ" || echo "DC4:443 ЗАКРЫТ"

python3 - <<'PY'
import re, json, pathlib
conf_p = pathlib.Path('/root/рассылка/конфиг.json')
conf = json.loads(conf_p.read_text())
found = False
for f in pathlib.Path('/root').rglob('*.py'):
    s = str(f)
    if any(x in s for x in ('node_modules', '.git', 'рассылка')):
        continue
    try:
        t = f.read_text(errors='ignore')
    except Exception:
        continue
    m = re.search(r'proxy\s*=\s*dict\(([^)]+)\)', t)
    if m:
        args = m.group(1)
        h = re.search(r"hostname\s*=\s*['\"]([^'\"]+)", args)
        p = re.search(r'port\s*=\s*(\d+)', args)
        sc = re.search(r"scheme\s*=\s*['\"]([^'\"]+)", args)
        if h and p:
            conf['proxy'] = {'scheme': sc.group(1) if sc else 'socks5', 'hostname': h.group(1), 'port': int(p.group(1))}
            conf_p.write_text(json.dumps(conf, ensure_ascii=False))
            found = True
            print('— прокси найден и вписан в конфиг (адрес скрыт)')
            break
if not found:
    print('— прокси в коде не найден')
PY

python3 -c "import socks" 2>/dev/null || pip3 install --quiet pysocks python-socks 2>/dev/null || true

if ! pgrep -f otpravka.py >/dev/null; then
  SENT=$(grep -c '^OK' "$R/отчёт-рассылки.txt" 2>/dev/null || echo 0)
  TOTAL=$(python3 -c "import json;print(len(json.load(open('$R/лиды.json'))))" 2>/dev/null || echo 7)
  if [ "$SENT" -lt "$TOTAL" ]; then
    cd "$R" && nohup python3 otpravka.py >> рассылка.log 2>&1 &
    echo "— рассылка перезапущена, PID $!"
    sleep 30
    tail -8 "$R/рассылка.log"
  else
    echo "— всё отправлено, перезапуск не нужен"
  fi
fi
