#!/data/data/com.termux/files/usr/bin/bash
# Точечная правка приватного дома. Ничего не менять, если рабочая копия/строка/SHA не совпадают.
set -e
ssh -o BatchMode=yes -o StrictHostKeyChecking=accept-new -o ConnectTimeout=15 root@45.152.198.192 'bash -s' <<'REMOTE'
set -euo pipefail
cd /root/kordinaps-machine
file='проекты/ПОЛКА-РЕШЕНИЙ.md'
[ "$(git branch --show-current)" = 'main' ] || { echo 'ABORT_BRANCH'; exit 2; }
[ -z "$(git status --porcelain)" ] || { echo 'ABORT_DIRTY'; exit 3; }
git remote get-url origin | grep -q 'DenAB-NVS/kordinaps-machine' || { echo 'ABORT_REMOTE'; exit 4; }
remote_sha=$(git ls-remote origin refs/heads/main | cut -f1)
[ -n "$remote_sha" ] && [ "$(git rev-parse HEAD)" = "$remote_sha" ] || { echo 'ABORT_OUTDATED'; exit 5; }
[ "$(git hash-object "$file")" = '074f1161398942f966ac4756ece2a16fe7bdc10a' ] || { echo 'ABORT_FILE_SHA'; exit 6; }
python3 - <<'PY'
from pathlib import Path
p=Path('проекты/ПОЛКА-РЕШЕНИЙ.md')
s=p.read_text()
old='| PM2-процессы: leadgen, shtraf, legal, admin | Уже работающие боты на сервере | admin — готовая основа «пульта-кнопки» из контуров (не строить с нуля, а посмотреть, что уже есть) | проверить живость |'
new='| Пульт `@kord_template_bot`: `/root/template-bot/src/admin.js`, `src/pult_users.js` | Настоящий кнопочный контур; синтаксис проверен 04.10, процесс `template-bot` был online без рестартов | Проверить живые кнопки и ограничения доступа, не подменять проверку статусом PM2 | расположение подтверждено, функции ещё не приняты |\n| PM2: leadgen-bot, shtraf-bot, legal-bots, template-bot | Снимок 04.10: процессы online, 0 рестартов на момент осмотра | Проверять по логам и тестам, не считать online доказательством работы | исторический снимок |\n| `/root/bankrotstvo-bots/admin.js` | Устаревший пример, ошибочно запущенный как `admin-bot` заданием 0015; удалён из PM2 заданием 0017 и сохранён новый список | Не использовать как пульт; файлы и базу не удалять без проверки зависимостей | архивный кандидат |'
if s.count(old)!=1: raise SystemExit('ABORT_OLD_ROW_NOT_UNIQUE')
p.write_text(s.replace(old,new))
PY
git diff --check
git add -- "$file"
git -c user.name='Kord Bridge' -c user.email='kord-bridge@users.noreply.github.com' commit -m 'Полка 7: настоящий пульт template-bot, старый admin в архив' >/dev/null
if git push origin main >/dev/null 2>&1; then echo "POLKA7_PUSHED $(git rev-parse --short HEAD)"; else echo 'PUSH_FAILED_LOCAL_COMMIT_REMAINS'; exit 7; fi
REMOTE
