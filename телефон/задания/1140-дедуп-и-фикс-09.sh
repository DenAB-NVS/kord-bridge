#!/data/data/com.termux/files/usr/bin/bash
# 1140 — 09 v1.1: фикс текст() (selftest 1139 упал на списках сущностей
# Telethon — поле() пропускал не-строки) + --дедуп против спам-рассылок
# (урок 1139: тема 17 раздута одним постом P2P777KAR, размноженным
# с вариациями хвоста). Прогон с дедупом на том же потоке 3893 сообщений.
# Правка 09 коммитится в дом с сервера (паттерн 1139).
echo "== 1140: 09 v1.1 — фикс текст() + дедуп =="
ssh -o BatchMode=yes -o StrictHostKeyChecking=accept-new -o ConnectTimeout=30 -o ServerAliveInterval=20 root@45.152.198.192 'bash -s' <<'REMOTE'
cd /root/kord-glubina/kordinaps-machine || exit 1
echo "--- git pull ---"
git pull -q origin main 2>&1 | tail -1
echo "--- 09 v1.1 (перезапись) ---"
cat > Hermes/движок/09-тест-словаря-тем.py <<'PYEOF'
#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""09 — тест словаря тем: ловит ли CSV (18 тем) живую беду в потоке.

Юнит — цепочка, не слово (решение сессии 09.11). Фразы словаря и сообщения
лемматизируются pymorphy3 (ё→е, один анализатор на прогон — урок 06 v1.2).
Сообщение относится к теме, если ВСЕ леммы какой-нибудь фразы темы есть
в сообщении. Дальше фильтр живого: первое лицо (я/мой) + цифра.
Выборка N случайных попаданий — глазами: живая беда или реклама.
--дедуп: схлопывать повторы (урок 1139 — тема 17 раздута одним
спам-постом P2P777KAR, размноженным с вариациями хвоста).

Запуск (python -u — закон буферизации stdout):
  python -u 09-тест-словаря-тем.py --поток поток.jsonl --словарь poisk_chatov_18_tem.csv [--выборка 30] [--дедуп] [--выхлоп отчёт.json]
  python -u 09-тест-словаря-тем.py --selftest

is_causal=false: тест качества топлива, не вердикт.
v1.1 (09.11, 1140): текст() не видел списки сущностей Telethon — поле()
пропускал не-строки; теперь текст() читает сообщение напрямую. + --дедуп, selftest 7.
"""
import argparse, csv, json, random, re, sys
from collections import defaultdict

try:
    import pymorphy3
except ImportError:
    print("НЕТ pymorphy3 — тест не пойдёт (на сервере: /root/kord-dvizhok-venv)")
    sys.exit(2)

MORPH = pymorphy3.MorphAnalyzer()
TOKEN = re.compile(r"[0-9a-zа-яё-]+", re.IGNORECASE)
ПЕРВОЕ_ЛИЦО = {"я", "мой"}
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


def load_dict(path):
    темы = {}
    with open(path, newline="", encoding="utf-8-sig") as f:
        for row in csv.DictReader(f):
            topic = (row.get("topic") or "").strip()
            group = (row.get("group") or "").strip()
            query = (row.get("query") or "").strip()
            if not (topic and query):
                continue
            фраз_леммы = lemmas_text(query)
            if not фраз_леммы:
                continue
            t = темы.setdefault(topic, {"группы": set(), "фразы": []})
            t["фразы"].append((query, фраз_леммы))
            t["группы"].add(group)
    return темы


def load_flow(path):
    msgs = []
    with open(path, encoding="utf-8") as f:
        for line in f:
            line = line.strip()
            if not line:
                continue
            try:
                msgs.append(json.loads(line))
            except json.JSONDecodeError:
                continue
    return msgs


def поле(msg, keys):
    for k in keys:
        v = msg.get(k)
        if isinstance(v, str) and v:
            return v
    return None


def текст(msg):
    for k in TEXT_KEYS:
        v = msg.get(k)
        if isinstance(v, list):
            return "".join(s.get("text", "") if isinstance(s, dict) else str(s) for s in v)
        if isinstance(v, str) and v:
            return v
    return ""


def selftest():
    ok = 0
    assert lemma("ёлки") == "елка", lemma("ёлки"); ok += 1
    assert lemma("Просрочки") == "просрочка", lemma("Просрочки"); ok += 1
    фраз = set(lemmas_text("просрочка по ипотеке"))
    сообщ = set(lemmas_text("У меня просрочки по ипотеке, банк требует"))
    assert фраз <= сообщ; ok += 1
    сообщ2 = set(lemmas_text("Ипотека одобрена банком"))
    assert not (фраз <= сообщ2); ok += 1
    assert lemma("мне") in ПЕРВОЕ_ЛИЦО and lemma("моего") in ПЕРВОЕ_ЛИЦО; ok += 1
    assert текст({"text": [{"text": "при"}, {"text": "вет"}]}) == "привет"; ok += 1
    assert дедуп_ключ("Продам аккаунт!") == дедуп_ключ("продам  АККАУНТ"); ok += 1
    print(f"SELFTEST OK: {ok}/7")
    return 0


def main():
    ap = argparse.ArgumentParser(description="тест словаря тем на живом потоке")
    ap.add_argument("--поток")
    ap.add_argument("--словарь")
    ap.add_argument("--выборка", type=int, default=30)
    ap.add_argument("--дедуп", action="store_true")
    ap.add_argument("--выхлоп")
    ap.add_argument("--selftest", action="store_true")
    args = ap.parse_args()

    if args.selftest:
        return selftest()
    if not (args.поток and args.словарь):
        ap.error("нужны --поток и --словарь (или --selftest)")

    темы = load_dict(args.словарь)
    фраз_всего = sum(len(t["фразы"]) for t in темы.values())
    print(f"СЛОВАРЬ: {фраз_всего} фраз, {len(темы)} тем")

    msgs = load_flow(args.поток)
    if not msgs:
        print("ПОТОК ПУСТ или не читается")
        return 2
    print(f"ПОТОК: {len(msgs)} сообщений; поля: {sorted(msgs[0].keys())}")
    if args.дедуп:
        seen = set()
        уникальные = []
        for m in msgs:
            к = дедуп_ключ(текст(m))
            if к is None or к in seen:
                continue
            seen.add(к)
            уникальные.append(m)
        print(f"ДЕДУП: {len(msgs) - len(уникальные)} дублей схлопнуто → {len(уникальные)} уникальных")
        msgs = уникальные

    попадания = defaultdict(int)
    живые = defaultdict(int)
    по_группам = defaultdict(int)
    матчи = []
    всего_текстовых = 0
    сообщений_с_темой = 0
    живых_всего = 0

    for i, m in enumerate(msgs):
        т = текст(m)
        if not т.strip():
            continue
        всего_текстовых += 1
        лем = set(lemmas_text(т))
        первое = bool(ПЕРВОЕ_ЛИЦО & лем)
        цифра = bool(re.search(r"\d", т))
        найдены = []
        for тема, t in темы.items():
            hit = False
            for _, фраз_леммы in t["фразы"]:
                if set(фраз_леммы) <= лем:
                    hit = True
                    break
            if hit:
                найдены.append(тема)
                for g in t["группы"]:
                    по_группам[g] += 1
        if найдены:
            сообщений_с_темой += 1
            if первое and цифра:
                живых_всего += 1
            for тема in найдены:
                попадания[тема] += 1
                if первое and цифра:
                    живые[тема] += 1
            матчи.append({"i": i, "темы": найдены, "первое": первое, "цифра": цифра,
                          "чат": поле(m, CHAT_KEYS) or "?", "текст": т[:200]})

    print("\n== ПОПАДАНИЯ ==")
    print(f"сообщений с текстом: {всего_текстовых}; с темой: {сообщений_с_темой}"
          f" ({100.0 * сообщений_с_темой / max(1, всего_текстовых):.1f}%)")
    print(f"живых (первое лицо + цифра): {живых_всего}"
          f" ({100.0 * живых_всего / max(1, сообщений_с_темой):.1f}% от попавших)")

    print("\nтема | фраз | сообщений | живых | доля живого")
    for тема in sorted(темы, key=lambda x: -попадания[x]):
        n, ж = попадания[тема], живые[тема]
        доля = f"{100.0 * ж / n:.0f}%" if n else "—"
        print(f"{тема} | {len(темы[тема]['фразы'])} | {n} | {ж} | {доля}")

    пустые = [т for т in темы if попадания[т] == 0]
    print(f"\nПУСТЫЕ ТЕМЫ ({len(пустые)}): " + ("; ".join(пустые) if пустые else "нет"))

    print("ПО ГРУППАМ СЛОВАРЯ: " + ", ".join(f"{g}: {n}"
          for g, n in sorted(по_группам.items(), key=lambda kv: -kv[1])) or "нет попаданий")

    rng = random.Random(20261109)
    выборка = rng.sample(матчи, min(args.выборка, len(матчи))) if матчи else []
    print(f"\n== ВЫБОРКА {len(выборка)} (глазами: живая беда или реклама?) ==")
    for n, м in enumerate(выборка, 1):
        print(f"{n}. [{' ; '.join(м['темы'])}] первое={'да' if м['первое'] else 'нет'} "
              f"цифра={'да' if м['цифра'] else 'нет'} ({м['чат']}) {м['текст']}")

    if args.выхлоп:
        with open(args.выхлоп, "w", encoding="utf-8") as f:
            json.dump({"сообщений": всего_текстовых, "с_темой": сообщений_с_темой,
                       "живых": живых_всего, "дедуп": bool(args.дедуп),
                       "по_темам": {т: [попадания[т], живые[т]] for т in темы},
                       "выборка": выборка}, f, ensure_ascii=False, indent=1)
        print(f"\nВЫХЛОП: {args.выхлоп}")
    print("\nis_causal=false — тест качества топлива, не вердикт.")
    return 0


if __name__ == "__main__":
    sys.exit(main())
PYEOF
PY=/root/kord-dvizhok-venv/bin/python
cd Hermes/движок || exit 1
echo "--- selftest (ожидаем 7/7) ---"
timeout 300 $PY 09-тест-словаря-тем.py --selftest 2>&1
echo "--- тест с --дедуп (3893 сообщения, выборка 30) ---"
timeout 900 $PY -u 09-тест-словаря-тем.py --поток ../топливо/поток.jsonl --словарь /root/kord-glubina/kordinaps-machine/проекты/poisk_chatov_18_tem.csv --выборка 30 --дедуп 2>&1
echo "--- коммит 09 v1.1 в дом ---"
cd /root/kord-glubina/kordinaps-machine || exit 1
git add Hermes/движок/09-тест-словаря-тем.py
git commit -q -m "09 v1.1: фикс текст() — списки сущностей Telethon (падение selftest 1139) + --дедуп против спам-рассылок (тема 17, урок P2P777KAR) (09.11)" 2>&1 | tail -1
if git push -q origin HEAD:main 2>/tmp/1140-push.err; then echo "пуш ок"; else echo "пуш отбит — rebase и повтор"; git pull -q --rebase origin main 2>&1 | tail -1; git push -q origin HEAD:main 2>&1 | tail -1 && echo "пуш после rebase ок"; fi
REMOTE
echo "== 1140: конец =="
