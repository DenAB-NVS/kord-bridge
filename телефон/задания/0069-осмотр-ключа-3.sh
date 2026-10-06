#!/data/data/com.termux/files/usr/bin/bash
# 0069: осмотр ключа zai (повтор 0067 — его вывод съела канарейка в том же такте).
# Временный скрипт на сервере, без вложенных кавычек. Значение ключа не печатается.

ssh -o BatchMode=yes -o ConnectTimeout=20 root@45.152.198.192 'cat > /tmp/insp.sh <<"EOS"
#!/bin/bash
K=$(python3 - <<PYEOF
import json
print(json.load(open("/root/.openclaw/openclaw.json"))["models"]["providers"]["zai"]["apiKey"].strip())
PYEOF
)
if [ -z "$K" ]; then echo "ключ не найден в конфиге"; exit 1; fi
echo "длина ключа: ${#K}"
echo "$K" | grep -qE "^[A-Za-z0-9._-]+$" && echo "структура: целая" || echo "структура: ПОВРЕЖДЕНА (лишние символы)"
CODE=$(curl -s -m 20 -o /tmp/z.json -w "%{http_code}" -H "Authorization: Bearer $K" -H "Content-Type: application/json" -d "{\"model\":\"glm-5.3\",\"messages\":[{\"role\":\"user\",\"content\":\"hi\"}],\"max_tokens\":4}" "https://api.z.ai/api/paas/v4/chat/completions")
echo "тест paas/v4: $CODE"
head -c 200 /tmp/z.json; echo
rm -f /tmp/z.json /tmp/insp.sh
EOS
bash /tmp/insp.sh'
