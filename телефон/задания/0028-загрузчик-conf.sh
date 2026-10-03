#!/data/data/com.termux/files/usr/bin/bash
# Только AST-форма вызова load и модуль импорта; без значений литералов.
echo '=== 0028 ЗАГРУЗЧИК CONF ==='
ssh -o BatchMode=yes -o StrictHostKeyChecking=accept-new -o ConnectTimeout=15 root@45.152.198.192 'python3 -' <<'PY'
import ast
from pathlib import Path
t = ast.parse(Path('/root/рассылка/otpravka.py').read_text(errors='replace'))
def shape(n):
    if isinstance(n, ast.Name): return 'NAME_' + n.id[:40]
    if isinstance(n, ast.Attribute): return shape(n.value) + '.ATTR_' + n.attr[:40]
    if isinstance(n, ast.Call): return 'CALL(' + shape(n.func) + ',ARGS_' + str(len(n.args)) + ')'
    if isinstance(n, ast.Constant): return 'LITERAL_' + type(n.value).__name__
    return type(n).__name__
for n in ast.walk(t):
    if isinstance(n, ast.ImportFrom) and any(a.name == 'load' for a in n.names):
        print('LOAD_IMPORT_FROM', n.module)
    if isinstance(n, ast.Import) and any(a.name in {'json', 'yaml'} for a in n.names):
        print('MODULE_IMPORT', ' '.join(a.name for a in n.names if a.name in {'json', 'yaml'}))
    if isinstance(n, ast.Assign) and any(isinstance(x, ast.Name) and x.id == 'conf' for x in n.targets):
        if isinstance(n.value, ast.Call):
            print('LOAD_ARG_COUNT', len(n.value.args))
            for i, a in enumerate(n.value.args[:2]): print('LOAD_ARG_' + str(i), shape(a))
            if n.value.args and isinstance(n.value.args[0], ast.Call):
                for i, a in enumerate(n.value.args[0].args[:2]): print('NESTED_ARG_' + str(i), shape(a))
PY
echo '=== КОНЕЦ 0028 ==='
