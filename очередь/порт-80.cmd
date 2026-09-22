if ! pgrep -f 'http.server 80' >/dev/null 2>&1; then
  if command -v python3 >/dev/null; then
    nohup python3 -m http.server 80 --directory /root/kord-bridge/статус >/dev/null 2>&1 &
  else
    nohup node -e 'const h=require("http"),f=require("fs");h.createServer((q,s)=>{f.readFile("/root/kord-bridge/статус"+decodeURIComponent(q.url),(e,d)=>{if(e){s.writeHead(404);s.end("нет")}else{s.end(d)}})}).listen(80)' >/dev/null 2>&1 &
  fi
fi
sleep 1
ss -tln 2>/dev/null | grep -E ':80 |:8777 ' || echo "порты не видны в ss"
curl -s -o /dev/null -w 'локально порт 80: HTTP %{http_code}\n' "http://127.0.0.1/5b0378e7bc40c6fa405b18eb1c7fd095/ЖУРНАЛ.md"
echo "--- ЖУРНАЛ (хвост) ---"
tail -30 "/root/kord-bridge/статус/5b0378e7bc40c6fa405b18eb1c7fd095/ЖУРНАЛ.md" 2>/dev/null || echo "журнала пока нет"
