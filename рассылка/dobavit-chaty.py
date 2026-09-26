# -*- coding: utf-8 -*-
# dobavit-chaty.py — вступает в чаты из чат-список.txt (аккаунт acc2)
# Формат строк: @имя_чата | https://t.me/имя | https://t.me/+приглашение
# Пустые строки и строки с # игнорируются. Пауза 30 сек между вступлениями.

import asyncio
import json
import os

from telethon import TelegramClient, errors
from telethon.tl.functions.channels import JoinChannelRequest
from telethon.tl.functions.messages import ImportChatInviteRequest

BASE = os.path.dirname(os.path.abspath(__file__))
SESSION = os.path.join(BASE, "sessions", "acc2")
SPISOK = os.path.join(BASE, "чат-список.txt")


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
    raise SystemExit("нет конфига: KORD_API_ID/KORD_API_HASH или конфиг.json рядом со скриптом")


API_ID, API_HASH = load_cfg()
client = TelegramClient(SESSION, API_ID, API_HASH)


async def main():
    await client.connect()
    if not await client.is_user_authorized():
        raise SystemExit("сессия sessions/acc2 не авторизована")
    if not os.path.exists(SPISOK):
        with open(SPISOK, "w", encoding="utf-8") as f:
            f.write("# по одному чату на строку: @имя или https://t.me/+приглашение\n")
        print("создан пустой чат-список.txt — заполни ссылками и запусти снова")
        return
    with open(SPISOK, encoding="utf-8") as f:
        lines = [l.strip() for l in f if l.strip() and not l.strip().startswith("#")]
    if not lines:
        print("чат-список пуст")
        return
    print(f"к вступлению: {len(lines)} чатов")
    ok = 0
    for i, link in enumerate(lines, 1):
        try:
            if "/+/" in link or link.startswith("+"):
                invite = link.split("/+/")[-1].lstrip("+").strip()
                await client(ImportChatInviteRequest(invite))
            else:
                name = link.split("/")[-1].lstrip("@").strip()
                await client(JoinChannelRequest(name))
            ok += 1
            print(f"[{i}/{len(lines)}] вступил: {link}")
        except errors.UserAlreadyParticipantError:
            ok += 1
            print(f"[{i}/{len(lines)}] уже там: {link}")
        except Exception as e:
            print(f"[{i}/{len(lines)}] не вышло: {link} — {e}")
        await asyncio.sleep(30)
    print(f"готово: {ok} из {len(lines)}")


client.loop.run_until_complete(main())
