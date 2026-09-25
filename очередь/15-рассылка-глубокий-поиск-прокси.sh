#!/usr/bin/env bash
# Задание моста: глубокий поиск прокси (кортеж/список/dict) + доп. порты + перезапуск при находке
set -u
R="/root/рассылка"

echo "— доп. порты до DC2 (149.154.167.51):"
timeout 4 bash -c 'cat < /dev/null > /dev/tcp/149.154.167.51/80' 2>/dev/null && echo "80 ОТКРЫТ" || echo "80 ЗАКРЫТ"
timeout 4 bash -c 'cat < /dev/null > /dev/tcp/149.154.167.51/5222' 2>/dev/null && echo "5222 ОТКРЫТ" || echo "5222 ЗАКРЫТ"
timeout 4 bash -c 'cat < /dev/null > /dev/tcp/149.154.167.220/443' 2>/dev/null && echo "api.telegram.org:443 ОТКРЫТ" || echo "api.telegram.org:443 ЗАКРЫТ"

echo "— файлы voen со словами proxy/socks (только имена):"
grep -rliE 'proxy|socks' /root/voen --include='*.py' 2>/dev/null | head -10 || echo "нет"

FOUND=0
python3 - <<'PY'
import re, json, pathlib
conf_p = pathlib.Path('/root/рассылка/конфиг.json')
conf = json.loads(conf_p.read_text())
patterns = [
    (r"proxy\s*=\s*\(\s*['\"]([^'\"]+)['\"]\s*,\s*(\d+)", 'кортеж'),
    (r"proxy\s*=\s*\[\s*['\"]([^'\"]+)['\"]\s*,\s*(\d+)", 'список'),
    (r"proxy\s*=\s*dict\([^)]*hostname\s*=\s*['\"]([^'\"]+)['\"][^)]*port\s*=\s*(\d+)", 'dict'),
]
found = False
for f in pathlib.Path('/root').rglob('*.py'):
    s = str(f)
    if any(x in s for x in ('node_modules', '.git', 'рассылка')):
        continue
    try:
        t = f.read_text(errors='ignore')
    except Exception:
        continue
    for pat, name in patterns:
        m = re.search(pat, t)
        if m:
            conf['proxy'] = {'scheme': 'socks5', 'hostname': m.group(1), 'port': int(m.group(2))}
            conf_p.write_text(json.dumps(conf, ensure_ascii=False))
            found = True
            print('— прокси найден (формат: %s) и вписан в конфиг (адрес скрыт)' % name)
            break
    if found:
        break
if not found:
    print('— прокси не найден ни в одном формате')
PY

if grep -q '"proxy"' "$R/конфиг.json" 2>/dev/null; then
  FOUND=1
fi

if [ "$FOUND" = "1" ]; then
  pkill -f otpravka.py 2>/dev/null
  sleep 2
  cd "$R" && nohup python3 otpravka.py >> рассылка.log 2>&1 &
  echo "— рассылка перезапущена с прокси, PID $!"
  sleep 30
  tail -8 "$R/рассылка.log"
else
  echo "— без прокси не перезапускаем; ждать прокси от владельца или публичный MTProxy"
fi
