#!/data/data/com.termux/files/usr/bin/bash
# Задание 0108 — ПЕЧАТЬ ДУШИ v3: полная запечатанная копия workspace OpenClaw на телефон (14.10, по слову владельца)
# Расширение печати 0090 (там были только КАРТА-ДУШИ + душа/): теперь весь workspace брата — с тетрадями и дневниками.
# Не ходит через GitHub: телефон тянет архив напрямую с сервера своим SSH-ключом.
# В эхо — только размер и хэш, содержимое не печатается.

echo "== 0108: печать души v3 (полный workspace) =="

D="$HOME/душа-печать"
mkdir -p "$D"
F="$D/openclaw-workspace-$(date +%Y-%m-%d).tar.gz"

ssh -o BatchMode=yes -o ConnectTimeout=25 root@45.152.198.192 \
  'tar -czf - -C /root/.openclaw/workspace .' > "$F" 2>$HOME/.ssh-err

if [ ! -s "$F" ]; then
  echo "SSH/архив не пришёл:"; head -3 $HOME/.ssh-err 2>/dev/null
  rm -f "$F"; exit 1
fi

SZ=$(wc -c < "$F")
[ "$SZ" -gt 5000 ] || { echo "архив подозрительно мал: $SZ байт — не принимаю"; rm -f "$F"; exit 1; }
tar -tzf "$F" >/dev/null 2>&1 || { echo "архив битый — не принимаю"; rm -f "$F"; exit 1; }

SHA=$(sha256sum "$F" | cut -c1-16)
echo "печать души v3 принята: $(basename "$F"), $SZ байт, sha256:$SHA"
echo "внутри: полный workspace OpenClaw (душа, тетради, дневники, карта). Содержимое не выводится."
echo "== 0108: конец =="
