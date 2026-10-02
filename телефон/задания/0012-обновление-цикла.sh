#!/data/data/com.termux/files/usr/bin/bash
# 0012: ОБНОВЛЕНИЕ ЦИКЛА РУКИ ДО v3 — тихое эхо.
# Копируем свежий kord-cikl.sh из моста (v3 от 16:28), перезапускаем службу.
# Безопасность: помечаем себя исполненным ДО перезапуска (нет двойного исполнения);
# туннель не трогаем — он отдельный процесс.

echo "--- 0012: ОБНОВЛЕНИЕ ЦИКЛА, $(date) ---"
cp "$HOME/kord-bridge/kord-cikl.sh" "$HOME/kord-cikl.sh" && echo "kord-cikl.sh обновлён из моста"
wc -l "$HOME/kord-cikl.sh"
grep -qxF "0012-обновление-цикла.sh" "$HOME/kord-vypolneno.txt" 2>/dev/null || echo "0012-обновление-цикла.sh" >> "$HOME/kord-vypolneno.txt"
pkill -f kord-sluzhba.sh 2>/dev/null
sleep 2
nohup bash "$HOME/kord-sluzhba.sh" >/dev/null 2>&1 &
sleep 5
pgrep -af kord-sluzhba || echo "СЛУЖБА НЕ ПОДНЯЛАСЬ"
echo "--- КОНЕЦ ---"
