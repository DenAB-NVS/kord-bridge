#!/bin/bash
# 0018: эхо телефона — таймер, коммитящий выводы пульта в kord-echo раз в 3 минуты
mkdir -p ~/kord-echo/эхо-телефон

cat > ~/kord-telefon.sh << 'SH'
#!/bin/bash
if [ -f ~/kord-echo/.git/index.lock ]; then
  exit 0
fi
cd ~/kord-echo || exit 1
if [ -n "$(git status --porcelain эхо-телефон)" ]; then
  git add эхо-телефон
  git commit -m "эхо телефона: $(date +%d.%m_%H:%M)" >/dev/null 2>&1
  git push origin main >/dev/null 2>&1
fi
SH
chmod +x ~/kord-telefon.sh

cat > /etc/systemd/system/kord-telefon.service << 'UNIT'
[Unit]
Description=Kord echo telefon commit
[Service]
Type=oneshot
ExecStart=/root/kord-telefon.sh
UNIT

cat > /etc/systemd/system/kord-telefon.timer << 'TIMER'
[Unit]
Description=Kord echo telefon timer
[Timer]
OnBootSec=2min
OnUnitActiveSec=3min
[Install]
WantedBy=timers.target
TIMER

systemctl daemon-reload
systemctl enable --now kord-telefon.timer
systemctl list-timers kord-telefon.timer --no-pager | head -3
echo "ЭХО ТЕЛЕФОНА ПОДКЛЮЧЕНО: таймер kord-telefon каждые 3 минуты коммитит выводы пульта из ~/kord-echo/эхо-телефон"
