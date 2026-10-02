#!/data/data/com.termux/files/usr/bin/bash
# 0005: УСКОРЕНИЕ РУКИ v3
# Рука проверяет мост каждые 30 секунд. Сам цикл v3 не создаёт пустых коммитов:
# здоровье раз в 10 минут, задания и дозор — сразу.

cat > "$HOME/kord-sluzhba.sh" <<'SLUZHBA'
#!/data/data/com.termux/files/usr/bin/bash
while true; do
  bash "$HOME/kord-cikl.sh" >> "$HOME/kord-sluzhba.log" 2>&1
  sleep 30
done
SLUZHBA
chmod +x "$HOME/kord-sluzhba.sh"
pkill -f kord-sluzhba.sh 2>/dev/null
nohup bash "$HOME/kord-sluzhba.sh" >/dev/null 2>&1 &
echo "РУКА v3: задания проверяются каждые 30 секунд; пустых коммитов нет"
