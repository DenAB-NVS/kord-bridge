#!/data/data/com.termux/files/usr/bin/bash
# Задание 0082 — READ-ONLY ОСМОТР СЕРВЕРА: карта здоровья на утро (ночь 07.10)
# Ничего не меняет, ничего не лечит, ничего не перезапускает. Только чтение.
# Цели: (1) живы ли боты и не растут ли счётчики рестартов; (2) какая gh-учётка активна для «машина читает дом»; (3) диск и память.

echo "== 0082: read-only осмотр сервера =="

echo "-- ssh-доступ ключом руки --"
ssh -o BatchMode=yes -o ConnectTimeout=15 root@45.152.198.192 'echo ОК' || { echo "ssh НЕ дошёл — это важная новость для утра"; exit 0; }

echo "-- uptime и ресурсы --"
ssh -o BatchMode=yes root@45.152.198.192 'uptime; echo; df -h / | tail -1; free -m | head -2'

echo "-- pm2: живость и счётчики рестартов (сравнить с 02.10: 645/625/645) --"
ssh -o BatchMode=yes root@45.152.198.192 'pm2 list 2>/dev/null | head -15'

echo "-- туннель на сервере: api.telegram.org через 127.0.0.1 (ждём 302) --"
ssh -o BatchMode=yes root@45.152.198.192 'curl --resolve api.telegram.org:443:127.0.0.1 -s -o /dev/null -w "%{http_code}\n" -m 10 https://api.telegram.org/ 2>/dev/null || echo недоступен'

echo "-- gh-учётка на сервере (для «машина читает дом»; без токенов) --"
ssh -o BatchMode=yes root@45.152.198.192 'command -v gh >/dev/null && gh auth status 2>&1 | grep -vi token || echo "gh не найден в PATH root"'

echo "== 0082: конец (только чтение, изменений нет) =="
