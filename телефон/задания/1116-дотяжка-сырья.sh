#!/data/data/com.termux/files/usr/bin/bash
# 1116 — дотяжка: pull --rebase + push для газетного сырья 1115 (клон отстал от коммитов соединителя).
echo "== 1116: дотяжка сырья =="
ssh -o BatchMode=yes -o StrictHostKeyChecking=accept-new -o ConnectTimeout=15 root@45.152.198.192 '
cd /root/kord-glubina/kordinaps-machine || exit 1
git fetch -q origin
git rebase origin/main 2>&1 | tail -2
git push -q origin HEAD:main 2>&1 | tail -1
echo "-- проверка --"
git log --oneline -3
echo "пуш HEAD:main выполнен"
'
echo "== 1116: конец =="
