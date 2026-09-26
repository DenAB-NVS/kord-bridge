# -*- coding: utf-8 -*-
# mon-pozhar.py v5.1 — пожарный монитор: два яруса слов + фильтр шума
# v5: убийца шума. v5.1: +риэлторы, водители, заработки на отзывах и картах.

import asyncio
import json
import os
import time

from telethon import TelegramClient, events

BASE = os.path.dirname(os.path.abspath(__file__))
SESSION = os.path.join(BASE, "sessions", "acc2")
LOG = os.path.join(BASE, "пожары.txt")
SPROS = os.path.join(BASE, "спрос.txt")

# Ярус 1 — пожары: тревога в Избранное + пожары.txt
FIRE = [
    "срочно нужен", "нужен разработчик", "нужен программист", "нужен бот",
    "ищем разработчика", "ищу исполнителя", "кто может написать", "кто сделает",
    "кто возьмется", "сломался бот", "упал бот", "не работает бот",
    "нужно починить", "восстановить бота", "горит дедлайн",
    "сегодня до", "до конца дня", "аварийн", "спасайте",
]

# Ярус 2 — спрос: тихо в спрос.txt
WORK = [
    "нужен техспец", "требуется разработчик", "заказ на разработку",
    "напишите в лс", "есть задача", "есть тз", "бюджет",
    "разработать бот", "чат-бот", "интеграц", "парсер", "автоматизир",
]

# Фильтр шума: если совпало — молча пропускаем
NOISE = [
    "#помогу", "#резюме", "#ищу_работу", "купл", "баланс",
    "набор на удал", "за отзыв", "верификац", "казино", "ставки на спор",
    "риэлтор", "водител", "яндекс.карт", "заработок на", "документ",
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
prefixes = set()


def ts():
    return time.strftime("%Y-%m-%d %H:%M:%S")


@client.on(events.NewMessage(incoming=True))
async def on_msg(event):
    try:
        text = (event.raw_text or "").lower()
        if not text:
            return
        sender = await event.get_sender()
        uname = getattr(sender, "username", None)
        if uname and "bot" in uname.lower():
            return
        if text.count("#") >= 3:
            return
        if any(n in text for n in NOISE):
            return
        pref = text[:60]
        if pref in prefixes:
            return
        fire = next((t for t in FIRE if t in text), None)
        work = None if fire else next((t for t in WORK if t in text), None)
        if fire is None and work is None:
            return
        chat = await event.get_chat()
        key = (getattr(chat, "id", None), event.id)
        if key in seen:
            return
        seen.add(key)
        if len(seen) > 500:
            seen.clear()
        prefixes.add(pref)
        if len(prefixes) > 2000:
            prefixes.clear()
        chat_name = getattr(chat, "title", None) or getattr(chat, "username", None) or str(key[0])
        who = f"@{uname}" if uname else (getattr(sender, "first_name", "") or "?")
        snippet = (event.raw_text or "")[:200].replace("\n", " ")
        if fire:
            line = f"{ts()} | ПОЖАР | {chat_name} | {who} | триггер: {fire} | {snippet}\n"
            with open(LOG, "a", encoding="utf-8") as f:
                f.write(line)
            try:
                await client.send_message("me", f"🔥 ПОЖАР\n{chat_name} | {who}\n{snippet}")
            except Exception as e:
                print(f"{ts()} | оповещение в Избранное не ушло: {e}", flush=True)
            print(line, end="", flush=True)
        else:
            line = f"{ts()} | спрос | {chat_name} | {who} | триггер: {work} | {snippet}\n"
            with open(SPROS, "a", encoding="utf-8") as f:
                f.write(line)
            print(line, end="", flush=True)
    except Exception as e:
        print(f"{ts()} | ошибка обработчика: {e}", flush=True)


async def main():
    await client.connect()
    if not await client.is_user_authorized():
        raise SystemExit("сессия sessions/acc2 не авторизована — проверь путь к сессии")
    print(f"{ts()} | монитор v5.1 запущен, сессия: acc2 (sessions/), фильтр шума: {len(NOISE)} шаблонов", flush=True)
    try:
        await client.send_message("me", f"🔥 монитор v5.1 на посту ({time.strftime('%d.%m %H:%M')})")
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
