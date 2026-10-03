#!/data/data/com.termux/files/usr/bin/bash
# Только чтение: карта процессов и исходников шаблонного пульта.
# Не выводим PM2 environment, содержимое .env, токены, конфиги, код, логи или БД.
echo "=== 0016 КАРТА ПУЛЬТА ==="
ssh -o BatchMode=yes -o StrictHostKeyChecking=accept-new -o ConnectTimeout=15 root@45.152.198.192 'bash -s' <<'REMOTE'
echo '--- Живые процессы PM2: только белый список полей ---'
pm2 jlist 2>/dev/null | node -e 'let b="";process.stdin.on("data",x=>b+=x).on("end",()=>{try{for(const p of JSON.parse(b)){const e=p.pm2_env||{};console.log(JSON.stringify({name:p.name,status:e.status,restarts:e.restart_time,script:e.pm_exec_path,cwd:e.pm_cwd}))}}catch(_){console.log("PM2_PARSE_ERROR")}})'
echo '--- Сохранённые процессы PM2: только имя и путь ---'
node -e 'try{for(const p of require("/root/.pm2/dump.pm2")){console.log(JSON.stringify({name:p.name,script:p.pm_exec_path,cwd:p.pm_cwd}))}}catch(_){console.log("DUMP_UNAVAILABLE")}'
echo '--- Исходники /root/template-bot: имена файлов, не содержимое ---'
if [ -d /root/template-bot ]; then find /root/template-bot -maxdepth 3 -type f \( -name '*.js' -o -name '*.json' -o -name '*.md' \) ! -path '*/node_modules/*' ! -name '*env*' -printf '%P\n' | head -60; else echo 'TEMPLATE_DIR_ABSENT'; fi
echo '--- Файлы с командами/кнопками: только пути ---'
if [ -d /root/template-bot ]; then grep -RIlE 'kord_template_bot|bot\.command|Markup|/start' /root/template-bot --include='*.js' --exclude-dir=node_modules 2>/dev/null | head -20; fi
echo '--- Архивный банкротный пример: только наличие каталога ---'
[ -d /root/bankrotstvo-bots ] && echo 'BANKROTSTVO_PRESENT' || echo 'BANKROTSTVO_ABSENT'
REMOTE
echo '=== КОНЕЦ 0016 ==='
