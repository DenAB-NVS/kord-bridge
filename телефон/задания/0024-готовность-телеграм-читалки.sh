#!/data/data/com.termux/files/usr/bin/bash
# Только логические признаки; никаких токенов, содержимого файлов и сообщений.
echo '=== 0024 ГОТОВНОСТЬ ЧИТАЛКИ ==='
ssh -o BatchMode=yes -o StrictHostKeyChecking=accept-new -o ConnectTimeout=15 root@45.152.198.192 'python3 -' <<'PY'
from pathlib import Path
import importlib.util
b = Path('/root/рассылка')
p = b / 'otpravka.py'
s = p.read_text(errors='replace') if p.is_file() else ''
print('TELETHON_AVAILABLE', bool(importlib.util.find_spec('telethon')))
print('OTPRAVKA_EXISTS', p.is_file())
for key in ('TelegramClient', 'api_id', 'api_hash', 'acc1', 'acc2'):
    print('OTPRAVKA_MENTIONS_' + key.upper(), key in s)
print('DOTENV_EXISTS', (b / '.env').is_file())
print('CONFIG_PY_EXISTS', (b / 'config.py').is_file())
PY
echo '=== КОНЕЦ 0024 ==='
