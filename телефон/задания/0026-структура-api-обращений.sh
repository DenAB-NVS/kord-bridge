#!/data/data/com.termux/files/usr/bin/bash
# AST-структура только api_id/api_hash; литералы никогда не выводятся.
echo '=== 0026 СТРУКТУРА API ==='
ssh -o BatchMode=yes -o StrictHostKeyChecking=accept-new -o ConnectTimeout=15 root@45.152.198.192 'python3 -' <<'PY'
import ast
from pathlib import Path
t = ast.parse(Path('/root/рассылка/otpravka.py').read_text(errors='replace'))
def shape(n):
    if isinstance(n, ast.Name): return 'NAME_' + n.id[:40]
    if isinstance(n, ast.Subscript): return 'SUB(' + shape(n.value) + ',' + shape(n.slice) + ')'
    if isinstance(n, ast.Constant):
        if isinstance(n.value, str) and n.value in {'api_id', 'api_hash', 'acc1', 'acc2'}: return 'KEY_' + n.value
        return 'LITERAL_REDACTED'
    if isinstance(n, ast.Attribute): return 'ATTR(' + shape(n.value) + ',NAME_' + n.attr[:40] + ')'
    return type(n).__name__
for n in ast.walk(t):
    if isinstance(n, ast.Assign):
        for target in n.targets:
            if isinstance(target, ast.Name) and target.id in {'api_id', 'api_hash'}:
                print(target.id.upper() + '_SOURCE', shape(n.value))
PY
echo '=== КОНЕЦ 0026 ==='
