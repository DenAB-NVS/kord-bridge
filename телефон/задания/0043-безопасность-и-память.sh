#!/data/data/com.termux/files/usr/bin/bash
# 0043: БЕЗОПАСНОСТЬ + СИСТЕМА ПАМЯТИ.
# а) Ротация gateway-токена: старый попал в эхо 18:56 по моей ошибке (конфиг печатался целиком после автогенерации токена гейтвеем). Старый токен сгорает, новый НЕ выводится.
# б) Установка системы памяти в workspace по рецепту openclaw doctor (два официальных патча).
# в) Статус гейтвея.

echo "--- 0043: БЕЗОПАСНОСТЬ И ПАМЯТЬ, $(date) ---"
ssh -o BatchMode=yes -o StrictHostKeyChecking=accept-new -o ConnectTimeout=15 root@45.152.198.192 '
echo "=== 1. РОТАЦИЯ ТОКЕНА ГЕЙТВЕЯ ==="
python3 - <<"PYEOF"
import json, os, secrets
p = os.path.expanduser("~/.openclaw/openclaw.json")
with open(p) as f:
    cfg = json.load(f)
gw = cfg.setdefault("gateway", {})
auth = gw.setdefault("auth", {})
auth["token"] = secrets.token_hex(24)
with open(p, "w") as f:
    json.dump(cfg, f, indent=2, ensure_ascii=False)
print("Токен ротирован, значение НЕ выводится")
PYEOF
echo "=== 2. СИСТЕМА ПАМЯТИ В WORKSPACE ==="
mkdir -p ~/.openclaw/workspace
cd ~/.openclaw/workspace || exit 1
for sha in 9ffea23f31ca1df5183b25668f8f814bee0fb34e 7d1fee70e76f2f634f1b41fca927ee663914183a; do
  if curl -fsSL "https://github.com/openclaw/openclaw/commit/$sha.patch" -o /tmp/mem-$sha.patch 2>/dev/null; then
    if git apply --check /tmp/mem-$sha.patch 2>/dev/null; then
      git apply /tmp/mem-$sha.patch && echo "ПРИМЕНЁН $sha"
    else
      echo "НЕ ПРИМЕНИЛСЯ $sha — начало патча:"
      head -25 /tmp/mem-$sha.patch
    fi
  else
    echo "НЕ СКАЧАЛСЯ $sha"
  fi
done
echo "=== СОДЕРЖИМОЕ WORKSPACE ==="
ls -la ~/.openclaw/workspace | head -20
echo "=== 3. СТАТУС ГЕЙТВЕЯ ==="
openclaw gateway status 2>&1 | tail -10 || true
echo "=== КОНЕЦ 0043 ==="
' 2>&1
echo "--- КОНЕЦ 0043 ---"
