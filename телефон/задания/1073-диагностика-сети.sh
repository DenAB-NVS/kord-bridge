#!/data/data/com.termux/files/usr/bin/bash
# 1073 — ДИАГНОСТИКА СЕТИ РУКИ (тик Р-186): почему ssh до 45.152.198.192 молчит с 08:45 UTC
echo '=== 1073 ДИАГНОСТИКА СЕТИ ==='
date -u
echo '-- TCP 45.152.198.192:22:'
timeout 10 bash -c 'echo > /dev/tcp/45.152.198.192/22' && echo PORT22_OPEN || echo PORT22_FAIL
echo '-- ssh попытка:'
timeout 25 ssh -o BatchMode=yes -o ConnectTimeout=15 -o StrictHostKeyChecking=accept-new root@45.152.198.192 'echo SSH_OK' 2>&1 | tail -8
echo '-- ключи руки:'
ssh-keygen -lf $HOME/.ssh/id_ed25519.pub 2>/dev/null || echo net_id_ed25519.pub
echo '=== КОНЕЦ 1073 ==='
