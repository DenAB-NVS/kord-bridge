#!/data/data/com.termux/files/usr/bin/bash
# 1120 — реестр в дом: серверный клон на ветке t37r203, реестр (677441e) на ней — пушуем текущую ветку в main.
echo "== 1120: реестр в дом =="
ssh -o BatchMode=yes -o StrictHostKeyChecking=accept-new -o ConnectTimeout=15 root@45.152.198.192 '
cd /root/kord-glubina/kordinaps-machine || exit 1
R=$(git remote | head -1)
git fetch "$R" main 2>&1 | tail -1
git rebase "$R/main" 2>&1 | tail -1
echo "-- push HEAD:main --"
git push "$R" HEAD:main 2>&1 | tail -3
echo "-- лог --"
git log --oneline -2
'
echo "== 1120: конец =="
