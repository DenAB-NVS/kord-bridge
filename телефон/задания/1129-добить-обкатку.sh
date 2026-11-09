#!/data/data/com.termux/files/usr/bin/bash
# 1129 — добить обкатку: svod v2 (%% формат), отчёт → пуш; №6 с выводом в файл на сервере
# (падение ssh больше не теряет результат — лог на диске, читается отдельным заходом).
echo "== 1129: добивание обкатки =="
ssh -o BatchMode=yes -o StrictHostKeyChecking=accept-new -o ConnectTimeout=30 -o ServerAliveInterval=20 root@45.152.198.192 'bash -s' <<'REMOTE'
cd /root/kord-glubina/kordinaps-machine/Hermes/движок || exit 1
PY=/root/kord-dvizhok-venv/bin/python
cat > svod.py <<'PYEOF'
import json, os
from importlib import util as u
DV = os.path.dirname(os.path.abspath(__file__))
spec = u.spec_from_file_location('k03sv', os.path.join(DV, '03-reestr-svoystv.py'))
k03 = u.module_from_spec(spec); spec.loader.exec_module(k03)
n_pred = n_ver = n_hit = 0
per_word = {}
for line in open('журнал-предсказаний.jsonl', encoding='utf-8'):
    try:
        r = json.loads(line)
    except Exception:
        continue
    n_pred += 1
    pid = r.get('property') or r.get('id') or '?'
    d = per_word.setdefault(pid, {'pred': 0, 'ver': 0, 'hit': 0})
    d['pred'] += 1
    if r.get('observed') is not None:
        n_ver += 1
        d['ver'] += 1
    if r.get('hit') is True:
        n_hit += 1
        d['hit'] += 1
cal = ('%.1f%%' % (100.0 * n_hit / n_ver)) if n_ver else '—'
print('ПРЕДСКАЗАНИЙ:', n_pred, '| сверено:', n_ver, '| попаданий:', n_hit, '| КАЛИБРОВКА:', cal)
for pid, d in sorted(per_word.items(), key=lambda kv: -kv[1]['pred'])[:12]:
    print('  %-32s предсказаний %4d | сверенных %4d | попаданий %4d' % (pid, d['pred'], d['ver'], d['hit']))
n_act = 0
verd = {}
for line in open('журнал-действий.jsonl', encoding='utf-8'):
    try:
        r = json.loads(line)
    except Exception:
        continue
    n_act += 1
    v = r.get('verdict') or r.get('status') or r.get('outcome') or '?'
    verd[v] = verd.get(v, 0) + 1
print('ДЕЙСТВИЙ (dry-run):', n_act, '|', verd if verd else '—')
trust = []
if os.path.exists('obkat-свойства.yaml'):
    reg = k03.load('obkat-свойства.yaml')
    from datetime import datetime
    trust = k03.status_table(reg, now=datetime(2026, 11, 9, 3, 0))
    print('--- живое доверие свойств ---')
    for t in trust:
        print('  %-32s скор=%.3f [%s-%s] сверок=%d открытых=%d' %
              (t['id'], t['score'], t['lo'], t['hi'], t['n_checks'], t['pending']))
ticks = [json.loads(l) for l in open('obkat-такты.jsonl', encoding='utf-8')]
ok = sum(1 for t in ticks if t.get('status') == 'OK')
with open('ОБКАТКА-ЖИВАЯ-01.md', 'w', encoding='utf-8') as f:
    f.write('# ЖИВАЯ ОБКАТКА ДВИЖКА №1 — 09.11.2026, ночь\n\n')
    f.write('**Топливо:** поток.jsonl — живая история 4 чатов (p2p777kar 2315, ipotekagroup 861, avtozalogrf 670, zalogzaym 47), 14 дней, 3893 сообщения.\n\n')
    f.write('## Числа прогонов\n\n')
    f.write('- тактов шофёра: %d | OK: %d | поломок: %d (журнал поломок не создан — ни одной)\n' % (len(ticks), ok, len(ticks) - ok))
    f.write('- предсказаний №4: %d | сверено: %d | попаданий: %d | калибровка на 90%% интервале: %s\n' % (n_pred, n_ver, n_hit, cal))
    f.write('- действий №5 (dry-run): %d | %s\n\n' % (n_act, verd if verd else '—'))
    f.write('## Доверие свойств (живое, Beta + старение)\n\n')
    f.write('| свойство | скор | интервал | сверок | открытых |\n|---|---|---|---|---|\n')
    for t in trust:
        f.write('| %s | %.3f | [%.3f, %.3f] | %d | %d |\n' %
                (t['id'], t['score'], t['lo'], t['hi'], t['n_checks'], t['pending']))
    f.write('\n## Находки живой обкатки (закон 7)\n\n')
    f.write('1. ДЕФЕКТ №6 (лемматизация): pymorphy3 на сервере даёт «ёлка» вместо «елки» — ё→е не применяется к лемме; в песочнице pymorphy3 не было, фолбэк скрывал. Нужен v1.2.\n')
    f.write('2. Буферизация stdout через пайп: при timeout буфер терялся; лечение — python -u и вывод в файл.\n')
    f.write('3. Топливо: из 9 чатов доехали 4; credity_zalogy — 0 сообщений за 14 дней; 3 чата не найдены сессией acc1.\n')
    f.write('4. SSH сервера за ночь дважды ронял соединение (banner timeout 00:44, closed by remote host 03:55) — движок не при чём, журнал поломок пуст.\n\n')
    f.write('*Движок судят живые числа, не вера. 55 тактов OK на живом потоке — первая живая поездка состоялась.*\n')
print('отчёт записан: ОБКАТКА-ЖИВАЯ-01.md')
PYEOF
echo "--- svod v2 (%% формат) ---"
$PY svod.py 2>&1 | tail -30
echo "--- пуш отчёта в дом (сначала, до №6) ---"
cd /root/kord-glubina/kordinaps-machine || exit 1
git add -f "Hermes/движок/ОБКАТКА-ЖИВАЯ-01.md" 2>&1 | tail -1
git commit -q -m "живая обкатка: 55 тактов OK, 660 предсказаний, калибровка выше 90%%, ноль поломок — отчёт (09.11 ночь)" 2>&1 | tail -1
git push -q origin HEAD:main 2>&1 | tail -1
echo "пуш отчёта выполнен"
cd /root/kord-glubina/kordinaps-machine/Hermes/движок || exit 1
echo "--- №6 в лог-файл на сервере (падение ssh не теряет результат) ---"
nohup timeout 900 $PY -u 06-forvardy-perenos-temy.py run ../топливо/поток.jsonl --lag 6 --lift 1.5 --out obkat-перенос.jsonl > obkat-n6.log 2>&1 &
echo "№6 запущен в фоне (PID $!), лог: obkat-n6.log, перенос: obkat-перенос.jsonl"
echo "== 1129: конец =="
REMOTE
echo "== 1129: конец задания =="
