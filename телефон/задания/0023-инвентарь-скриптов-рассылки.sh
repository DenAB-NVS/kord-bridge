#!/data/data/com.termux/files/usr/bin/bash
# Только имена .py и .sh в /root/рассылка, без содержимого, конфигов, сессий и сообщений.
echo '=== 0023 ИНВЕНТАРЬ СКРИПТОВ ==='
ssh -o BatchMode=yes -o StrictHostKeyChecking=accept-new -o ConnectTimeout=15 root@45.152.198.192 'bash -s' <<'REMOTE'
if [ -d /root/рассылка ]; then
 find /root/рассылка -maxdepth 2 -type f \( -name '*.py' -o -name '*.sh' \) ! -path '*/sessions/*' ! -name '*env*' -printf '%P\n' | sort | head -60
else
 echo 'READ_DIR_ABSENT'
fi
REMOTE
echo '=== КОНЕЦ 0023 ==='
