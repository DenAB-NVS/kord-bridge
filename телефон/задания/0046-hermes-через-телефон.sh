#!/data/data/com.termux/files/usr/bin/bash
# 0046: HERMES — обходной путь через сеть телефона.
# Причина: сервер не скачал install.sh с hermes-agent.nousresearch.com (задание 0045, адрес верный по README).
# Гипотеза: селективная блокировка домена на сети сервера (как было с Telegram 26.09–02.10).
# План: (1) телефон скачивает установщик своей сетью, (2) осмотр: какие URL он тянет,
# (3) диагностика сети сервера, (4) передача и запуск установщика на сервере через SSH, таймаут 7 минут.

echo "--- 0046: HERMES — ОБХОДНОЙ ПУТЬ, $(date) ---"
echo "=== 1. ТЕЛЕФОН СКАЧИВАЕТ УСТАНОВЩИК ==="
if curl -fsSL --max-time 30 https://hermes-agent.nousresearch.com/install.sh -o /tmp/hermes-install-phone.sh; then
  echo "ТЕЛЕФОН СКАЧАЛ: $(wc -c < /tmp/hermes-install-phone.sh) байт"
  echo "=== URL ВНУТРИ УСТАНОВЩИКА (первые 10) ==="
  grep -oE "https://[a-zA-Z0-9./_-]+" /tmp/hermes-install-phone.sh | sort -u | head -10
else
  echo "ТЕЛЕФОН ТОЖЕ НЕ СКАЧАЛ — домен недоступен и из сети телефона"
fi
ssh -o BatchMode=yes -o StrictHostKeyChecking=accept-new -o ConnectTimeout=15 root@45.152.198.192 '
echo "=== 2. ДИАГНОСТИКА СЕТИ СЕРВЕРА ==="
getent hosts hermes-agent.nousresearch.com || echo "DNS: домен не разрешается"
curl -sS -o /dev/null -w "install.sh с сервера: %{http_code} за %{time_total}s\n" --max-time 20 https://hermes-agent.nousresearch.com/install.sh || echo "сервер: curl не прошёл"
curl -sS -o /dev/null -w "github.com (контроль): %{http_code}\n" --max-time 15 https://github.com || true
' 2>&1
if [ -f /tmp/hermes-install-phone.sh ]; then
  echo "=== 3. ПЕРЕДАЧА И ЗАПУСК НА СЕРВЕРЕ (таймаут 7 минут) ==="
  ssh -o BatchMode=yes -o StrictHostKeyChecking=accept-new -o ConnectTimeout=15 root@45.152.198.192 'timeout 420 bash -s' < /tmp/hermes-install-phone.sh 2>&1 | tail -35
  echo "=== 4. ПРОВЕРКА ==="
  ssh -o BatchMode=yes -o StrictHostKeyChecking=accept-new -o ConnectTimeout=15 root@45.152.198.192 '
  export PATH="$PATH:/root/.local/bin:/root/.hermes/bin"
  which hermes 2>/dev/null || echo "hermes не в PATH"
  ls -la /root/.hermes 2>/dev/null | head -8 || true
  hermes --version 2>&1 | head -3 || true
  ' 2>&1
fi
echo "--- КОНЕЦ 0046 ---"
