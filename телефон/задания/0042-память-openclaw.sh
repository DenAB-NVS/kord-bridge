#!/data/data/com.termux/files/usr/bin/bash
# 0042: ПАМЯТЬ OPENCLAW — включить Dreaming, поставить службу гейтвея, прогнать doctor.
# Ночь памяти, фаза 1.5. Конфиг правим слиянием JSON через python3 (ничего не затираем).
# Секретов нет; API-ключ — потом, руками Дениса (openclaw onboard).

echo "--- 0042: ПАМЯТЬ OPENCLAW, $(date) ---"
ssh -o BatchMode=yes -o StrictHostKeyChecking=accept-new -o ConnectTimeout=15 root@45.152.198.192 '
echo "=== 1. КОНФИГ: ВКЛЮЧИТЬ DREAMING ==="
python3 - <<"PYEOF"
import json, os
p = os.path.expanduser("~/.openclaw/openclaw.json")
cfg = {}
if os.path.exists(p):
    with open(p) as f:
        try:
            cfg = json.load(f)
        except Exception:
            cfg = {}
plugins = cfg.setdefault("plugins", {})
entries = plugins.setdefault("entries", {})
memcore = entries.setdefault("memory-core", {})
mconf = memcore.setdefault("config", {})
dream = mconf.setdefault("dreaming", {})
dream["enabled"] = True
dream["frequency"] = "0 */6 * * *"
os.makedirs(os.path.dirname(p), exist_ok=True)
with open(p, "w") as f:
    json.dump(cfg, f, indent=2, ensure_ascii=False)
print("Dreaming включён ->", p)
PYEOF
echo "=== 2. СЛУЖБА ГЕЙТВЕЯ ==="
export XDG_RUNTIME_DIR=/run/user/0
loginctl enable-linger root 2>/dev/null || true
openclaw gateway install 2>&1 | tail -15 || echo "gateway install не прошёл — смотрим вывод"
echo "=== 3. ДОКТОР ==="
openclaw doctor 2>&1 | tail -25 || true
echo "=== 4. КОНФИГ ЦЕЛИКОМ ==="
cat ~/.openclaw/openclaw.json 2>/dev/null || echo "конфиг не найден"
echo "=== КОНЕЦ 0042 ==="
' 2>&1
echo "--- КОНЕЦ 0042 ---"
