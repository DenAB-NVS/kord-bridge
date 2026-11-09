#!/data/data/com.termux/files/usr/bin/bash
# 1133 — порезать исследование предвестников (74 КБ) на части по ~18 КБ
# (границы строк), чтобы дом дочитал хвост: ярусы слов (60+122), чёрный
# список (24 ловушки), карта разведки, честность. Части: проекты/исследование-части/.
echo "== 1133: порез исследования =="
ssh -o BatchMode=yes -o StrictHostKeyChecking=accept-new -o ConnectTimeout=30 -o ServerAliveInterval=20 root@45.152.198.192 'bash -s' <<'REMOTE'
cd /root/kord-glubina/kordinaps-machine || exit 1
echo "--- git pull ---"
git pull -q origin main 2>&1 | tail -1
f="проекты/ПРЕДВЕСТНИКИ-СОБЫТИЕ-ДО-ЗАЯВКИ-2026-10-31.md"
echo "--- исходник ---"
wc -c "$f"
rm -rf проекты/исследование-части
mkdir -p проекты/исследование-части
cd проекты
split -C 18000 -d -a 2 --additional-suffix=.md "ПРЕДВЕСТНИКИ-СОБЫТИЕ-ДО-ЗАЯВКИ-2026-10-31.md" "исследование-части/часть-"
cd ..
echo "--- части ---"
wc -c проекты/исследование-части/*.md
git add -f "проекты/исследование-части" 2>&1 | tail -1
git commit -q -m "исследование предвестников порезано на части — дом дочитывает хвост (09.11, 1133)" 2>&1 | tail -1
git push -q origin HEAD:main 2>&1 | tail -1
echo "пуш выполнен"
REMOTE
echo "== 1133: конец =="
