#!/data/data/com.termux/files/usr/bin/bash
# 1121 — ВЫРЕЗКИ ГРУППЫ А (залог/недвижимость, 18 чатов по chat_id) из стека линзы → лёгкий файл в дом. Последние 15 сообщений на чат, текст до 300 знаков.
echo "== 1121: вырезки группы А =="
ssh -o BatchMode=yes -o StrictHostKeyChecking=accept-new -o ConnectTimeout=15 root@45.152.198.192 '
cd /root/kord-glubina/kordinaps-machine || exit 1
R=$(git remote | head -1)
git fetch "$R" main >/dev/null 2>&1
git rebase "$R/main" >/dev/null 2>&1
python3 - <<PYEOF
import json, glob
ids = {
 "-1004391894910": "ЗАЛОГ-КЕЙСЫ живые заявки",
 "-1001604814667": "Занько юрист",
 "-1001421490433": "Bezdelka",
 "-1002417913249": "Инсайдер Лобанкова",
 "-1001815552618": "Коммерческая недвижимость",
 "-1001904835913": "Медведев проверки",
 "-1001384668955": "КАДАСТРZЕМ",
 "-1002431773149": "Формула земли",
 "-1001744517467": "Дарья про землю",
 "-1002400977375": "Апартономика",
 "-1002154722993": "ТОП НОВОСТРОЕК",
 "-1001426135915": "Недвижимость Ростова",
 "-1002237759539": "Новый Ростов",
 "-1003723677343": "Нижний Тагил",
 "-1003962332583": "Владимир",
 "-1001741112654": "Риелторы Россия",
 "-1001853088149": "Кудинов доходная",
 "-1001459415582": "Инвестиции Студента",
}
lines = ["# ПРОХОД ГРУППЫ А — залог/недвижимость, вырезки из стека (срез 08.11, по слову владельца)", ""]
found = 0
total = 0
for f in sorted(glob.glob("/root/kord-linza/стек/*.json")):
    try:
        d = json.load(open(f, encoding="utf-8"))
    except Exception:
        continue
    msgs = d.get("messages") if isinstance(d, dict) else d
    if not isinstance(msgs, list) or not msgs:
        continue
    cid = str(d.get("chat_id", "")) if isinstance(d, dict) else str(msgs[0].get("chat_id", ""))
    if cid not in ids:
        continue
    chat = (d.get("chat") if isinstance(d, dict) else "") or ids[cid]
    found += 1
    lines.append("## " + ids[cid] + " | " + chat + " | chat_id=" + cid)
    for m in [m for m in msgs if isinstance(m, dict)][-15:]:
        t = m.get("text") or m.get("message") or m.get("caption") or ""
        if isinstance(t, list):
            t = " ".join(str(x) for x in t)
        t = str(t).replace("\n", " ").strip()
        if not t:
            continue
        total += 1
        lines.append("- [" + str(m.get("date", "")) + "] " + t[:300])
    lines.append("")
open("проекты/ПРОХОД-ГРУППА-А-2026-11-08.md", "w", encoding="utf-8").write("\n".join(lines))
print("чатов группы А найдено:", found, "| сообщений:", total)
PYEOF
OUT="проекты/ПРОХОД-ГРУППА-А-2026-11-08.md"
echo "-- размер: $(wc -c < "$OUT") байт --"
git add "$OUT"
git commit -q -m "ПРОХОД ГРУППА А: вырезки 18 чатов залог/недвижимость из стека (по слову владельца)" && echo "коммит: ок"
git push "$R" HEAD:main 2>&1 | tail -2
'
echo "== 1121: конец =="
