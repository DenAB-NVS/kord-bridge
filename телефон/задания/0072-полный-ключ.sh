#!/data/data/com.termux/files/usr/bin/bash
# 0072: полный ключ zai (обе половины, id.секрет) — из приватного дома в конфиг.
# Тест обеих дверей, авто-переключение на открывшуюся, рестарт. Значение не печатается.

ssh -o BatchMode=yes -o ConnectTimeout=20 root@45.152.198.192 '
TOKEN=$(gh auth token --user DenAB-NVS 2>/dev/null || gh auth token)
rm -rf /tmp/dom-stage
git clone --depth 1 --quiet "https://x-access-token:${TOKEN}@github.com/DenAB-NVS/kordinaps-machine.git" /tmp/dom-stage 2>/dev/null
if [ -f /tmp/dom-stage/projects/zai-test-key.tmp ]; then
  K=$(tr -d "[:space:]" < /tmp/dom-stage/projects/zai-test-key.tmp)
  rm -rf /tmp/dom-stage
  echo "длина ключа: ${#K}"
  cp /root/.openclaw/openclaw.json /root/.openclaw/openclaw.json.bak-$(date +%F_%H-%M) 2>/dev/null
  K="$K" python3 -c "import json,os; p=\"/root/.openclaw/openclaw.json\"; cfg=json.load(open(p)); cfg[\"models\"][\"providers\"][\"zai\"][\"apiKey\"]=os.environ[\"K\"].strip(); json.dump(cfg,open(p,\"w\"),indent=2,ensure_ascii=False); print(\"ключ уложен\")"
  FOUND=""
  for BASE in "https://api.z.ai/api/paas/v4" "https://api.z.ai/api/coding/paas/v4"; do
    CODE=$(curl -s -m 20 -o /tmp/z.json -w "%{http_code}" -H "Authorization: Bearer $K" -H "Content-Type: application/json" -d "{\"model\":\"glm-5.3\",\"messages\":[{\"role\":\"user\",\"content\":\"привет\"}],\"max_tokens\":8}" "$BASE/chat/completions")
    echo "$BASE -> $CODE"
    head -c 200 /tmp/z.json; echo
    if [ "$CODE" = "200" ]; then FOUND="$BASE"; break; fi
  done
  rm -f /tmp/z.json
  if [ -n "$FOUND" ]; then
    if [ "$FOUND" = "https://api.z.ai/api/paas/v4" ]; then
      python3 -c "import json; p=\"/root/.openclaw/openclaw.json\"; cfg=json.load(open(p)); cfg[\"models\"][\"providers\"][\"zai\"][\"baseUrl\"]=\"https://api.z.ai/api/paas/v4\"; json.dump(cfg,open(p,\"w\"),indent=2,ensure_ascii=False); print(\"дверь: обычная\")"
    else
      python3 -c "import json; p=\"/root/.openclaw/openclaw.json\"; cfg=json.load(open(p)); cfg[\"models\"][\"providers\"][\"zai\"][\"baseUrl\"]=\"https://api.z.ai/api/coding/paas/v4\"; json.dump(cfg,open(p,\"w\"),indent=2,ensure_ascii=False); print(\"дверь: coding\")"
    fi
    openclaw gateway restart
  else
    echo "обе двери закрыты"
  fi
else
  echo "ключ не найден в доме"
  rm -rf /tmp/dom-stage
fi
'
