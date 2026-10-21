#!/data/data/com.termux/files/usr/bin/bash
# ПЕЧАТЬ ДОМА HERMES (ритм dom-backup.sh) — запечатанный сейф на телефон.
# Рука тянет архив напрямую с сервера своим SSH-ключом; в эхо — только размер и sha256.
echo "== 0116: печать дома Hermes =="
D="$HOME/hermes-печать"; mkdir -p "$D"
F="$D/hermes-home-$(date +%Y-%m-%d).tar.gz"
ssh -o BatchMode=yes -o ConnectTimeout=25 root@45.152.198.192 \
  'tar -czf - -C /root/.hermes/workspace --exclude=".git" .' > "$F" 2>$HOME/.ssh-err
if [ ! -s "$F" ]; then echo "SSH/архив не пришёл:"; head -3 $HOME/.ssh-err 2>/dev/null; rm -f "$F"; exit 1; fi
SZ=$(wc -c < "$F")
[ "$SZ" -gt 5000 ] || { echo "архив подозрительно мал: $SZ — не принимаю"; rm -f "$F"; exit 1; }
tar -tzf "$F" >/dev/null 2>&1 || { echo "архив битый — не принимаю"; rm -f "$F"; exit 1; }
echo "внутри: полный workspace Hermes (память, дневники, тетради, моя копия карты души). Содержимое не выводится."
SHA=$(sha256sum "$F" | cut -c1-16)
echo "печать дома Hermes принята: $(basename "$F"), $SZ байт, sha256:$SHA"
echo "== 0116: конец =="
