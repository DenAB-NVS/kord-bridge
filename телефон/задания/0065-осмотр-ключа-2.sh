#!/data/data/com.termux/files/usr/bin/bash
# 0065: осмотр текущего ключа zai без печати значения — длина и целость структуры.

ssh -o BatchMode=yes -o ConnectTimeout=15 root@45.152.198.192 '
python3 -c "import json,re; k=json.load(open(\"/root/.openclaw/openclaw.json\"))[\"models\"][\"providers\"][\"zai\"][\"apiKey\"].strip(); print(\"длина ключа:\", len(k)); print(\"структура целая (буквы/цифры/точка/дефис):\", \"да\" if re.fullmatch(r\"[A-Za-z0-9._-]+\", k) else \"НЕТ — вставка повреждена"); print(\"точка внутри:\", \"да\" if \".\" in k else \"нет\")"
'
