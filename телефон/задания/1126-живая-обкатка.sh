#!/data/data/com.termux/files/usr/bin/bash
# 1126 — ПЕРВАЯ ЖИВАЯ ОБКАТКА ДВИЖКА: поток.jsonl (9 чатов, 14 дней) → все компоненты.
# Капот (doctor) → авто-реестр из топ-слов → такты шофёра каждые 6 ч → предвестники №6.
# Отчёт с числами → в дом. Журналы — append-only, поломка такта не убивает прогон.
echo "== 1126: живая обкатка движка =="
ssh -o BatchMode=yes -o StrictHostKeyChecking=accept-new -o ConnectTimeout=30 root@45.152.198.192 'bash -s' <<'REMOTE'
cd /root/kord-glubina/kordinaps-machine || exit 1
echo "--- git pull ---"
git pull -q origin main 2>&1 | tail -1
if [ ! -d /root/kord-dvizhok-venv ]; then
  echo "--- venv движка (создаётся один раз) ---"
  python3 -m venv /root/kord-dvizhok-venv
fi
echo "--- зависимости движка (pyyaml обязателен, pymorphy3 — иначе фолбэк) ---"
/root/kord-dvizhok-venv/bin/pip install -q --no-input pyyaml pymorphy3 2>&1 | tail -2
cd Hermes/движок || exit 1
PY=/root/kord-dvizhok-venv/bin/python
echo "--- капот: doctor всех шести ---"
$PY 07-shofer-dvizhka.py doctor 2>&1 | tail -10
echo "--- обкатчик живого потока ---"
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

t_min, t_max = min(r['ts'] for r in msgs), max(r['ts'] for r in msgs)
t0 = datetime.fromtimestamp(t_min, tz=timezone.utc).replace(tzinfo=None)
reg = k03.new_registry()
for w in TOP:
    chat = max((c for (c, ww) in chat_wc if ww == w), key=lambda c: chat_wc[(c, w)])
    k03.add_property(reg, chat, w, 'живая обкатка 09.11, автосвойство', now=t0)
    print('свойство:', chat + '-' + w, '(сообщений:', chat_wc[(chat, w)], ')')
k03.save(reg, REG)

STEP = 6 * 3600
ticks, ok_n, broken_n = 0, 0, 0
now_ts = t_min + STEP
while now_ts <= t_max:
    now_iso = datetime.fromtimestamp(now_ts, tz=timezone.utc).replace(tzinfo=None).isoformat()
    rc = subprocess.run([PY, os.path.join(DV, '07-shofer-dvizhka.py'), 'run', INP,
                         '--now', now_iso, '--registry', REG, '--actions', ACT,
                         '--journal', JT, '--errors', JE],
                        capture_output=True, text=True)
    ticks += 1
    if rc.returncode == 0:
        ok_n += 1
    else:
        broken_n += 1
        print('ТАКТ СЛОМАН @', now_iso, 'код', rc.returncode, (rc.stderr or '')[-160:])
    if ticks % 10 == 0:
        print('... тактов:', ticks, 'OK:', ok_n, 'BROKEN:', broken_n)
    now_ts += STEP
print('ТАКТОВ:', ticks, '| OK:', ok_n, '| BROKEN (записаны в журнал, данные не тронуты):', broken_n)

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

trust = k03.status_table(reg, now=datetime.fromtimestamp(t_max, tz=timezone.utc).replace(tzinfo=None))
print('--- доверие свойств (живое) ---')
for t in trust:
    print('  %-28s скор=%.3f [%s-%s] сверок=%d открытых=%d' %
          (t['id'], t['score'], t['lo'], t['hi'], t['n_checks'], t['pending']))

print('--- предвестники №6 на живом потоке ---')
rc6 = subprocess.run([PY, os.path.join(DV, '06-forvardy-perenos-temy.py'), 'run', INP,
                      '--lag', '6', '--lift', '1.5', '--out', 'obkat-перенос.jsonl'],
                     capture_output=True, text=True)
print(rc6.stdout[-1500:])
if rc6.returncode != 0:
    print('№6 stderr:', (rc6.stderr or '')[-300:])

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

hours_total = int((t_max - t_min) / 3600) + 1
with open(REPORT, 'w', encoding='utf-8') as f:
    f.write('# ЖИВАЯ ОБКАТКА ДВИЖКА №1 — 09.11.2026, ночь\n\n')
    f.write('**Топливо:** поток.jsonl — живая история 9 болевых чатов, 14 дней.\n\n')
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
    f.write('\n*Обкатка — по закону 7 дома: движок судят живые числа, не вера. Поломки тактов — в obkat-поломки.jsonl (append-only), данные не тронуты.*\n')
print('отчёт:', REPORT)
PYEOF
timeout 1500 $PY obkat-live.py ../топливо/поток.jsonl 2>&1 | tail -80
echo "--- пуш отчёта в дом ---"
git add -f ОБКАТКА-ЖИВАЯ-01.md obkat-перенос.jsonl 2>&1 | tail -1
git commit -q -m "живая обкатка движка №1: 9 чатов, 14 дней, все компоненты — отчёт с числами (09.11 ночь)" 2>&1 | tail -1
git push -q origin HEAD:main 2>&1 | tail -1
echo "пуш выполнен"
REMOTE
echo "== 1126: конец =="
