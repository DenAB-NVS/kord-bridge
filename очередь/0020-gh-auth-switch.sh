#!/usr/bin/env bash
# 0020: gh — вернуть активной учётку моста KordinapsArhanHome.
# Причина: 05.10 в gh на сервере вошёл токен DenAB-NVS и стал активным,
# а мост и эхо пушат под KordinapsArhanHome. Обе учётки остаются в gh.

echo "=== gh auth switch -> KordinapsArhanHome ==="
gh auth switch --user KordinapsArhanHome && echo "SWITCH OK"
echo
echo "=== gh auth status ==="
gh auth status
echo
echo "=== проверка пуша эха (dry-run, ничего не меняет) ==="
if [ -d "$HOME/kord-echo/.git" ]; then
  cd "$HOME/kord-echo" || exit 0
  git pull --rebase >/dev/null 2>&1
  git push --dry-run 2>&1
else
  echo "~/kord-echo не найден"
fi
