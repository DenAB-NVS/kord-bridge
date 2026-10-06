#!/data/data/com.termux/files/usr/bin/bash
# 0070: тестовый ключ zai — из приватного дома в конфиг OpenClaw, живой тест, рестарт.
# Значение ключа не печатается никогда. Бэкап конфига делается перед правкой.

ssh -o BatchMode=yes -o ConnectTimeout=20 root@45.152.198.192 '
TOKEN=$(gh auth token --user DenAB-NVS 2>/dev/null || gh auth token)
rm -rf /tmp/dom-stage
git clone --depth 1 --quiet "https://x-access-token:${TOKEN}@github.com/DenAB-NVS/kordinaps-machine.git" /tmp/dom-stage 2>/dev/null
if [ -f /tmp/dom-stage/projects/zai-test-key.tmp ]; then
  K=$(tr -d "[:space:]" < /tmp/dom-stage/projects/zai-test-key.tmp)
  rm -rf /tmp/dom-stage
  cp /root/.openclaw/openclaw.json /root/.openclaw/openclaw.json.bak-$(date +%F_%H-%M) 2>/dev/null
  K="$K" python3 -c "import json,os; p=\"/root/.openclaw/openclaw.json\"; cfg=json.load(open(p)); cfg[\"models\"][\"providers\"][\"zai\"][\"apiKey\"]=os.environ[\"K\"].strip(); cfg[\"models\"][\"providers\"][\"zai\"][\"baseUrl\"]=\"https://api.z.ai/api/paas/v4\"; json.dump(cfg,open(p,\"w\"),indent=2,ensure_ascii=False); print(\"ключ уложен, длина:\", len(os.environ[\"K\"]))"
  echo "--- живой тест:"
  CODE=$(curl -s -m 20 -o /tmp/z.json -w "%{http_code}" -H "Authorization: Bearer $K" -H "Content-Type: application/json" -d "{\"model\":\"glm-5.3\",\"messages\":[{\"role\":\"user\",\"content\":\"привет\"}],\"max_tokens\":8}" "https://api.z.ai/api/paas/v4/chat/completions")
  echo "код ответа: $CODE"
  head -c 200 /tmp/z.json; echo
  rm -f /tmp/z.json
  openclaw gateway restart
else
  echo "ОШИБКА: ключ не найден в доме"
  rm -rf /tmp/dom-stage
fi
'
