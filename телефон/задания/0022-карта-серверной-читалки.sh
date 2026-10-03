#!/data/data/com.termux/files/usr/bin/bash
# Только метаданные: не запускать Telegram, не выводить токены, конфиги, исходники или сообщения.
echo '=== 0022 СЕРВЕРНАЯ ЧИТАЛКА ==='
ssh -o BatchMode=yes -o StrictHostKeyChecking=accept-new -o ConnectTimeout=15 root@45.152.198.192 'bash -s' <<'REMOTE'
D=/root/рассылка
if [ -d "$D" ]; then echo 'READ_DIR_EXISTS yes'; else echo 'READ_DIR_EXISTS no'; fi
if command -v python3 >/dev/null 2>&1; then echo 'PYTHON3_AVAILABLE yes'; else echo 'PYTHON3_AVAILABLE no'; fi
for rel in chitka-kanala.py sessions/acc1.session sessions/acc2.session канала-дамп.txt; do
 case "$rel" in chitka-kanala.py) key=CHITALKA;; sessions/acc1.session) key=ACC1;; sessions/acc2.session) key=ACC2;; *) key=DUMP;; esac
 if [ -f "$D/$rel" ]; then echo "${key}_EXISTS yes"; else echo "${key}_EXISTS no"; fi
done
if [ -f "$D/chitka-kanala.py" ]; then
 wc -c < "$D/chitka-kanala.py" | sed 's/^/CHITALKA_BYTES /'
 for word in iter_messages get_dialogs TelegramClient send_message; do
  if grep -qF "$word" "$D/chitka-kanala.py"; then echo "HAS_${word} yes"; else echo "HAS_${word} no"; fi
 done
fi
REMOTE
echo '=== КОНЕЦ 0022 ==='
