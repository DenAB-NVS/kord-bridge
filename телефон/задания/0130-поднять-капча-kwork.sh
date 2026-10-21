#!/data/data/com.termux/files/usr/bin/bash
echo '=== 0130 КАПЧА+KWORK ЦИКЛЫ ==='
for s in kord-webtunnel-24431.sh kord-webtunnel-24432.sh; do
  if ! pgrep -f "$s" >/dev/null; then
    setsid nohup "$HOME/$s" >/dev/null 2>&1 &
    echo "поднят: $s"
  else
    echo "жив: $s"
  fi
done
sleep 12
echo 'процессов webtunnel: '"$(pgrep -cf kord-webtunnel)"
echo '=== КОНЕЦ 0130 ==='
