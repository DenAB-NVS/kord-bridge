#!/usr/bin/env bash
set -e
export GIT_TERMINAL_PROMPT=0
cd "$(dirname "$0")/.."
TOKEN=$(openssl rand -hex 16 2>/dev/null || head -c 32 /dev/urandom | od -An -tx1 | tr -d ' \n')
echo "$TOKEN" > bridge/.status-token
mkdir -p "статус/$TOKEN" очередь .worker
grep -q '^статус/' .git/info/exclude 2>/dev/null || echo 'статус/' >> .git/info/exclude
grep -q '^\.worker/' .git/info/exclude 2>/dev/null || echo '.worker/' >> .git/info/exclude
if ! pgrep -f 'http.server 8777' >/dev/null 2>&1; then
  if command -v python3 >/dev/null; then
    nohup python3 -m http.server 8777 --directory "$PWD/статус" >/dev/null 2>&1 &
  else
    nohup node -e 'const h=require("http"),f=require("fs");h.createServer((q,s)=>{f.readFile("статус"+decodeURIComponent(q.url),(e,d)=>{if(e){s.writeHead(404);s.end("нет")}else{s.end(d)}})}).listen(8777)' >/dev/null 2>&1 &
  fi
fi
pm2 delete kord-worker >/dev/null 2>&1 || true
pm2 start bridge/worker.sh --name kord-worker
pm2 save
IP=$(curl -s --max-time 5 ifconfig.me || hostname -I | awk '{print $1}')
sleep 1
echo "=============================================="
echo "СТАТУС_URL: http://$IP:8777/$TOKEN/ЖУРНАЛ.md"
echo "Покажи эту строку Perplexity — петля замкнётся"
echo "=============================================="
