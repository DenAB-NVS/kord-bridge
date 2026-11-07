#!/data/data/com.termux/files/usr/bin/bash
# 1097 — usernames: автор поста 75205 + кандидаты И-К37Р-392…408. В эхо, телефоны замаскированы.
echo "== 1097: usernames =="
ssh -o BatchMode=yes -o ConnectTimeout=25 root@45.152.198.192 '
M() { sed -E "s/[0-9+][0-9 -]{9,}/[ТЕЛЕФОН]/g"; }
echo "-- 1. Досье 75205 --"
for f in $(grep -rln "75205" /root/kord-glubina/ /root/.hermes/cache/scratch/ 2>/dev/null | grep -v "\.bak" | grep -v "reestr-live" | head -3); do
  echo "### $f"; grep -B2 -A10 "75205" "$f" | M | head -50
done
echo "-- 2. Заголовки всех блоков кандидатов (с датами) --"
grep -n "### И-К37Р-" /root/kord-glubina/reestr-live.md | M | tail -25
echo "-- 3. Поля кандидатов И-К37Р-392…408 --"
sed -n "/И-К37Р-392/,/И-К37Р-409/p" /root/kord-glubina/reestr-live.md | grep -iE "username|юзер|автор|чат|пост|залог|млн|тыс|дол[яи]|квартир" | M | head -70
'
echo "== 1097: конец =="
