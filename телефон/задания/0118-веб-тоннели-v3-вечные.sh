#!/data/data/com.termux/files/usr/bin/bash
# 0118 — ВЕБ-ТУННЕЛИ v3: вечные циклы по паттерну kord-tunnel.sh (вены).
# Задание ставит на телефоне ~/kord-webtunnel.sh (3 цикла: fl.ru, smartcaptcha, kwork)
# и будит их. Живут сами, переподнимаются каждые 15 с. Идемпотентно.
echo '=== 0118 ВЕБ-ТУННЕЛИ v3 (вечные, паттерн вены) ==='

# 1) устанавливаем вечный цикл (если нет или изменился)
cat > "$HOME/kord-webtunnel.sh" <<'WT'
#!/data/data/com.termux/files/usr/bin/bash
# Вечные веб-тоннели: сервер 127.0.0.2-4:443 → сайты через IP телефона.
# Стоп: touch /root/kord-linza/СТОП-ВЕБ на сервере (циклы сами завершатся на следующем круге).
SRV="root@45.152.198.192"
OPTS="-o BatchMode=yes -o ExitOnForwardFailure=yes -o ServerAliveInterval=20 -o ConnectTimeout=15"
loop() {  # $1=метка $2=ip:порт $3=хост
  while true; do
    if ssh $SRV 'test -f /root/kord-linza/СТОП-ВЕБ' 2>/dev/null; then exit 0; fi
    ssh -N -R "$2:$3:443" $OPTS "$SRV" >/dev/null 2>&1
    sleep 15
  done
}
loop fl     "127.0.0.2:443" "www.fl.ru" &
loop capt   "127.0.0.3:443" "smartcaptcha.yandexcloud.net" &
loop kwork  "127.0.0.4:443" "kwork.ru" &
wait
WT
chmod +x "$HOME/kord-webtunnel.sh"

# 2) уже бежит? не дублируем
if pgrep -f kord-webtunnel.sh >/dev/null 2>&1; then
  echo 'WEBTUNNEL_CYCLES already running'
else
  setsid nohup "$HOME/kord-webtunnel.sh" >/dev/null 2>&1 &
  echo 'WEBTUNNEL_CYCLES started'
fi
sleep 8

# 3) проверка с сервера
RES=$(ssh -o BatchMode=yes -o StrictHostKeyChecking=accept-new -o ConnectTimeout=15 root@45.152.198.192 'ss -tln | grep -cE "127.0.0.[234]:443"' 2>/dev/null)
echo "LISTENERS $RES/3"
echo '=== КОНЕЦ 0118 ==='
