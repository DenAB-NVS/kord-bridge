#!/usr/bin/env python3
# Кординапс — пожарный монитор: живой поток чатов -> триггеры -> пожары.txt + Избранное
# Запуск: nohup python3 mon-pozhar.py >> монитор.log 2>&1 &
# Важно: запускать только после завершения рассылки (одна сессия — один процесс)
import asyncio
import json
from datetime import datetime
from pathlib import Path

from telethon import TelegramClient, events

BASE = Path(__file__).resolve().parent
CONF = BASE / "конфиг.json"
OUT = BASE / "пожары.txt"
SESSION = "acc2"  # второй аккаунт слушает поток

conf = json.loads(CONF.read_text(encoding="utf-8"))

TRIGGERS = [
    "лежит бот", "не работает бот", "бот упал", "бот сломался", "бот не отвечает",
    "взломали", "сломался сайт", "упал сайт", "срочно нужен разработчик",
    "нужен программист", "нужен разработчик", "починить бот", "починить телеграм",
    "кабинет заблокир", "бухгалтерия встала", "срочная доработка",
]

client = TelegramClient(
    str(BASE / "sessions" / SESSION),
    conf["api_id"],
    conf["api_hash"],
    proxy=conf.get("proxy"),
)


@client.on(events.NewMessage)
async def on_msg(event):
    text = (event.message.message or "").lower()
    if not text:
        return
    hit = next((t for t in TRIGGERS if t in text), None)
    if not hit:
        return
    try:
        chat = await event.get_chat()
    except Exception:
        chat = None
    who = (
        getattr(chat, "title", None)
        or getattr(chat, "username", None)
        or f"id:{event.chat_id}"
    )
    uname = getattr(chat, "username", None) if chat else None
    link = f"https://t.me/{uname}/{event.message.id}" if uname else ""
    stamp = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
    line = f"{stamp} | {hit} | {who} | {link} | {text[:200]}"
    with OUT.open("a", encoding="utf-8") as f:
        f.write(line + "\n---\n")
    try:
        await client.send_message("me", f"🔥 {hit}\n{who}\n{link}\n{text[:300]}")
    except Exception:
        pass


async def main():
    print("монитор пожарного потока запущен, сессия:", SESSION)
    print("триггеров:", len(TRIGGERS))
    await client.run_until_disconnected()


if __name__ == "__main__":
    asyncio.run(main())
