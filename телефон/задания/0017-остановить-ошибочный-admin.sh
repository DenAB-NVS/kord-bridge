#!/data/data/com.termux/files/usr/bin/bash
# Исправление ошибки 0015: удалить только PM2 admin-bot из устаревшего банкротного примера.
# Не удалять файлы, БД и другие процессы. Отменить действие, если путь изменился.
set -e
echo '=== 0017 ОСТАНОВКА ОШИБОЧНОГО ADMIN ==='
ssh -o BatchMode=yes -o StrictHostKeyChecking=accept-new -o ConnectTimeout=15 root@45.152.198.192 'bash -s' <<'REMOTE'
set -e
pm2 jlist 2>/dev/null | node -e 'let b="";process.stdin.on("data",x=>b+=x).on("end",()=>{let a;try{a=JSON.parse(b)}catch(_){process.exit(3)}const p=a.find(x=>x.name==="admin-bot");if(!p){console.log("ADMIN_ALREADY_ABSENT");process.exit(4)}if(p.pm2_env?.pm_exec_path!=="/root/bankrotstvo-bots/admin.js"){console.log("ABORT_WRONG_PATH");process.exit(5)}console.log("VERIFIED_OLD_ADMIN_ONLY")})'
pm2 delete admin-bot >/dev/null
pm2 save >/dev/null
echo 'REMOVED_OLD_ADMIN_AND_SAVED'
pm2 jlist 2>/dev/null | node -e 'let b="";process.stdin.on("data",x=>b+=x).on("end",()=>{try{for(const p of JSON.parse(b)){console.log(JSON.stringify({name:p.name,status:p.pm2_env?.status,script:p.pm2_env?.pm_exec_path}))}}catch(_){console.log("PM2_PARSE_ERROR")}})'
REMOTE
echo '=== КОНЕЦ 0017 ==='
