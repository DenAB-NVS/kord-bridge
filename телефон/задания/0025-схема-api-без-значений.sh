#!/data/data/com.termux/files/usr/bin/bash
# Только имена известных переменных и типы AST, без значений и сообщений.
echo '=== 0025 СХЕМА API БЕЗ ЗНАЧЕНИЙ ==='
ssh -o BatchMode=yes -o StrictHostKeyChecking=accept-new -o ConnectTimeout=15 root@45.152.198.192 'python3 -' <<'PY'
import ast
from pathlib import Path
p = Path('/root/рассылка/otpravka.py')
if not p.is_file():
    print('SOURCE_MISSING')
else:
    t = ast.parse(p.read_text(errors='replace'))
    targets = {'api_id', 'api_hash', 'API_ID', 'API_HASH'}
    for node in ast.walk(t):
        if isinstance(node, ast.Assign):
            names = [x.id for x in node.targets if isinstance(x, ast.Name)]
            for name in names:
                if name in targets:
                    kind = type(node.value).__name__
                    subtype = type(node.value.value).__name__ if isinstance(node.value, ast.Constant) else '-'
                    print(name + '_SHAPE', kind, subtype)
        elif isinstance(node, ast.AnnAssign) and isinstance(node.target, ast.Name) and node.target.id in targets:
            print(node.target.id + '_SHAPE', type(node.value).__name__ if node.value else 'None')
PY
echo '=== КОНЕЦ 0025 ==='
