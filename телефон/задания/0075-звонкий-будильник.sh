#!/data/data/com.termux/files/usr/bin/bash
# Задание 0075 — ЗВОНКИЙ БУДИЛЬНИК: пакет termux-api (ночь 06→07.10)
# Ставит пакет termux-api (приложение Termux:API уже стоит по ВОССТАНОВЛЕНИЮ-МОСТА v2.1) и проверяет уведомление.
# Ничего не удаляет. Откат по слову владельца: pkg uninstall termux-api

echo "== 0075: звонкий будильник =="

echo "-- до установки --"
command -v termux-notification >/dev/null 2>&1 && echo "уже есть — пропуск установки" || echo "нет — ставим"

if ! command -v termux-notification >/dev/null 2>&1; then
  echo "-- установка termux-api (может занять до минуты) --"
  pkg install -y termux-api 2>&1 | tail -5
fi

echo "-- после установки --"
command -v termux-notification >/dev/null 2>&1 && echo "termux-notification: ЕСТЬ" || echo "termux-notification: ПО-ПРЕЖНЕМУ НЕТ"

echo "-- тест будильника (уведомление на экран телефона) --"
termux-notification --title "СТОРОЖ ВЕНЫ" --content "Тест: будильник звонкий — Кординапс" 2>&1 && echo "уведомление отправлено" || echo "не отправилось — вероятно, не хватает приложения Termux:API (F-Droid)"
echo "== 0075: конец =="
