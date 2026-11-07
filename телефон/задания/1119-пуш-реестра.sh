#!/data/data/com.termux/files/usr/bin/bash
# 1119 — повторить пуш реестра каналов (1118) в дом: подтянуть серверный клон через rebase и запушить.
echo "== 1119: пуш реестра =="
ssh -o BatchMode=yes -o StrictHostKeyChecking=accept-new -o ConnectTimeout=15 root@45.152.198.192 '
cd /root/kord-glubina/kordinaps-machine || exit 1
R=$(git remote | head -1)
echo "-- fetch+rebase --"
git fetch "$R" main 2>&1 | tail -1
git rebase "$R/main" 2>&1 | tail -3
echo "-- push --"
git push "$R" main 2>&1 | tail -3
echo "-- лог --"
git log --oneline -3
echo "-- реестр в клоне --"
ls -la "проекты/РЕЕСТР-КАНАЛОВ-2026-11-08.md" 2>&1
'
echo "== 1119: конец =="
