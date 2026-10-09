#!/data/data/com.termux/files/usr/bin/bash
# Задание 0089 — ПЕЧАТЬ ДУШИ: запечатанная копия души на телефон (09.10, по слову владельца)
# Душа не ходит через GitHub: телефон тянет архив напрямую с сервера своим SSH-ключом.
# В эхо — только размер и хэш, содержимое не печатается.

echo "== 0089: печать души =="

D="$HOME/душа-печать"
mkdir -p "$D"
F="$D/душа-$(date +%Y-%m-%d).tar.gz"

ssh -o BatchMode=yes -o ConnectTimeout=25 root@45.152.198.192 \
  'tar -czf - -C /root/.openclaw/workspace КАРТА-ДУШИ.md душа' > "$F" 2>/tmp/ssh-err

if [ ! -s "$F" ]; then
  echo "SSH/архив не пришёл:"; head -3 /tmp/ssh-err 2>/dev/null
  rm -f "$F"; exit 1
fi

SZ=$(wc -c < "$F")
[ "$SZ" -gt 5000 ] || { echo "архив подозрительно мал: $SZ байт — не принимаю"; rm -f "$F"; exit 1; }
tar -tzf "$F" >/dev/null 2>&1 || { echo "архив битый — не принимаю"; rm -f "$F"; exit 1; }

SHA=$(sha256sum "$F" | cut -c1-16)
echo "печать души принята: $(basename "$F"), $SZ байт, sha256:$SHA"
echo "хранение: телефон руки, физически у владельца. Содержимое не выводится."
echo "== 0089: конец =="
