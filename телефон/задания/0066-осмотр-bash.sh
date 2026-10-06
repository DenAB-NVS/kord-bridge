#!/data/data/com.termux/files/usr/bin/bash
# 0066: осмотр ключа zai чистым bash (без питона — прошлый споткнулся о кавычки):
# длина, структура, живой тест. Значение ключа не печатается.

ssh -o BatchMode=yes -o ConnectTimeout=20 root@45.152.198.192 '
K=$(sed -n "s/.*\"apiKey\"[[:space:]]*:[[:space:]]*\"([^\"]*)\".*/\\1/p" /root/.openclaw/openclaw.json | head -1)
if [ -z "$K" ]; then echo "ключ не найден в конфиге"; exit 1; fi
echo "длина ключа: ${#K}"
echo "$K" | grep -qE "^[A-Za-z0-9._-]+$" && echo "структура: целая" || echo "структура: ПОВРЕЖДЕНА (лишние символы)"
CODE=$(curl -s -m 20 -o /tmp/z.json -w "%{http_code}" -H "Authorization: Bearer $K" -H "Content-Type: application/json" -d "{\"model\":\"glm-5.3\",\"messages\":[{\"role\":\"user\",\"content\":\"hi\"}],\"max_tokens\":4}" "https://api.z.ai/api/paas/v4/chat/completions")
echo "тест paas/v4: $CODE"
head -c 200 /tmp/z.json; echo
rm -f /tmp/z.json
'
