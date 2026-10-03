#!/data/data/com.termux/files/usr/bin/bash
# Не исполнять otpravka.py; только безопасная AST-карта.
echo '=== 0029 КАРТА LOAD CONF ==='
ssh -o BatchMode=yes -o StrictHostKeyChecking=accept-new -o ConnectTimeout=15 root@45.152.198.192 'python3 -' <<'PY'
import ast
from pathlib import Path
t = ast.parse(Path('/root/рассылка/otpravka.py').read_text(errors='replace'))
def shape(n):
    if isinstance(n, ast.Name): return 'NAME_' + n.id[:40]
    if isinstance(n, ast.Attribute): return shape(n.value) + '.ATTR_' + n.attr[:40]
    if isinstance(n, ast.Call): return 'CALL_' + shape(n.func)
    if isinstance(n, ast.Constant): return 'LITERAL_' + type(n.value).__name__
    if isinstance(n, ast.Dict): return 'DICT_' + str(len(n.keys))
    return type(n).__name__
for n in t.body:
    if isinstance(n, (ast.FunctionDef, ast.AsyncFunctionDef)) and n.name == 'load':
        print('LOAD_FUNCTION', 'async' if isinstance(n, ast.AsyncFunctionDef) else 'sync')
        print('LOAD_ARGS', ' '.join(a.arg[:40] for a in n.args.args))
        print('LOAD_STATEMENTS', ' '.join(type(x).__name__ for x in n.body[:12]))
        for x in ast.walk(n):
            if isinstance(x, ast.Return): print('LOAD_RETURN', shape(x.value))
            if isinstance(x, ast.Call): print('LOAD_CALL', shape(x.func))
    if isinstance(n, ast.ImportFrom):
        for a in n.names:
            if a.name == 'load' or a.asname == 'load': print('LOAD_FROM', n.module)
    if isinstance(n, ast.Assign) and any(isinstance(x, ast.Name) and x.id == 'CONF' for x in n.targets):
        print('CONF_SOURCE', shape(n.value))
PY
echo '=== КОНЕЦ 0029 ==='
