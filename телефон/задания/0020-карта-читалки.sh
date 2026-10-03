#!/data/data/com.termux/files/usr/bin/bash
# Read-only: структура старой читалки; не запускать Telegram-клиент, не читать каналы и не выводить конфиги/сессии.
echo '=== 0020 КАРТА ЧИТАЛКИ ==='
python3 - <<'PY'
import ast, hashlib
from pathlib import Path
base=Path.home()/'рассылка'
f=base/'chitka-kanala.py'
print('READ_DIR_EXISTS',base.is_dir())
print('CHITALKA_EXISTS',f.is_file())
if f.is_file():
    raw=f.read_bytes()
    print('CHITALKA_BYTES',len(raw))
    print('CHITALKA_SHA256',hashlib.sha256(raw).hexdigest())
    try:
        tree=ast.parse(raw.decode('utf-8'))
        calls=[n.func.attr for n in ast.walk(tree) if isinstance(n,ast.Call) and isinstance(n.func,ast.Attribute)]
        for name in ('iter_messages','get_messages','get_dialogs','send_message','start','connect'):
            print('USES_'+name.upper(),name in calls)
        print('SYNTAX_OK',True)
    except Exception:
        print('SYNTAX_OK',False)
for rel in ('sessions/acc1.session','sessions/acc2.session','канала-дамп.txt'):
    print('EXISTS_'+rel.replace('/','_').replace('.','_'),(base/rel).exists())
PY
echo '=== КОНЕЦ 0020 ==='
