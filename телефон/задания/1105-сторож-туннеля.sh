#!/data/data/com.termux/files/usr/bin/bash
# 1105 — постоянный сторож MTProto-туннеля (паттерн 0114) на телефоне + чтение avtozalogrf.
echo "== 1105: сторож + чтение =="
W="$HOME/kord-mtproto-storozh.sh"
echo "IyEvZGF0YS9kYXRhL2NvbS50ZXJtdXgvZmlsZXMvdXNyL2Jpbi9iYXNoCiMga29yZC1tdHByb3RvLXN0b3Jvemguc2ggLSDRgdGC0L7RgNC+0LYgTVRQcm90by3RgtGD0L3QvdC10LvRjyAo0L/QsNGC0YLQtdGA0L0gMDExNCk6INGG0LjQutC7IDMwINGBLCDRg9C80LXRgCAtINC/0L7QtNC90LjQvNCw0LXRgi4KIyDQodC90Y/RgtC40LU6IHRvdWNoIC9yb290L2tvcmQtbGluemEv0KHQotCe0J8t0KLQo9Cd0J3QndCV0JvQrCAmJiBlY2hvIHllcyB8fCBlY2hvIG5vJyAyPi9kZXYvbnVsbCkKICBpZiBbICIkU1RPUCIgPSAieWVzIiBdOyB0aGVuCiAgICBwa2lsbCAtZiAnMTI3LjAuMC4xOjE3NDQzJyAyPi9kZXYvbnVsbAogICAgc2xlZXAgMzAKICAgIGNvbnRpbnVlCiAgZmkKICBBTElWRT0kKHNzaCAkTyAiJFNSViIgInNzIC10bG4gfCBncmVwIC1jICc6MTc0NDMgJyIgMj4vZGV2L251bGwpCiAgaWYgWyAiJHtBTElWRTotMH0iIC1sdCAxIF07IHRoZW4KICAgIE1FVEE9JChzc2ggJE8gIiRTUlYiICdweXRob24zIC0gMj4vZGV2L251bGwnIDw8J1BZJwppbXBvcnQgc3FsaXRlMwp0cnk6CiAgICBjID0gc3FsaXRlMy5jb25uZWN0KCdmaWxlOi9yb290L9GA0LDRgdGB0YvQu9C60LAvc2Vzc2lvbnMvYWNjMS5zZXNzaW9uP21vZGU9cm8nLCB1cmk9VHJ1ZSkKICAgIHJvdyA9IGMuZXhlY3V0ZSgnc2VsZWN0IHNlcnZlcl9hZGRyZXNzLCBwb3J0IGZyb20gc2Vzc2lvbnMgbGltaXQgMScpLmZldGNob25lKCkKICAgIGMuY2xvc2UoKQogICAgaWYgcm93OiBwcmludChyb3dbMF0sIHJvd1sxXSkKZXhjZXB0IEV4Y2VwdGlvbjogcGFzcwpQWQopCiAgICByZWFkIC1yIEhPU1QgUE9SVCA8PDwgIiRNRVRBIgogICAgY2FzZSAiJEhPU1Q6JFBPUlQiIGluICpbITAtOS46XSopIHNsZWVwIDMwOyBjb250aW51ZTs7IGVzYWMKICAgIHBraWxsIC1mICcxMjcuMC4wLjE6MTc0NDMnIDI+L2Rldi9udWxsCiAgICBzbGVlcCAxCiAgICBzZXRzaWQgbm9odXAgc3NoIC1OIC1SICIxMjcuMC4wLjE6MTc0NDM6JEhPU1Q6JFBPUlQiIFwKICAgICAgLW8gQmF0Y2hNb2RlPXllcyAtbyBFeGl0T25Gb3J3YXJkRmFpbHVyZT15ZXMgLW8gU3RyaWN0SG9zdEtleUNoZWNraW5nPWFjY2VwdC1uZXcgXAogICAgICAtbyBDb25uZWN0VGltZW91dD0xNSAtbyBTZXJ2ZXJBbGl2ZUludGVydmFsPTE1IC1vIFNlcnZlckFsaXZlQ291bnRNYXg9MyBcCiAgICAgICIkU1JWIiA+L2Rldi9udWxsIDI+JjEgJgogIGZpCiAgc2xlZXAgMzAKZG9uZQo=" | base64 -d > "$W"
chmod +x "$W"
if pgrep -f 'kord-mtproto-storozh.sh' >/dev/null 2>&1; then
  echo "сторож уже жив"
else
  setsid nohup bash "$W" >/dev/null 2>&1 &
  echo "сторож запущен"
fi
sleep 40
SRV="root@45.152.198.192"
O="-o BatchMode=yes -o StrictHostKeyChecking=accept-new -o ConnectTimeout=15"
CHK=$(ssh $O "$SRV" "ss -tln | grep ':17443 ' | head -1")
echo "слушатель: ${CHK:-НЕТ}"
echo "-- чтение avtozalogrf --"
ssh $O "$SRV" 'timeout 120 /root/kord-linza/venv/bin/python /root/kord-glubina/read-one-r1104.py 2>&1 | tail -90'
echo "-- пуш в дом --"
ssh $O "$SRV" 'cd /root/kord-glubina/kordinaps-machine && git add "проекты/ЧТЕНИЕ-avtozalogrf-2026-11-07.md" 2>/dev/null; git commit -q -m "ЧТЕНИЕ avtozalogrf 07.11 (по слову владельца)" 2>/dev/null; git push -q origin HEAD:main 2>&1 | tail -1; echo "пуш выполнен"'
echo "== 1105: конец =="
