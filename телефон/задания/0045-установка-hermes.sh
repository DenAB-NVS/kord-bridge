#!/data/data/com.termux/files/usr/bin/bash
# 0045: УСТАНОВКА HERMES AGENT (Nous Research, MIT) — агент-компаньон с непрерывной памятью.
# Ночь памяти, фаза 2. Аккуратно: сначала осмотр установщика, потом запуск с таймаутом 5 минут
# (чтобы интерактив, если он есть, не повесил руку), потом проверка версии.
# Секретов нет: модель подключит Денис позже (hermes model).

echo "--- 0045: УСТАНОВКА HERMES, $(date) ---"
ssh -o BatchMode=yes -o StrictHostKeyChecking=accept-new -o ConnectTimeout=15 root@45.152.198.192 '
echo "=== 1. ОСМОТР УСТАНОВЩИКА (первые 30 строк) ==="
if curl -fsSL https://hermes-agent.nousresearch.com/install.sh -o /tmp/hermes-install.sh 2>/dev/null; then
  head -30 /tmp/hermes-install.sh
else
  echo "УСТАНОВЩИК НЕ СКАЧАЛСЯ — проверить адрес"
fi
echo "=== 2. УСТАНОВКА (таймаут 5 минут) ==="
timeout 300 bash /tmp/hermes-install.sh 2>&1 | tail -30 || echo "установщик завершился таймаутом или ошибкой — смотрим вывод выше"
echo "=== 3. ПРОВЕРКА ==="
export PATH="$PATH:/usr/local/bin:/root/.local/bin:/root/.hermes/bin"
hash -r 2>/dev/null
which hermes 2>/dev/null || echo "hermes не в PATH — ищем"
ls -la /root/.hermes 2>/dev/null | head -10 || true
hermes --version 2>&1 | head -5 || true
echo "=== КОНЕЦ 0045 ==="
' 2>&1
echo "--- КОНЕЦ 0045 ---"
