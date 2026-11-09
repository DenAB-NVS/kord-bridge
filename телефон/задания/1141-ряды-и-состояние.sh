#!/data/data/com.termux/files/usr/bin/bash
# 1141 — 10-ряды-цепочек: словарь тем признан рабочим (дедуп, живое 12.5%),
# строим ряды по 18 цепочкам в формате движка (01-конвертера) и закрываем
# фронт: дозапись СОСТОЯНИЕ-ДОМА v1.13 + сводка в Звонок.
echo "== 1141: ряды цепочек + СОСТОЯНИЕ v1.13 + сводка =="
ssh -o BatchMode=yes -o StrictHostKeyChecking=accept-new -o ConnectTimeout=30 -o ServerAliveInterval=20 root@45.152.198.192 'bash -s' <<'REMOTE'
cd /root/kord-glubina/kordinaps-machine || exit 1
echo "--- git pull ---"
git pull -q origin main 2>&1 | tail -1
echo "--- 10-ряды-цепочек.py ---"
cat > Hermes/движок/10-ряды-цепочек.py <<'PYEOF'
#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""10 — ряды цепочек: поток сообщений × словарь тем → матрица тема×чат×час.

Формат — как у 01-конвертера-часовых-бинов (движок ест без переделок):
    chat, hour, word, mentions, messages, freq, is_incomplete_hour
word здесь — код темы (т1..т18), расшифровка в meta.

Законы (те же, атлас часть 18):
1. Час — общий знаменатель.
2. Пустые часы — часть сигнала: сетка непрерывна от первого до последнего.
3. Последний час всегда недосчитан — помечен, не чинится.
4. Нормировка на объём часа: freq = доля сообщений чат-часа с темой.
5. Лемматизация pymorphy3 (ё→е), один анализатор на прогон.
Цепочка: сообщение несёт тему, если ВСЕ леммы какой-нибудь фразы темы
есть в сообщении (решение сессии 09.11; 09-тест-словаря-тем v1.1).
Дедуп — по умолчанию: спам-рассылки схлопываются (урок 1140: 2454 дубля
из 3893; без дедупа тема 17 раздувалась одним постом P2P777KAR).

is_causal=false: ряды — топливо для скоринга, не вердикт о связях.

Запуск:
  python -u 10-ряды-цепочек.py --поток поток.jsonl --словарь dict.csv --out ряды.csv --meta meta.json
  python -u 10-ряды-цепочек.py --selftest
"""
import argparse, csv, json, re, sys
from collections import Counter, defaultdict
from datetime import datetime, timedelta, timezone

try:
    import pymorphy3
except ImportError:
    print("НЕТ pymorphy3 — ряды не построятся (на сервере: /root/kord-dvizhok-venv)")
    sys.exit(2)

MORPH = pymorphy3.MorphAnalyzer()
TOKEN = re.compile(r"[0-9a-zа-яё-]+", re.IGNORECASE)
TEXT_KEYS = ("text", "message", "текст", "msg", "raw")
CHAT_KEYS = ("chat", "chat_title", "chat_name", "чат", "group", "peer", "source")


def lemma(w):
    p = MORPH.parse(w)
    nf = p[0].normal_form if p else w
    return nf.lower().replace("ё", "е")


def lemmas_text(text):
    return [lemma(t) for t in TOKEN.findall(text or "")]


def дедуп_ключ(т):
    н = re.sub(r"[^0-9a-zа-яё]", "", (т or "").lower().replace("ё", "е"))
    return н[:120] or None


def текст(msg):
    for k in TEXT_KEYS:
        v = msg.get(k)
        if isinstance(v, list):
            return "".join(s.get("text", "") if isinstance(s, dict) else str(s) for s in v)
        if isinstance(v, str) and v:
            return v
    return ""


def поле(msg, keys):
    for k in keys:
        v = msg.get(k)
        if isinstance(v, str) and v:
            return v
    return None


def parse_ts(value):
    if isinstance(value, (int, float)):
        return datetime.fromtimestamp(value, tz=timezone.utc).replace(tzinfo=None)
    if isinstance(value, str):
        v = value.strip().replace("Z", "+00:00")
        dt = datetime.fromisoformat(v)
        return dt.replace(tzinfo=None) if dt.tzinfo is None else dt.astimezone(timezone.utc).replace(tzinfo=None)
    raise TypeError(f"ts должен быть числом или ISO-строкой, получено: {type(value)}")


def load_dict(path):
    темы = {}
    with open(path, newline="", encoding="utf-8-sig") as f:
        for row in csv.DictReader(f):
            topic = (row.get("topic") or "").strip()
            group = (row.get("group") or "").strip()
            query = (row.get("query") or "").strip()
            if not (topic and query):
                continue
            m = re.match(r"^\s*(\d+)", topic)
            код = f"т{int(m.group(1))}" if m else "т" + re.sub(r"\W", "", topic)[:12]
            фраз_леммы = lemmas_text(query)
            if not фраз_леммы:
                continue
            t = темы.setdefault(код, {"название": topic, "группы": set(), "фразы": []})
            t["фразы"].append(фраз_леммы)
            t["группы"].add(group)
    return темы


def hour_floor(dt):
    return dt.replace(minute=0, second=0, microsecond=0)


def load_flow(path):
    msgs = []
    with open(path, encoding="utf-8") as f:
        for line in f:
            line = line.strip()
            if not line:
                continue
            try:
                rec = json.loads(line)
            except json.JSONDecodeError:
                continue
            rec["ts_dt"] = parse_ts(rec.get("ts"))
            msgs.append(rec)
    return msgs


def build_rows(msgs, темы, дедуп=True):
    if дедуп:
        seen = set()
        уникальные = []
        for m in msgs:
            к = дедуп_ключ(текст(m))
            if к is None or к in seen:
                continue
            seen.add(к)
            уникальные.append(m)
        msgs = уникальные
    if not msgs:
        raise ValueError("поток пуст (после дедупа)")
    hours_chats = defaultdict(set)
    msgs_in_hour = Counter()
    theme_in_hour = Counter()
    тем_попаданий = Counter()
    for rec in msgs:
        chat = поле(rec, CHAT_KEYS) or "?"
        hour = hour_floor(rec["ts_dt"])
        hours_chats[chat].add(hour)
        msgs_in_hour[(chat, hour)] += 1
        лем = set(lemmas_text(текст(rec)))
        for код, t in темы.items():
            if any(set(ф) <= лем for ф in t["фразы"]):
                theme_in_hour[(код, chat, hour)] += 1
                тем_попаданий[код] += 1
    all_hours = sorted({h for hs in hours_chats.values() for h in hs})
    grid = []
    cur = all_hours[0]
    while cur <= all_hours[-1]:
        grid.append(cur)
        cur += timedelta(hours=1)
    last_hour = all_hours[-1]
    rows = []
    for chat in sorted(hours_chats):
        for hour in grid:
            n_msgs = msgs_in_hour.get((chat, hour), 0)
            for код in sorted(темы):
                mentions = theme_in_hour.get((код, chat, hour), 0)
                rows.append({
                    "chat": chat,
                    "hour": hour.isoformat(),
                    "word": код,
                    "mentions": mentions,
                    "messages": n_msgs,
                    "freq": (mentions / n_msgs) if n_msgs else 0.0,
                    "is_incomplete_hour": hour == last_hour,
                })
    meta = {
        "chats": sorted(hours_chats),
        "hour_from": grid[0].isoformat(),
        "hour_to": grid[-1].isoformat(),
        "n_hours": len(grid),
        "n_messages": len(msgs),
        "n_rows": len(rows),
        "дедуп": bool(дедуп),
        "incomplete_hour": last_hour.isoformat(),
        "темы": {код: {"название": t["название"], "группы": sorted(t["группы"]),
                       "фраз": len(t["фразы"]), "попаданий": тем_попаданий[код]}
                 for код, t in sorted(темы.items())},
        "is_causal": False,
    }
    return rows, meta


def selftest():
    ok = 0
    темы = {"т1": {"название": "1. Тест", "группы": {"Ядро"}, "фразы": [["просрочка", "ипотека"]]},
            "т2": {"название": "2. Тест2", "группы": {"Ядро"}, "фразы": [["семейная", "ипотека"]]}}
    base = datetime(2026, 11, 1, 0, 0)
    msgs = []
    def add(chat, h, text, n=1):
        for i in range(n):
            msgs.append({"chat": chat, "ts": (base + timedelta(hours=h, minutes=i)).timestamp(), "text": text})
    add("A", 0, "у меня просрочка по ипотеке 3 месяца", 2)
    add("A", 0, "ипотека одобрена", 2)
    add("A", 1, "семейная ипотека под 6%", 1)
    add("A", 3, "обычное сообщение", 1)
    add("A", 4, "дубль спама", 5)
    rows, meta = build_rows(msgs, темы, дедуп=True)
    by = {(r["chat"], r["hour"], r["word"]): r for r in rows}
    assert meta["n_hours"] == 5, meta["n_hours"]; ok += 1
    assert meta["n_messages"] == 5, meta["n_messages"]; ok += 1
    r = by[("A", base.isoformat(), "т1")]
    assert r["messages"] == 2 and r["mentions"] == 1 and abs(r["freq"] - 0.5) < 1e-9, r; ok += 1
    assert by[("A", (base + timedelta(hours=1)).isoformat(), "т1")]["mentions"] == 0; ok += 1
    assert by[("A", (base + timedelta(hours=1)).isoformat(), "т2")]["mentions"] == 1; ok += 1
    n_inc = sum(1 for r in rows if r["is_incomplete_hour"])
    assert meta["incomplete_hour"] == (base + timedelta(hours=4)).isoformat() and n_inc > 0; ok += 1
    print(f"SELFTEST OK: {ok}/6")
    return 0


def main():
    ap = argparse.ArgumentParser(description="ряды цепочек: поток × словарь тем → матрица тема×чат×час")
    ap.add_argument("--поток")
    ap.add_argument("--словарь")
    ap.add_argument("--out")
    ap.add_argument("--meta")
    ap.add_argument("--без-дедуп", action="store_true")
    ap.add_argument("--selftest", action="store_true")
    args = ap.parse_args()
    if args.selftest:
        return selftest()
    if not (args.поток and args.словарь and args.out):
        ap.error("нужны --поток, --словарь и --out (или --selftest)")
    темы = load_dict(args.словарь)
    фраз_всего = sum(len(t["фразы"]) for t in темы.values())
    print(f"СЛОВАРЬ: {фраз_всего} фраз, {len(темы)} тем")
    msgs = load_flow(args.поток)
    print(f"ПОТОК: {len(msgs)} сообщений (до дедупа)")
    rows, meta = build_rows(msgs, темы, дедуп=not args.без_дедуп)
    if meta["дедуп"]:
        print(f"ДЕДУП: {len(msgs) - meta['n_messages']} дублей схлопнуто → {meta['n_messages']} уникальных")
    with open(args.out, "w", encoding="utf-8", newline="") as f:
        w = csv.DictWriter(f, fieldnames=["chat", "hour", "word", "mentions", "messages", "freq", "is_incomplete_hour"])
        w.writeheader()
        w.writerows(rows)
    print(f"РЯДЫ: {args.out} ({meta['n_rows']} строк; {meta['n_hours']} часов; чаты: {', '.join(meta['chats'])})")
    if args.meta:
        with open(args.meta, "w", encoding="utf-8") as f:
            json.dump(meta, f, ensure_ascii=False, indent=1)
        print(f"META: {args.meta}")
    топ = sorted(meta["темы"].items(), key=lambda kv: -kv[1]["попаданий"])
    print("топ тем по попаданиям: " + "; ".join(f"{к}={v['попаданий']}" for к, v in топ[:6]))
    print("is_causal=false — ряды топлива, не вердикт.")
    return 0


if __name__ == "__main__":
    sys.exit(main())
PYEOF
PY=/root/kord-dvizhok-venv/bin/python
cd Hermes/движок || exit 1
echo "--- selftest 10 (ожидаем 6/6) ---"
timeout 300 $PY 10-ряды-цепочек.py --selftest 2>&1
echo "--- ряды на живом потоке (3893 сообщения, дедуп) ---"
timeout 900 $PY -u 10-ряды-цепочек.py --поток ../топливо/поток.jsonl --словарь /root/kord-glubina/kordinaps-machine/проекты/poisk_chatov_18_tem.csv --out ряды-цепочек.csv --meta ряды-цепочек-meta.json 2>&1
echo "--- контроль ---"
wc -l ряды-цепочек.csv
head -3 ряды-цепочек.csv

echo "--- СОСТОЯНИЕ-ДОМА v1.13 (дозапись) ---"
cd /root/kord-glubina/kordinaps-machine || exit 1
cat >> Hermes/СОСТОЯНИЕ-ДОМА.md <<'STATEEOF'

## v1.13 — словарь тем и ряды цепочек (09.11)

Решение сессии: CSV poisk_chatov_18_tem.csv (3258 фраз, 18 тем) — словарь тем,
единица — цепочка (все леммы фразы в сообщении), не слово. Лежит в проекты/.
Испытан 09-тест-словаря-тем v1.1 на живом топливе (3893 сообщения, 4 чата):
- сырой поток: 795 сообщений с темой (20.4%), живых 2.5%;
- дедуп спам-рассылок (урок P2P777KAR): 2454 дубля → 1439 уникальных,
  88 с темой (6.1%), живых 12.5%; тема 17 (криптобиржи) 608→4 — ловушка спама;
- рабочие цепочки: т13 семейная ипотека (32, 22% живых), т1 просрочка (18, 22%),
  т18 банкротство (25, 12%), т4 арест имущества, т6 выход партнёра (по 20%);
- 5 пустых тем (3, 9, 10, 11, 14) — ярус-1, в болевых чатах не звучат, норма.
Фикс 09 v1.1: текст() склеивает списки сущностей Telethon (selftest 7/7).
Новый 10-ряды-цепочек.py: поток × словарь → матрица тема×чат×час в формате
01-конвертера (chat/hour/word/mentions/messages/freq/is_incomplete_hour,
word=код темы т1..т18, дедуп по умолчанию, сетка непрерывна, последний час
помечен, не чинится). Ряды — топливо скоринга, is_causal=false.
Путь доставки словаря (Звонок ← сервер, рецепт 1125: конфиг.json + acc1 +
туннель 17443) закрыт заданиями 1136–1140. Дальше: тройная проверка
кандидатов (Granger + BH-FDR, PCMCI+, устойчивость к сдвигу окна).
STATEEOF
tail -5 Hermes/СОСТОЯНИЕ-ДОМА.md

echo "--- сводка в Звонок ---"
cat > /root/kord-glubina/svodka-v-zvonok.py <<'PYEOF'
import asyncio, json, sqlite3, shutil, os
from telethon import TelegramClient
from telethon.tl.types import PeerChannel
cfg = json.load(open('/root/рассылка/конфиг.json', encoding='utf-8'))
API_ID, API_HASH = int(cfg['api_id']), cfg['api_hash']
BASE = '/root/kord-linza'
WORK = os.path.join(BASE, 'стек', '.work-svodka')
os.makedirs(WORK, exist_ok=True)
shutil.copyfile('/root/рассылка/sessions/acc1.session', os.path.join(WORK, 'acc1.session'))
db = sqlite3.connect(os.path.join(WORK, 'acc1.session'))
db.execute('update sessions set server_address=?, port=?', ('127.0.0.1', 17443))
db.commit(); db.close()
MSG = "движок — сводка 1141:\nсловарь тем (3258 фраз, 18 тем) испытан и признан рабочим.\nживое топливо: 3893 → дедуп → 1439 уникальных; с темой 88 (6.1%), живых 12.5%.\nтема 17 — ловушка спама P2P777KAR: 608 → 4 после дедупа.\nрабочие цепочки: семейная ипотека 22% живых, просрочка 22%, банкротство 12%.\n10-ряды-цепочек: матрица тема×чат×час в формате движка — ряды легли.\nis_causal=false. дальше: тройная проверка кандидатов (Granger+BH-FDR, PCMCI+)."
async def main():
    client = TelegramClient(os.path.join(WORK,'acc1'), API_ID, API_HASH, receive_updates=False, request_retries=1, connection_retries=1, timeout=25)
    await asyncio.wait_for(client.connect(), 35)
    if not await client.is_user_authorized():
        print('acc1 НЕ авторизован'); await client.disconnect(); return
    ent = await client.get_entity(PeerChannel(4473651001))
    await client.send_message(ent, MSG)
    print('СВОДКА ОТПРАВЛЕНА В ЗВОНК')
    await client.disconnect()
asyncio.run(main())
shutil.rmtree(WORK, ignore_errors=True)
PYEOF
timeout 120 /root/kord-linza/venv/bin/python /root/kord-glubina/svodka-v-zvonok.py 2>&1 | tail -3

echo "--- коммит в дом ---"
git add Hermes/движок/10-ряды-цепочек.py Hermes/движок/ряды-цепочек.csv Hermes/движок/ряды-цепочек-meta.json Hermes/СОСТОЯНИЕ-ДОМА.md
git commit -q -m "10-ряды-цепочек: матрица тема×чат×час в формате движка; СОСТОЯНИЕ v1.13 — словарь тем решён, дедуп, ряды (09.11)" 2>&1 | tail -1
if git push -q origin HEAD:main 2>/tmp/1141-push.err; then echo "пуш ок"; else echo "пуш отбит — rebase и повтор"; git pull -q --rebase origin main 2>&1 | tail -1; git push -q origin HEAD:main 2>&1 | tail -1 && echo "пуш после rebase ок"; fi
REMOTE
echo "== 1141: конец =="
