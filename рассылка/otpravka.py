#!/usr/bin/env python3
# Кординапс — рассылка горячим лидам: три аккаунта по кругу, паузы, отчёт, прокси, без дублей
# Запуск: python3 otpravka.py [--dry]
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
REPORT = BASE / "отчёт-рассылки.txt"
SESSIONS_DIR = BASE / "sessions"


def load(path, what):
    if not path.exists():
        print(f"НЕТ ФАЙЛА: {path} ({what})")
        sys.exit(1)
    return json.loads(path.read_text(encoding="utf-8"))


def already_sent():
    sent = set()
    if REPORT.exists():
        for line in REPORT.read_text(encoding="utf-8").splitlines():
            parts = [p.strip() for p in line.split("|")]
            if parts and parts[0] == "OK" and len(parts) >= 3:
                sent.add(parts[2])
    return sent


async def main(dry: bool):
    conf = load(CONF, "конфиг, на сервере")
    lids = load(LIDS, "лиды")
    api_id = conf["api_id"]
    api_hash = conf["api_hash"]
    sessions = conf.get("sessions", ["acc1", "acc2", "acc3"])
    pause = conf.get("pause", [240, 600])
    proxy = conf.get("proxy")

    sent = already_sent()
    todo = [l for l in lids if l["контакт"] not in sent]
    print(f"лидов всего: {len(lids)}, уже отправлено: {len(sent)}, осталось: {len(todo)}")

    for i, lid in enumerate(todo):
        s = sessions[i % len(sessions)]
        text = lid["сообщение"]
        stamp = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
        if dry:
            print(f"DRY | {stamp} | {lid['контакт']} | через {s} | {lid['тема']}")
            continue
        try:
            async with TelegramClient(
                str(SESSIONS_DIR / s), api_id, api_hash, proxy=proxy
            ) as client:
                await client.send_message(lid["контакт"], text)
            line = f"OK | {stamp} | {lid['контакт']} | через {s} | {lid['тема']}"
        except Exception as e:
            line = f"ОШИБКА | {stamp} | {lid['контакт']} | {type(e).__name__}: {e}"
        print(line)
        with REPORT.open("a", encoding="utf-8") as f:
            f.write(line + "\n")
        if i < len(todo) - 1:
            wait = random.uniform(*pause)
            print(f"пауза {int(wait)} сек...")
            await asyncio.sleep(wait)
    print("ГОТОВО")


if __name__ == "__main__":
    asyncio.run(main("--dry" in sys.argv))
