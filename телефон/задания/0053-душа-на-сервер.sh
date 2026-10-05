#!/data/data/com.termux/files/usr/bin/bash
# 0053: душа — из приватного дома на сервер в ~/.openclaw/workspace/SOUL.md.
# Плюс gh-переключение активной учётки на KordinapsArhanHome (лечение моста).
# Текст души и токен не печатаются никогда.

ssh -o BatchMode=yes root@45.152.198.192 '
TOKEN=$(gh auth token --user DenAB-NVS 2>/dev/null || gh auth token)
rm -rf /tmp/dom-stage
git clone --depth 1 --quiet "https://x-access-token:${TOKEN}@github.com/DenAB-NVS/kordinaps-machine.git" /tmp/dom-stage 2>/dev/null
if [ -f /tmp/dom-stage/projects/soul-stage.md ]; then
  mkdir -p /root/.openclaw/workspace
  cp /tmp/dom-stage/projects/soul-stage.md /root/.openclaw/workspace/SOUL.md
  echo "ДУША ЛЕГЛА: $(wc -c < /root/.openclaw/workspace/SOUL.md) байт"
else
  echo "ОШИБКА: файл души не найден в доме"
fi
rm -rf /tmp/dom-stage
echo
echo "=== gh: активная учётка ==="
gh auth switch --user KordinapsArhanHome && echo "SWITCH OK"
gh auth status 2>&1 | grep -v "Token"
'
