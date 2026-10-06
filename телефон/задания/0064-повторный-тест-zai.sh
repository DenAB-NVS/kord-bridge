#!/data/data/com.termux/files/usr/bin/bash
# 0064: повторный тест ключа zai после переприклейки — оба входа, авто-переключение baseUrl при 200.
# Ключ не печатается никогда.

ssh -o BatchMode=yes -o ConnectTimeout=20 root@45.152.198.192 '
KEY=$(python3 -c "import json;print(json.load(open(\"/root/.openclaw/openclaw.json\"))[\"models\"][\"providers\"][\"zai\"][\"apiKey\"].strip())" 2>/dev/null)
if [ -z "$KEY" ]; then echo "ключ zai не найден в конфиге"; exit 1; fi
FOUND=""
for BASE in "https://api.z.ai/api/paas/v4" "https://api.z.ai/api/coding/paas/v4"; do
  CODE=$(curl -s -m 20 -o /tmp/zai-test.json -w "%{http_code}" -H "Authorization: Bearer $KEY" -H "Content-Type: application/json" -d "{\"model\":\"glm-5.3\",\"messages\":[{\"role\":\"user\",\"content\":\"привет\"}],\"max_tokens\":8}" "$BASE/chat/completions")
  echo "$BASE -> $CODE"
  head -c 200 /tmp/zai-test.json; echo
  if [ "$CODE" = "200" ]; then
    FOUND="$BASE"
    break
  fi
done
rm -f /tmp/zai-test.json
if [ -n "$FOUND" ]; then
  python3 -c "import json; p=\"/root/.openclaw/openclaw.json\"; cfg=json.load(open(p)); cur=cfg[\"models\"][\"providers\"][\"zai\"].get(\"baseUrl\"); print(\"текущий baseUrl:\", cur)"
  python3 -c "import json; p=\"/root/.openclaw/openclaw.json\"; cfg=json.load(open(p)); cfg[\"models\"][\"providers\"][\"zai\"][\"baseUrl\"]='"$FOUND"'; json.dump(cfg,open(p,\"w\"),indent=2,ensure_ascii=False); print(\"baseUrl подтверждён:\", '"$FOUND"'")"
  openclaw gateway restart
else
  echo "ключ всё ещё не принят — нужно переприклеить заново"
fi
'
