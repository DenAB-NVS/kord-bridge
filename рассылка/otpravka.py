#!/usr/bin/env python3
# Кординапс — рассылка горячим лидам: три аккаунта по кругу, паузы, отчёт
# Запуск: python3 otpravka.py [--dry]   (--dry — прогон без отправки)
import asyncio
import json
import random
import sys
from datetime import datetime
from pathlib import Path

from telethon import TelegramClient

BASE = Path(__file__).resolve().parent
CONF = BASE / "конфиг.json"
LIDS = BASE / "лиды.json"
SESSIONS_DIR = BASE / "sessions"


def load(path, what):
    if not path.exists():
        print(f"НЕТ ФАЙЛА: {path} ({what})")
        sys.exit(1)
    return json.loads(path.read_text(encoding="utf-8"))


async def main(dry: bool):
    conf = load(CONF, "конфиг, создаётся на сервере, в репо не кладётся")
    lids = load(LIDS, "лиды")
    api_id = conf["api_id"]
    api_hash = conf["api_hash"]
    sessions = conf.get("sessions", ["acc1", "acc2", "acc3"])
    pause = conf.get("pause", [240, 600])

    log = []
    for i, lid in enumerate(lids):
        s = sessions[i % len(sessions)]
        text = lid["сообщение"]
        stamp = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
        if dry:
            line = f"DRY | {stamp} | {lid['контакт']} | через {s} | {lid['тема']}"
            print(line)
            log.append(line)
            continue
        try:
            async with TelegramClient(
                str(SESSIONS_DIR / s), api_id, api_hash
            ) as client:
                await client.send_message(lid["контакт"], text)
            line = f"OK | {stamp} | {lid['контакт']} | через {s} | {lid['тема']}"
        except Exception as e:
            line = f"ОШИБКА | {stamp} | {lid['контакт']} | {type(e).__name__}: {e}"
        print(line)
        log.append(line)
        (BASE / "отчёт-рассылки.txt").write_text(
            "\n".join(log), encoding="utf-8"
        )
        if i < len(lids) - 1:
            wait = random.uniform(*pause)
            print(f"пауза {int(wait)} сек...")
            await asyncio.sleep(wait)

    (BASE / "отчёт-рассылки.txt").write_text("\n".join(log), encoding="utf-8")
    print(f"ГОТОВО: {len(log)} лидов, отчёт: отчёт-рассылки.txt")


if __name__ == "__main__":
    asyncio.run(main("--dry" in sys.argv))
