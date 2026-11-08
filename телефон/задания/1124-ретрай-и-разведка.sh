#!/data/data/com.termux/files/usr/bin/bash
# 1124 — ретрай ssh после часа молчания (banner timeout в 1122/1123).
# Если ssh ожил — сразу разведка топливного пути (для сборщика движка).
echo "== 1124: ретрай ssh + разведка топлива =="
ssh -o BatchMode=yes -o StrictHostKeyChecking=accept-new -o ConnectTimeout=30 root@45.152.198.192 '
echo "SSH-ЖИВ"
echo "--- uptime и нагрузка ---"
uptime
echo ""
echo "--- pm2: боты ---"
pm2 list 2>/dev/null | head -14
echo ""
echo "--- диск ---"
df -h / | tail -1
echo ""
echo "--- read-one-r1110.py: первые 60 строк (как читает и авторизуется) ---"
head -60 /root/kord-glubina/read-one-r1110.py 2>&1
echo ""
echo "--- venv: телеграм-библиотеки ---"
/root/kord-linza/venv/bin/pip list 2>/dev/null | grep -iE "telethon|pyrogram|tdlib|tgcrypto"
echo ""
echo "--- файлы сессий ---"
find /root -maxdepth 4 \( -name "*.session" -o -name "*.session-journal" \) 2>/dev/null | head -10
echo ""
echo "--- /root/kord-glubina ---"
ls -la /root/kord-glubina 2>&1 | head -20
echo "== 1124: конец =="
' 2>&1
echo "== 1124: конец задания =="
