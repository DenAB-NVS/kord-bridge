#!/usr/bin/env bash
# Кординапс — установка моста на VPS (Ubuntu, root)
# Запуск: bash vps-zapusk.sh
set -u

HERE="$(cd "$(dirname "$0")" && pwd)"

echo "=== Кординапс: установка моста на сервер ==="

command -v git >/dev/null || apt-get update -y && apt-get install -y git
command -v gh  >/dev/null || apt-get install -y gh

if gh auth status >/dev/null 2>&1; then
  echo "GitHub уже авторизован."
else
  echo
  echo "Вставь токен нового аккаунта (KordinapsArhanHome) и нажми Enter:"
  read -r TOKEN
  echo "$TOKEN" | gh auth login --with-token
fi

LOGIN="$(gh api user -q .login 2>/dev/null || echo KordinapsArhanHome)"
echo "Работаем под: $LOGIN"

git config --global user.name  "$LOGIN"
git config --global user.email "$LOGIN@users.noreply.github.com"

if ! gh repo view "$LOGIN/kord-echo" >/dev/null 2>&1; then
  gh repo create kord-echo --public --description "Эхо моста Кординапс: обратная связь сервера. Только результаты, без секретов."
  echo "Эхо-репозиторий создан."
fi

if [ ! -d "$HOME/kord-echo" ]; then
  gh repo clone "$LOGIN/kord-echo" "$HOME/kord-echo"
fi

mkdir -p "$HOME/kord-echo/эхо"

cp "$HERE/kord-cikl.sh" "$HOME/kord-cikl.sh"
chmod +x "$HOME/kord-cikl.sh"

cat > "$HOME/kord-sluzhba.sh" <<'SLUZHBA'
#!/usr/bin/env bash
# Кординапс — служба цикла: очередь -> исполнение -> эхо
while true; do
  bash "$HOME/kord-cikl.sh" >> "$HOME/kord-sluzhba.log" 2>&1
  sleep 180
done
SLUZHBA
chmod +x "$HOME/kord-sluzhba.sh"

# systemd: мост переживает ребут
if command -v systemctl >/dev/null 2>&1; then
  cat > /etc/systemd/system/kord-myst.service <<UNIT
[Unit]
Description=Кординапс — мост и цикл (очередь -> эхо)
After=network-online.target
Wants=network-online.target

[Service]
Type=simple
ExecStart=/bin/bash $HOME/kord-sluzhba.sh
Restart=always
RestartSec=60
WorkingDirectory=$HOME

[Install]
WantedBy=multi-user.target
UNIT
  systemctl daemon-reload
  systemctl enable --now kord-myst.service
  echo "Служба systemd установлена и запущена (переживает ребут)."
else
  pkill -f kord-sluzhba.sh 2>/dev/null
  nohup bash "$HOME/kord-sluzhba.sh" >/dev/null 2>&1 &
fi

bash "$HOME/kord-cikl.sh"

echo
echo "=== Готово. Мост установлен, служба работает. ==="
echo "Возвращайся к Кординапс — он проверит эхо."
