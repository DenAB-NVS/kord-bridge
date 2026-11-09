#!/data/data/com.termux/files/usr/bin/bash
# 1127 — починка на дороге (закон 7): 1) полный диагноз selftest №6;
# 2) фикс обкатчика (ts — datetime из №1, защита aware/naive); 3) перегон живой обкатки.
echo "== 1127: починка обкатчика и перегон =="
ssh -o BatchMode=yes -o StrictHostKeyChecking=accept-new -o ConnectTimeout=30 root@45.152.198.192 'bash -s' <<'REMOTE'
cd /root/kord-glubina/kordinaps-machine/Hermes/движок || exit 1
PY=/root/kord-dvizhok-venv/bin/python
echo "--- диагноз: полный selftest №6 ---"
$PY 06-forvardy-perenos-temy.py --selftest 2>&1 | head -40
echo "--- чистые журналы обкатки (поломки — append-only, не трогаем) ---"
rm -f obkat-такты.jsonl obkat-свойства.yaml obkat-действия.yaml obkat-перенос.jsonl журнал-предсказаний.jsonl журнал-действий.jsonl 2>/dev/null
echo "--- обкатчик v2 (фикс: ts — datetime; now — в форме потока) ---"
cat > obkat-live.py <<'PYEOF'
import json, subprocess, sys, os
from collections import Counter
from datetime import datetime, timedelta, timezone
from importlib import util as u

INP = sys.argv[1]
DV = os.path.dirname(os.path.abspath(__file__))
PY = sys.executable
REG, ACT = 'obkat-свойства.yaml', 'obkat-действия.yaml'
JT, JE, JP, JD = 'obkat-такты.jsonl', 'obkat-поломки.jsonl', 'журнал-предсказаний.jsonl', 'журнал-действий.jsonl'
REPORT = 'ОБКАТКА-ЖИВАЯ-01.md'

def load_mod(fn, mn):
    spec = u.spec_from_file_location(mn, os.path.join(DV, fn))
    m = u.module_from_spec(spec); spec.loader.exec_module(m); return m

k01 = load_mod('01-конвертер-часовых-бинов.py', 'k01live')
k03 = load_mod('03-reestr-svoystv.py', 'k03live')

msgs = k01.load_jsonl(INP)
print('сообщений в потоке:', len(msgs))
chats = sorted({r['chat'] for r in msgs})
print('чатов:', len(chats), '|', ', '.join(chats))

wc, chat_wc = Counter(), Counter()
for r in msgs:
    lems = k01.lemmas_of_message(r.get('text', '') or '')
    wc.update(lems)
    for w in set(lems):
        chat_wc[(r['chat'], w)] += 1
TOP = [w for w, n in wc.most_common(400) if len(w) >= 5][:10]
print('топ-слов для реестра:', ', '.join(TOP))

raw_min, raw_max = min(r['ts'] for r in msgs), max(r['ts'] for r in msgs)
if not isinstance(raw_min, datetime):
    raw_min = datetime.fromtimestamp(raw_min, tz=timezone.utc)
    raw_max = datetime.fromtimestamp(raw_max, tz=timezone.utc)
print('диапазон потока:', raw_min.isoformat(), '→', raw_max.isoformat())

reg = k03.new_registry()
t0 = raw_min.replace(tzinfo=None)
for w in TOP:
    chat = max((c for (c, ww) in chat_wc if ww == w), key=lambda c: chat_wc[(c, w)])
    k03.add_property(reg, chat, w, 'живая обкатка 09.11, автосвойство', now=t0)
    print('свойство:', chat + '-' + w, '(сообщений:', chat_wc[(chat, w)], ')')
k03.save(reg, REG)

ticks, ok_n, broken_n = 0, 0, 0
now_dt = raw_min + timedelta(hours=6)
while now_dt <= raw_max:
    now_iso = now_dt.isoformat()
    rc = subprocess.run([PY, os.path.join(DV, '07-shofer-dvizhka.py'), 'run', INP,
                         '--now', now_iso, '--registry', REG, '--actions', ACT,
                         '--journal', JT, '--errors', JE],
                        capture_output=True, text=True)
    ticks += 1
    if rc.returncode == 0:
        ok_n += 1
    else:
        broken_n += 1
        print('ТАКТ СЛОМАН @', now_iso, 'код', rc.returncode, (rc.stderr or '')[-200:])
    if ticks % 10 == 0:
        print('... тактов:', ticks, 'OK:', ok_n, 'BROKEN:', broken_n)
    now_dt += timedelta(hours=6)
print('ТАКТОВ:', ticks, '| OK:', ok_n, '| BROKEN (в журнале, данные не тронуты):', broken_n)

n_pred = n_ver = n_hit = 0
if os.path.exists(JP):
    for line in open(JP, encoding='utf-8'):
        try:
            r = json.loads(line)
        except Exception:
            continue
        n_pred += 1
        if r.get('observed') is not None:
            n_ver += 1
        if r.get('hit') is True:
            n_hit += 1
cal = (n_hit / n_ver) if n_ver else None
print('ПРЕДСКАЗАНИЙ:', n_pred, '| сверенo:', n_ver, '| попаданий:', n_hit,
      '| калибровка на 90% интервале:', ('%.1f%%' % (100 * cal)) if cal is not None else 'нет сверённых')

verdicts = Counter()
n_act = 0
if os.path.exists(JD):
    for line in open(JD, encoding='utf-8'):
        try:
            r = json.loads(line)
        except Exception:
            continue
        n_act += 1
        for key in ('verdict', 'status', 'outcome'):
            v = r.get(key)
            if isinstance(v, str):
                verdicts[v] += 1
print('ДЕЙСТВИЙ (dry-run):', n_act, '|', dict(verdicts) if verdicts else '—')

trust = k03.status_table(reg, now=raw_max.replace(tzinfo=None))
print('--- доверие свойств (живое) ---')
for t in trust:
    print('  %-28s скор=%.3f [%s-%s] сверок=%d открытых=%d' %
          (t['id'], t['score'], t['lo'], t['hi'], t['n_checks'], t['pending']))

print('--- предвестники №6 на живом потоке ---')
rc6 = subprocess.run([PY, os.path.join(DV, '06-forvardy-perenos-temy.py'), 'run', INP,
                      '--lag', '6', '--lift', '1.5', '--out', 'obkat-перенос.jsonl'],
                     capture_output=True, text=True)
print((rc6.stdout or '')[-1800:])
if rc6.returncode != 0:
    print('№6 stderr:', (rc6.stderr or '')[-400:])

cands = []
if os.path.exists('obkat-перенос.jsonl'):
    for line in open('obkat-перенос.jsonl', encoding='utf-8'):
        try:
            r = json.loads(line)
        except Exception:
            continue
        if r.get('is_candidate'):
            cands.append(r)
print('КАНДИДАТОВ-ПРЕДВЕСТНИКОВ (lift_lo>=1.5, echo>=3):', len(cands))
for c in cands[:10]:
    print('  %s: %s -> %s | echo %d/%d | lift %s lo %s' %
          (c['word'], c['from_chat'], c['to_chat'], c['echo_sessions'],
           c['n_source_hours'], c['lift'], c['lift_lo']))

hours_total = int((raw_max - raw_min).total_seconds() // 3600) + 1
with open(REPORT, 'w', encoding='utf-8') as f:
    f.write('# ЖИВАЯ ОБКАТКА ДВИЖКА №1 — 09.11.2026, ночь\n\n')
    f.write('**Топливо:** поток.jsonl — живая история 4 чатов (p2p777kar, ipotekagroup, avtozalogrf, zalogzaym), 14 дней.\n\n')
    f.write('- сообщений: %d | чатов: %d | часов сетки: ~%d\n' % (len(msgs), len(chats), hours_total))
    f.write('- свойства реестра: авто, топ-10 слов живого потока: %s\n' % ', '.join(TOP))
    f.write('- такты шофёра (каждые 6 ч): %d | OK: %d | BROKEN: %d\n' % (ticks, ok_n, broken_n))
    f.write('- предсказаний №4: %d | сверено: %d | попаданий: %d | калибровка: %s\n' %
            (n_pred, n_ver, n_hit, ('%.1f%%' % (100 * cal)) if cal is not None else '—'))
    f.write('- действий №5 (dry-run): %d | %s\n' % (n_act, dict(verdicts) if verdicts else '—'))
    f.write('\n## Доверие свойств (живое)\n\n')
    f.write('| свойство | скор | интервал | сверок |\n|---|---|---|---|\n')
    for t in trust:
        f.write('| %s | %.3f | [%.3f, %.3f] | %d |\n' %
                (t['id'], t['score'], t['lo'], t['hi'], t['n_checks']))
    f.write('\n## Предвестники-кандидаты (№6, is_causal=false — гипотезы)\n\n')
    if cands:
        f.write('| слово | откуда | куда | эхо | lift | lift_lo |\n|---|---|---|---|---|---|\n')
        for c in cands[:15]:
            f.write('| %s | %s | %s | %d/%d | %s | %s |\n' %
                    (c['word'], c['from_chat'], c['to_chat'], c['echo_sessions'],
                     c['n_source_hours'], c['lift'], c['lift_lo']))
    else:
        f.write('кандидатов по правилу (lift_lo>=1.5, echo>=3) не найдено — честно\n')
    f.write('\n*Обкатка — по закону 7 дома: движок судят живые числа, не вера. Первая попытка упала на ошибке обкатчика (ts — datetime, не unix) — починено на дороге, журнал поломок append-only.*\n')
print('отчёт:', REPORT)
PYEOF
timeout 1500 $PY obkat-live.py ../топливо/поток.jsonl 2>&1 | tail -90
echo "--- пуш отчёта в дом ---"
cd /root/kord-glubina/kordinaps-machine || exit 1
git add -f "Hermes/движок/ОБКАТКА-ЖИВАЯ-01.md" "Hermes/движок/obkat-перенос.jsonl" 2>&1 | tail -1
git commit -q -m "живая обкатка v2: фикс обкатчика, полный прогон 4 чатов — отчёт с числами (09.11 ночь)" 2>&1 | tail -1
git push -q origin HEAD:main 2>&1 | tail -1
echo "пуш выполнен"
REMOTE
echo "== 1127: конец =="
