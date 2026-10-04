#!/data/data/com.termux/files/usr/bin/bash
# 0050: HERMES — запуск через source ./activate в дочернем шелле.
# Причина 0049: run-in-hermes-env ищет hermes как файл, а hermes — shell-функция от source ./activate.
# Решение: bash -c "source ./activate && hermes ..." в корне /root/hermes-src.

echo "--- 0050: HERMES — ЗАПУСК ЧЕРЕЗ ACTIVATE, $(date) ---"
ssh -o BatchMode=yes -o StrictHostKeyChecking=accept-new -o ConnectTimeout=15 root@45.152.198.192 '
echo "=== 1. КАК УСТРОЕНА ФУНКЦИЯ hermes ==="
grep -n -A8 "hermes ()" /root/hermes-src/scripts/_activation.sh 2>/dev/null | head -25 || grep -n -A8 "hermes()" /root/hermes-src/scripts/_activation.sh 2>/dev/null | head -25 || echo "определение не найдено"
echo "=== 2. ВЕРСИЯ ЧЕРЕЗ SOURCE ACTIVATE ==="
cd /root/hermes-src && timeout 180 bash -c "source ./activate && hermes --version" 2>&1 | tail -15
echo "=== 3. СПРАВКА (первые 35 строк) ==="
timeout 180 bash -c "source ./activate && hermes --help" 2>&1 | head -35
echo "=== КОНЕЦ 0050 ==="
' 2>&1
echo "--- КОНЕЦ 0050 ---"
