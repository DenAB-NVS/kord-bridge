#!/data/data/com.termux/files/usr/bin/bash
# Задание 0084 — READ-ONLY: показания сторожа вены + статус окна машины (ночь 07.10)
# Диагноз 0083: туннель цел, вена к api.telegram.org лежит. Сторож должен был это поймать.
# Только чтение. Лечение — утром, по слову владельца.

echo "== 0084: показания сторожа и окна =="

echo "-- лог сторожа (полный, если короткий) --"
wc -l "$HOME/vena-watchdog.log" 2>/dev/null; tail -20 "$HOME/vena-watchdog.log" 2>/dev/null || echo "лог пуст или отсутствует — сторож ни разу не видел молчания"
echo "-- счётчик молчаний --"
cat "$HOME/.vena-watchdog-fails" 2>/dev/null || echo нет
echo "-- время последнего будильника --"
[ -f "$HOME/.vena-watchdog-notified" ] && { t=$(cat "$HOME/.vena-watchdog-notified"); date -d @$t "+%Y-%m-%d %H:%M:%S" 2>/dev/null || echo "$t"; } || echo "будильников не было"
echo "-- контрольный тест вены сейчас --"
curl -m 10 -s -o /dev/null -w '%{http_code}\n' https://api.telegram.org/ 2>/dev/null; echo "(000 = вена всё ещё лежит)"

echo "-- окно машины на сервере: жив ли гейтвей OpenClaw (без токенов) --"
ssh -o BatchMode=yes root@45.152.198.192 'systemctl list-units --type=service --all 2>/dev/null | grep -iE "openclaw|gateway" ; pm2 list 2>/dev/null | grep -iE "openclaw|gateway" ; echo "---"; journalctl --no-pager -n 10 2>/dev/null | grep -iE "openclaw|gateway|telegram" | tail -8 || true'

echo "== 0084: конец (только чтение) =="
