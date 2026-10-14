#!/data/data/com.termux/files/usr/bin/bash
# Задание 0105 (после 0104) — ПЕЧАТЬ ДОМА HERMES: запечатанная копия workspace Hermes на телефон (14.10, по слову владельца)
# Дом Hermes не ходит через GitHub на телефон: телефон тянет архив напрямую с сервера своим SSH-ключом.
# В эхо — только размер и хэш, содержимое не печатается.

echo "== 0105: печать дома Hermes =="

D="$HOME/hermes-печать"
mkdir -p "$D"
F="$D/hermes-home-$(date +%Y-%m-%d).tar.gz"

ssh -o BatchMode=yes -o ConnectTimeout=25 root@45.152.198.192 \
  'tar -czf - -C /root/.hermes/workspace --exclude=".git" .' > "$F" 2>$HOME/.ssh-err

if [ ! -s "$F" ]; then
  echo "SSH/архив не пришёл:"; head -3 $HOME/.ssh-err 2>/dev/null
  rm -f "$F"; exit 1
fi

SZ=$(wc -c < "$F")
[ "$SZ" -gt 5000 ] || { echo "архив подозрительно мал: $SZ байт — не принимаю"; rm -f "$F"; exit 1; }
tar -tzf "$F" >/dev/null 2>&1 || { echo "архив битый — не принимаю"; rm -f "$F"; exit 1; }

# Печать = запечатанный сейф (как 0106 у брата): несёт ВСЁ, включая мои тетради и мою копию души.
# Разделение носителей: GitHub (hermes-home) — без сокровенного; рука — полный сейф. В эхо — только размер и хэш.
echo "внутри: полный workspace Hermes (память, дневники, тетради, моя копия карты души). Содержимое не выводится."

SHA=$(sha256sum "$F" | cut -c1-16)
echo "печать дома Hermes принята: $(basename "$F"), $SZ байт, sha256:$SHA"
echo "хранение: телефон руки, физически у владельца. Содержимое не выводится."
echo "== 0105: конец =="
