#!/data/data/com.termux/files/usr/bin/bash
# 0063: осмотр ключа zai без печати значения — длина, целость, лишние символы.

ssh -o BatchMode=yes -o ConnectTimeout=15 root@45.152.198.192 '
python3 -c "import json,re; k=json.load(open(\"/root/.openclaw/openclaw.json\"))[\"models\"][\"providers\"][\"zai\"][\"apiKey\"].strip(); print(\"длина ключа:\", len(k)); print(\"лишние символы:\", \"да\" if not re.fullmatch(r\"[A-Za-z0-9._-]+\", k) else \"нет\"); print(\"пробелы внутри:\", \"да\" if any(c.isspace() for c in k) else \"нет\")"
'
