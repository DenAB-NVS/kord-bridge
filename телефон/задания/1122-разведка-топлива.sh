#!/data/data/com.termux/files/usr/bin/bash
# 1122 — разведка топливного пути: как read-one-r1110.py читает чаты Telegram
# (библиотека, сессия, venv, структура). Только взгляд, ничего не меняется.
# Цель: собрать живое топливо (поток.jsonl) для движка тем же механизмом.
echo "== 1122: разведка топливного пути =="
ssh -o BatchMode=yes -o StrictHostKeyChecking=accept-new -o ConnectTimeout=15 root@45.152.198.192 '
echo "--- read-one-r1110.py: первые 60 строк (как читает и как авторизуется) ---"
head -60 /root/kord-glubina/read-one-r1110.py 2>&1
echo ""
echo "--- venv: телеграм-библиотеки ---"
/root/kord-linza/venv/bin/pip list 2>/dev/null | grep -iE "telethon|pyrogram|tdlib|tgcrypto"
echo ""
echo "--- файлы сессий (где живёт авторизация) ---"
find /root -maxdepth 4 \( -name "*.session" -o -name "*.session-journal" \) 2>/dev/null | head -10
echo ""
echo "--- /root/kord-glubina: что лежит ---"
ls -la /root/kord-glubina 2>&1 | head -20
echo ""
echo "--- /root/kord-linza: структура ---"
ls /root/kord-linza 2>&1 | head -10
echo "== 1122: конец =="
'
