#!/data/data/com.termux/files/usr/bin/bash
# 0047: HERMES — установка из GitHub-зеркала (домен nousresearch заблокирован в сети).
# Доказано 0046: DNS сервера отвечает, соединение режется (000/timeout); github.com с сервера — 200.
# План: клон репозитория с github → осмотр install.sh → sed-подмена домена на raw.githubusercontent.com → запуск с таймаутом.

echo "--- 0047: HERMES ИЗ GITHUB, $(date) ---"
ssh -o BatchMode=yes -o StrictHostKeyChecking=accept-new -o ConnectTimeout=15 root@45.152.198.192 '
echo "=== 1. КЛОН РЕПОЗИТОРИЯ ==="
rm -rf /root/hermes-src
git clone --depth 1 https://github.com/NousResearch/hermes-agent /root/hermes-src 2>&1 | tail -5
echo "--- файлы репозитория (первые 20) ---"
ls /root/hermes-src | head -20
echo "=== 2. ОСМОТР INSTALL.SH (первые 40 строк) ==="
head -40 /root/hermes-src/install.sh
echo "--- URL внутри install.sh ---"
grep -oE "https://[a-zA-Z0-9./_-]+" /root/hermes-src/install.sh | sort -u | head -15
echo "=== 3. ЗАМЕНА ДОМЕНА И ЗАПУСК (таймаут 7 минут) ==="
sed "s|https://hermes-agent.nousresearch.com|https://raw.githubusercontent.com/NousResearch/hermes-agent/main|g" /root/hermes-src/install.sh > /tmp/hermes-install-fixed.sh
timeout 420 bash /tmp/hermes-install-fixed.sh 2>&1 | tail -35 || echo "установка завершилась таймаутом или ошибкой — вывод выше"
echo "=== 4. ПРОВЕРКА ==="
export PATH="$PATH:/root/.local/bin:/root/.hermes/bin"
hash -r 2>/dev/null
which hermes 2>/dev/null || echo "hermes не в PATH — ищем"
ls -la /root/.hermes 2>/dev/null | head -8 || true
hermes --version 2>&1 | head -3 || true
echo "=== КОНЕЦ 0047 ==="
' 2>&1
echo "--- КОНЕЦ 0047 ---"
