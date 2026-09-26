#!/bin/bash
# 0019: ускорение эха телефона — таймер с 3 минут до 30 секунд
cat > /etc/systemd/system/kord-telefon.timer << 'TIMER'
[Unit]
Description=Kord echo telefon timer
[Timer]
OnBootSec=1min
OnUnitActiveSec=30sec
[Install]
WantedBy=timers.target
TIMER

systemctl daemon-reload
systemctl restart kord-telefon.timer
systemctl list-timers kord-telefon.timer --no-pager | head -3
echo "ЭХО ТЕЛЕФОНА УСКОРЕНО: таймер kord-telefon теперь каждые 30 секунд"
