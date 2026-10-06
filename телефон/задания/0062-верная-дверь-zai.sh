#!/data/data/com.termux/files/usr/bin/bash
# 0062: ключ zai стучится не в ту дверь (401). Проверить оба входа, переключить baseUrl на рабочий.
# Ключ не печатается никогда. Бэкап конфига делается перед правкой.

ssh -o BatchMode=yes -o ConnectTimeout=20 root@45.152.198.192 '
KEY=$(python3 -c "import json;print(json.load(open(\"/root/.openclaw/openclaw.json\"))[\"models\"][\"providers\"][\"zai\"][\"apiKey\"] )" 2>/dev/null)
if [ -z "$KEY" ]; then echo "ключ zai не найден в конфиге"; exit 1; fi
cp /root/.openclaw/openclaw.json /root/.openclaw/openclaw.json.bak-$(date +%F_%H-%M) 2>/dev/null
FOUND=""
for BASE in "https://api.z.ai/api/coding/paas/v4" "https://api.z.ai/api/paas/v4"; do
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
  python3 -c "import json; p=\"/root/.openclaw/openclaw.json\"; cfg=json.load(open(p)); cfg[\"models\"][\"providers\"][\"zai\"][\"baseUrl\"]='"$FOUND"'; json.dump(cfg,open(p,\"w\"),indent=2,ensure_ascii=False); print(\"baseUrl переключён на $FOUND\")"
  openclaw gateway restart
else
  echo "оба входа ответили ошибкой — ключ, возможно, скопирован с опечаткой или истёк"
fi
'
