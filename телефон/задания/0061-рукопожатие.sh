#!/data/data/com.termux/files/usr/bin/bash
# 0061: рукопожатие — утвердить спаривание Telegram (код TF53N8PM, пользователь 7650680553).

ssh -o BatchMode=yes -o ConnectTimeout=15 root@45.152.198.192 '
openclaw pairing approve telegram TF53N8PM
echo
echo "--- статус спаривания:"
openclaw pairing list 2>&1 | head -10
'
