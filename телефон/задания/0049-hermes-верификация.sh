#!/data/data/com.termux/files/usr/bin/bash
# 0049: HERMES — финальная верификация через официальный scripts/run-in-hermes-env.
# Активация 0048 прошла: зависимости установлены (pm + uv.lock, hash-verified).
# hermes — shell-функция внутри ворктри; для неинтерактивных запусков — run-in-hermes-env.

echo "--- 0049: HERMES — ВЕРИФИКАЦИЯ, $(date) ---"
ssh -o BatchMode=yes -o StrictHostKeyChecking=accept-new -o ConnectTimeout=15 root@45.152.198.192 '
echo "=== 1. ВЕРСИЯ HERMES ==="
cd /root/hermes-src && timeout 180 scripts/run-in-hermes-env hermes --version 2>&1 | tail -10
echo "=== 2. ГЛАВНЫЕ КОМАНДЫ (первые 30 строк help) ==="
timeout 180 scripts/run-in-hermes-env hermes --help 2>&1 | head -30
echo "=== 3. СРЕДА ЦЕЛОСТНА ==="
ls -la /root/hermes-src/scripts/run-in-hermes-env
echo "=== КОНЕЦ 0049 ==="
' 2>&1
echo "--- КОНЕЦ 0049 ---"
