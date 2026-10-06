#!/data/data/com.termux/files/usr/bin/bash
# 0060: финал телеграмного окна — разрешить группу «Кординапс HQ» (-1003860737774)
# в конфиге OpenClaw и перезапустить гейтвей. Топики = отдельные сессии (по умолчанию).
# requireMention: false — бот отвечает на обычные сообщения в топиках.

ssh -o BatchMode=yes -o ConnectTimeout=15 root@45.152.198.192 '
cp /root/.openclaw/openclaw.json /root/.openclaw/openclaw.json.bak-$(date +%F_%H-%M) 2>/dev/null
python3 -c "import json; p=\"/root/.openclaw/openclaw.json\"; cfg=json.load(open(p)); ch=cfg.setdefault(\"channels\",{}).setdefault(\"telegram\",{}); ch[\"groups\"]={\"-1003860737774\": {\"groupPolicy\": \"open\", \"requireMention\": False}}; json.dump(cfg,open(p,\"w\"),indent=2,ensure_ascii=False); print(\"группа разрешена\")"
openclaw gateway restart
'
