#!/data/data/com.termux/files/usr/bin/bash
# 1135 — канарейка: почему рука не берёт задания. Показывает HEAD клона моста,
# последние задания в локальном клоне и есть ли 1134 в журнале исполненного.
echo "== 1135: канарейка =="
date
echo "--- HEAD клона моста на телефоне ---"
git -C ~/kord-bridge rev-parse --short HEAD 2>&1
git -C ~/kord-bridge log -1 --format='%ci %s' 2>&1
echo "--- последние задания в локальном клоне ---"
ls ~/kord-bridge/телефон/задания/ | tail -5
echo "--- 1134 в журнале исполненного? ---"
grep -n "1134" ~/kord-vypolneno.txt 2>/dev/null || echo "1134 НЕ в vypolneno"
echo "--- служба жива? ---"
pgrep -af kord-sluzhba | head -2
echo "== 1135: конец =="
