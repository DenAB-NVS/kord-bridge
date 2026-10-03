#!/data/data/com.termux/files/usr/bin/bash
# Только наличие/метаданные; не запускаем читалку и Telegram, не выводим исходники или секреты.
echo '=== 0021 SHELL КАРТА ЧИТАЛКИ ==='
D="$HOME/рассылка"
F="$D/chitka-kanala.py"
if [ -d "$D" ]; then echo 'READ_DIR_EXISTS yes'; else echo 'READ_DIR_EXISTS no'; fi
if [ -f "$F" ]; then
  echo 'CHITALKA_EXISTS yes'
  wc -c < "$F" | sed 's/^/CHITALKA_BYTES /'
  sha256sum "$F" | cut -d ' ' -f1 | sed 's/^/CHITALKA_SHA256 /'
  for word in iter_messages get_messages get_dialogs send_message TelegramClient; do
    if grep -qF "$word" "$F"; then echo "HAS_${word} yes"; else echo "HAS_${word} no"; fi
  done
else echo 'CHITALKA_EXISTS no'; fi
for rel in sessions/acc1.session sessions/acc2.session канала-дамп.txt; do
  case "$rel" in sessions/acc1.session) key=ACC1;; sessions/acc2.session) key=ACC2;; *) key=DUMP;; esac
  if [ -f "$D/$rel" ]; then echo "${key}_EXISTS yes"; else echo "${key}_EXISTS no"; fi
done
echo '=== КОНЕЦ 0021 ==='
