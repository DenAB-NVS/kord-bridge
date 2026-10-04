#!/data/data/com.termux/files/usr/bin/bash
# 0048: HERMES — активация из сырцов (клон /root/hermes-src уже лежит с 0047).
# Путь: activate + PM (пакетный менеджер) — из README/CONTRIBUTING.
# Проверяем на заблокированный домен ДО запуска; активация с таймаутом 5 минут.

echo "--- 0048: HERMES — АКТИВАЦИЯ ИЗ СЫРЦОВ, $(date) ---"
ssh -o BatchMode=yes -o StrictHostKeyChecking=accept-new -o ConnectTimeout=15 root@45.152.198.192 '
echo "=== 1. ОСТАЛЬНЫЕ ФАЙЛЫ РЕПОЗИТОРИЯ (20-70) ==="
ls /root/hermes-src | sed -n "20,70p"
echo "=== 2. ACTIVATE — ПЕРВЫЕ 60 СТРОК ==="
head -60 /root/hermes-src/activate
echo "=== 3. ЗАБЛОКИРОВАННЫЙ ДОМЕН В ACTIVATE ==="
grep -n "nousresearch.com" /root/hermes-src/activate 2>/dev/null | head -5 || echo "в activate домен не найден"
echo "=== 4. CONTRIBUTING — DEVELOPMENT SETUP ==="
sed -n "/Development Setup/,/^## /p" /root/hermes-src/CONTRIBUTING.md 2>/dev/null | head -50 || echo "раздел не найден"
echo "=== 5. АКТИВАЦИЯ (таймаут 5 минут) ==="
cd /root/hermes-src && timeout 300 bash ./activate 2>&1 | tail -30 || echo "активация завершилась таймаутом или ошибкой — вывод выше"
echo "=== 6. ПРОВЕРКА ==="
export PATH="/root/hermes-src/.pm/bin:/root/.hermes/bin:$PATH"
which hermes 2>/dev/null || echo "hermes не в PATH"
hermes --version 2>&1 | head -3 || true
echo "=== КОНЕЦ 0048 ==="
' 2>&1
echo "--- КОНЕЦ 0048 ---"
