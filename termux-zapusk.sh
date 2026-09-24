#!/data/data/com.termux/files/usr/bin/bash
# Кординапс — установка моста на сервер (Termux)
# Запуск: bash termux-zapusk.sh
set -u

HERE="$(cd "$(dirname "$0")" && pwd)"

echo "=== Кординапс: установка моста ==="

command -v git >/dev/null || pkg install -y git
command -v gh  >/dev/null || pkg install -y gh

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
#!/data/data/com.termux/files/usr/bin/bash
while true; do
  bash "$HOME/kord-cikl.sh" >> "$HOME/kord-sluzhba.log" 2>&1
  sleep 180
done
SLUZHBA
chmod +x "$HOME/kord-sluzhba.sh"

command -v termux-wake-lock >/dev/null 2>&1 && termux-wake-lock

pkill -f kord-sluzhba.sh 2>/dev/null
nohup bash "$HOME/kord-sluzhba.sh" >/dev/null 2>&1 &

bash "$HOME/kord-cikl.sh"

echo
echo "=== Готово. Мост установлен, служба работает в фоне. ==="
echo "Возвращайся к Кординапс — он напишет первое задание в очередь."
