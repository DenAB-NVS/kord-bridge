#!/data/data/com.termux/files/usr/bin/bash
# Автозапуск руки при включении телефона
# Кладётся в ~/.termux/boot/ (см. ИНСТРУКЦИЯ-НОВЫЙ-ТЕЛЕФОН.md)

termux-wake-lock 2>/dev/null
pkill -f kord-sluzhba.sh 2>/dev/null
nohup bash "$HOME/kord-sluzhba.sh" >/dev/null 2>&1 &

echo "рука проснулась при загрузке $(date +%d.%m_%H:%M)"
