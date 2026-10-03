#!/data/data/com.termux/files/usr/bin/bash
# Только чтение. Выводим лишь синтаксис, имена файлов и признаки пульта; исходники, токены и логи не печатаем.
echo '=== 0018 ОСМОТР TEMPLATE PULT ==='
ssh -o BatchMode=yes -o StrictHostKeyChecking=accept-new -o ConnectTimeout=15 root@45.152.198.192 'bash -s' <<'REMOTE'
cd /root/template-bot || exit 2
for f in src/index.js src/admin.js src/pult_users.js src/texts.js src/hub.js src/launcher.js; do
  if [ -f "$f" ]; then
    if node --check "$f" >/dev/null 2>&1; then echo "SYNTAX_OK $f"; else echo "SYNTAX_FAIL $f"; fi
  else echo "ABSENT $f"; fi
done
node <<'JS'
const fs=require('fs');
for(const f of ['src/index.js','src/admin.js','src/pult_users.js','src/texts.js','src/hub.js']){
 try {const s=fs.readFileSync(f,'utf8');console.log(JSON.stringify({file:f,lines:s.split('\n').length,buttons:/Markup|inline_keyboard|reply_markup|callback_query/.test(s),start:/\bstart\b/.test(s),access_control:/adminIds|ADMIN_IDS|isAdmin|ownerId|OWNER_ID/.test(s),pult_users:/pult_users/.test(s),commands:/\.command\(|bot\.on\(/.test(s)}))}
 catch(_) {console.log(JSON.stringify({file:f,status:'UNREADABLE'}))}
}
JS
pm2 jlist 2>/dev/null | node -e 'let b="";process.stdin.on("data",x=>b+=x).on("end",()=>{try{const p=JSON.parse(b).find(x=>x.name==="template-bot");if(!p){console.log("TEMPLATE_PM2_ABSENT");return}const e=p.pm2_env||{};console.log(JSON.stringify({name:p.name,status:e.status,restarts:e.restart_time,args_reference_template:JSON.stringify(e.args||[]).includes("template-bot")}))}catch(_){console.log("PM2_PARSE_ERROR")}})'
REMOTE
echo '=== КОНЕЦ 0018 ==='
