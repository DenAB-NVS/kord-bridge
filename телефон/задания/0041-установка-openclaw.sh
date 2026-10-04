#!/data/data/com.termux/files/usr/bin/bash
# 0041: УСТАНОВКА OPENCLAW на kord-vps-01 — ночь памяти, фаза 1.
# Тихая установка без onboarding: официальный флаг --no-onboard (docs.openclaw.ai/install).
# Секретов нет: API-ключ модели подключит Денис позже сам, интерактивно.
# Ожидаемая длительность: до 10 минут (Node 24 + npm-пакет). Молчание руки в это время — норма.

echo "--- 0041: УСТАНОВКА OPENCLAW, $(date) ---"
ssh -o BatchMode=yes -o StrictHostKeyChecking=accept-new -o ConnectTimeout=15 root@45.152.198.192 '
echo "=== ДО УСТАНОВКИ ==="
node -v 2>/dev/null; npm -v 2>/dev/null
echo "=== УСТАНОВКА (тихая, без onboarding) ==="
curl -fsSL https://openclaw.ai/install.sh | bash -s -- --no-onboard 2>&1 | tail -40
echo "=== ПРОВЕРКА ==="
export PATH="$PATH:/usr/local/bin:/root/.local/bin:/root/.npm-global/bin"
hash -r 2>/dev/null
which openclaw 2>/dev/null || echo "openclaw не в PATH — смотрим пути ниже"
ls -la /root/.openclaw 2>/dev/null || true
openclaw --version 2>&1 || true
echo "=== КОНЕЦ 0041 ==="
' 2>&1
echo "--- КОНЕЦ 0041 ---"
