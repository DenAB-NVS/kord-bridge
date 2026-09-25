# -*- coding: utf-8 -*-
# mon-pozhar.py v3 — пожарный монитор потока чатов (acc2)
# v2: вечное кольцо переподключения. v3: сессия берётся из sessions/, как у отправщика.

import asyncio
import json
import os
import time

from telethon import TelegramClient, events

BASE = os.path.dirname(os.path.abspath(__file__))
SESSION = os.path.join(BASE, "sessions", "acc2")
LOG = os.path.join(BASE, "пожары.txt")

# 16 триггеров пожарного спроса (в нижнем регистре, поиск по подстроке)
TRIGGERS = [
    "срочно", "горит", "пожар", "аврал",
    "не работает", "сломал", "упал бот", "упал сервер",
    "ошибка в", "баг", "критичн", "дедлайн",
    "как можно скорее", "нужно до конца дня", "спасайте", "ищем разработчика",
]


def load_cfg():
    env = os.environ
    if env.get("KORD_API_ID") and env.get("KORD_API_HASH"):
        return int(env["KORD_API_ID"]), env["KORD_API_HASH"]
    for name in ("конфиг.json", "config.json", "kord-config.json"):
        for d in (BASE, os.path.expanduser("~")):
            p = os.path.join(d, name)
            if os.path.exists(p):
                with open(p, encoding="utf-8") as f:
                    c = json.load(f)
                if "api_id" in c and "api_hash" in c:
                    return int(c["api_id"]), c["api_hash"]
    raise SystemExit("нет конфига: KORD_API_ID/KORD_API_HASH или конфиг.json рядом с монитором")


API_ID, API_HASH = load_cfg()
client = TelegramClient(SESSION, API_ID, API_HASH)
seen = set()


def ts():
    return time.strftime("%Y-%m-%d %H:%M:%S")


@client.on(events.NewMessage(incoming=True))
async def on_msg(event):
    try:
        text = (event.raw_text or "").lower()
        if not text:
            return
        hit = next((t for t in TRIGGERS if t in text), None)
        if hit is None:
            return
        chat = await event.get_chat()
        sender = await event.get_sender()
        key = (getattr(chat, "id", None), event.id)
        if key in seen:
            return
        seen.add(key)
        if len(seen) > 500:
            seen.clear()
        chat_name = getattr(chat, "title", None) or getattr(chat, "username", None) or str(key[0])
        uname = getattr(sender, "username", None)
        who = f"@{uname}" if uname else (getattr(sender, "first_name", "") or "?")
        snippet = (event.raw_text or "")[:200].replace("\n", " ")
        line = f"{ts()} | {chat_name} | {who} | триггер: {hit} | {snippet}\n"
        with open(LOG, "a", encoding="utf-8") as f:
            f.write(line)
        try:
            await client.send_message("me", f"🔥 ПОЖАР\n{chat_name} | {who}\n{snippet}")
        except Exception as e:
            print(f"{ts()} | оповещение в Избранное не ушло: {e}", flush=True)
        print(line, end="", flush=True)
    except Exception as e:
        print(f"{ts()} | ошибка обработчика: {e}", flush=True)


async def main():
    await client.connect()
    if not await client.is_user_authorized():
        raise SystemExit("сессия sessions/acc2 не авторизована — проверь путь к сессии")
    print(f"{ts()} | монитор пожарного потока запущен, сессия: acc2 (sessions/)", flush=True)
    try:
        await client.send_message("me", f"🔥 монитор на посту, сессия: acc2, {time.strftime('%d.%m %H:%M')}")
    except Exception:
        pass
    await client.run_until_disconnected()


while True:
    try:
        client.loop.run_until_complete(main())
        print(f"{ts()} | соединение закрыто, поднимаю через 30 сек", flush=True)
    except KeyboardInterrupt:
        print(f"{ts()} | остановлен вручную", flush=True)
        break
    except Exception as e:
        print(f"{ts()} | разрыв: {e}; переподключение через 30 сек", flush=True)
    time.sleep(30)
