#!/data/data/com.termux/files/usr/bin/bash
# 0071: тест чистого ключа на coding-двери (paas/v4 уже отвергла). При 200 — переключение baseUrl и рестарт.
# Значение ключа не печатается.

ssh -o BatchMode=yes -o ConnectTimeout=20 root@45.152.198.192 '
K=$(python3 -c "import json;print(json.load(open(\"/root/.openclaw/openclaw.json\"))[\"models\"][\"providers\"][\"zai\"][\"apiKey\"].strip())" 2>/dev/null)
if [ -z "$K" ]; then echo "ключ не найден в конфиге"; exit 1; fi
echo "--- тест coding-двери:"
CODE=$(curl -s -m 20 -o /tmp/z.json -w "%{http_code}" -H "Authorization: Bearer $K" -H "Content-Type: application/json" -d "{\"model\":\"glm-5.3\",\"messages\":[{\"role\":\"user\",\"content\":\"привет\"}],\"max_tokens\":8}" "https://api.z.ai/api/coding/paas/v4/chat/completions")
echo "код ответа: $CODE"
head -c 200 /tmp/z.json; echo
rm -f /tmp/z.json
if [ "$CODE" = "200" ]; then
  python3 -c "import json; p=\"/root/.openclaw/openclaw.json\"; cfg=json.load(open(p)); cfg[\"models\"][\"providers\"][\"zai\"][\"baseUrl\"]=\"https://api.z.ai/api/coding/paas/v4\"; json.dump(cfg,open(p,\"w\"),indent=2,ensure_ascii=False); print(\"baseUrl переключён на coding-дверь\")"
  openclaw gateway restart
else
  echo "coding-дверь тоже закрыта — ключ мёртв на стороне z.ai"
fi
'
