#!/data/data/com.termux/files/usr/bin/bash
# 1117 — свежий срез газетного сырья: строки 04–07.11 по всем 9 каналам + эхо-дубликат.
echo "== 1117: свежий срез =="
ssh -o BatchMode=yes -o StrictHostKeyChecking=accept-new -o ConnectTimeout=15 root@45.152.198.192 '
S=/root/kord-glubina/газета-сбор-2026-11-07.txt
grep -E "2026-11-0[4-7]" "$S" > /root/kord-glubina/газета-свежее-2026-11-07.txt
W=$(wc -l < /root/kord-glubina/газета-свежее-2026-11-07.txt)
echo "строк в свежем срезе: $W"
cat /root/kord-glubina/газета-свежее-2026-11-07.txt
cd /root/kord-glubina/kordinaps-machine || exit 1
cp /root/kord-glubina/газета-свежее-2026-11-07.txt "проекты/ГАЗЕТА-сборы/2026-11-07-свежее-72ч.md"
git add "проекты/ГАЗЕТА-сборы/2026-11-07-свежее-72ч.md"
git commit -q -m "ГАЗЕТА свежий срез 72ч 07.11 (по слову владельца)"
git push -q origin HEAD:main 2>&1 | tail -1
echo "пуш HEAD:main выполнен"
'
echo "== 1117: конец =="
