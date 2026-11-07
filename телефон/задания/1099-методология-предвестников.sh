#!/data/data/com.termux/files/usr/bin/bash
# 1099 — методология предвестников: определение + свежие сигналы. Только чтение, телефоны замаскированы.
echo "== 1099: методология предвестников =="
ssh -o BatchMode=yes -o ConnectTimeout=25 root@45.152.198.192 '
M() { sed -E "s/[0-9+][0-9 -]{9,}/[ТЕЛЕФОН]/g"; }
echo "-- 1. Карта радара (верхний уровень) --"
ls /root/radar/ 2>/dev/null | head -40
echo
echo "-- 2. Где определены предвестники --"
grep -rlni "редвестник" /root/radar/ /root/kord-glubina/*.md 2>/dev/null | grep -v ".bak" | head -10
echo
echo "-- 3. Канон: контекст определения (первые находки .md) --"
for f in $(grep -rlni "редвестник" /root/radar/ 2>/dev/null | grep -E "\.md$" | grep -v ".bak" | head -2); do
  echo "### $f"; grep -B2 -A10 -i "редвестник" "$f" | M | head -70
done
echo
echo "-- 4. Свежие предвестники в журнале (последние 15) --"
grep -i "редвестник" /root/radar/журнал/*.log 2>/dev/null | tail -15 | M | cut -c1-350
echo
echo "-- 5. Свежие вердикты поля (хвост 12) --"
VF=$(find /root -name "verify-verdicts.jsonl" 2>/dev/null | head -1)
echo "файл: $VF"
tail -12 "$VF" 2>/dev/null | M | cut -c1-350
'
echo "== 1099: конец =="
