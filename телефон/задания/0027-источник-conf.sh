#!/data/data/com.termux/files/usr/bin/bash
# Имена идентификаторов AST без литералов и содержимого конфигурации.
echo '=== 0027 ИСТОЧНИК CONF ==='
ssh -o BatchMode=yes -o StrictHostKeyChecking=accept-new -o ConnectTimeout=15 root@45.152.198.192 'python3 -' <<'PY'
import ast
from pathlib import Path
t = ast.parse(Path('/root/рассылка/otpravka.py').read_text(errors='replace'))
def shape(n):
    if isinstance(n, ast.Name): return 'NAME_' + n.id[:40]
    if isinstance(n, ast.Attribute): return shape(n.value) + '.ATTR_' + n.attr[:40]
    if isinstance(n, ast.Call): return 'CALL(' + shape(n.func) + ')'
    if isinstance(n, ast.Subscript): return 'SUB(' + shape(n.value) + ',REDACTED)'
    if isinstance(n, ast.Dict): return 'DICT_' + str(len(n.keys))
    return type(n).__name__
for n in ast.walk(t):
    if isinstance(n, (ast.Assign, ast.AnnAssign)):
        targets = n.targets if isinstance(n, ast.Assign) else [n.target]
        if any(isinstance(x, ast.Name) and x.id == 'conf' for x in targets):
            print('CONF_ASSIGN', shape(n.value))
    if isinstance(n, (ast.For, ast.AsyncFor)):
        names = {x.id for x in ast.walk(n.target) if isinstance(x, ast.Name)}
        if 'conf' in names:
            print('CONF_LOOP', ' '.join(sorted(names)), shape(n.iter))
    if isinstance(n, ast.Assign) and isinstance(n.value, ast.Dict):
        names = [x.id for x in n.targets if isinstance(x, ast.Name)]
        if names:
            nested = any(isinstance(x, ast.Dict) for x in n.value.values)
            if nested: print('NESTED_DICT', ' '.join(names), 'entries', len(n.value.keys))
PY
echo '=== КОНЕЦ 0027 ==='
