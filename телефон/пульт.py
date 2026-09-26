# -*- coding: utf-8 -*-
# пульт.py — терминальный мост Кординапс → Termux через git-очередь
# Слушает телефон/задания/ в клоне моста, исполняет .sh, вывод в ~/пульт/вывод,
# rsync на сервер в ~/kord-echo/эхо-телефон/ (там его коммитит таймер kord-telefon).

import os
import subprocess
import time

DOM = os.path.expanduser("~/пульт")
MOST = os.path.join(DOM, "мост")
ZAD = os.path.join(MOST, "телефон", "задания")
VYVOD = os.path.join(DOM, "вывод")
JOURNAL = os.path.join(DOM, "выполнено.txt")
SERVER = "root@45.152.198.192"
EHO = "~/kord-echo/эхо-телефон/"


def log(msg):
    print(time.strftime("%Y-%m-%d %H:%M:%S") + " | " + msg, flush=True)


def main():
    os.makedirs(VYVOD, exist_ok=True)
    while True:
        try:
            subprocess.run("git -C " + MOST + " pull --ff-only", shell=True,
                           capture_output=True, text=True, timeout=120)
            if not os.path.isdir(ZAD):
                time.sleep(60)
                continue
            done = set()
            if os.path.exists(JOURNAL):
                with open(JOURNAL, encoding="utf-8") as f:
                    done = set(l.strip() for l in f if l.strip())
            for name in sorted(os.listdir(ZAD)):
                if not name.endswith(".sh") or name in done:
                    continue
                path = os.path.join(ZAD, name)
                log("исполняю: " + name)
                r = subprocess.run(["bash", path], capture_output=True, text=True,
                                   timeout=600, cwd=MOST)
                out = "== ЗАДАНИЕ: " + name + " ==\n" + (r.stdout or "")
                if r.stderr:
                    out = out + "\n--stderr--\n" + r.stderr
                with open(os.path.join(VYVOD, name.replace(".sh", ".txt")), "w", encoding="utf-8") as f:
                    f.write(out)
                with open(JOURNAL, "a", encoding="utf-8") as f:
                    f.write(name + "\n")
                log("готово: " + name + " (код " + str(r.returncode) + ")")
            rs = subprocess.run("rsync -a " + VYVOD + "/ " + SERVER + ":" + EHO,
                                shell=True, capture_output=True, text=True, timeout=180)
            if rs.returncode != 0:
                log("rsync не прошёл: " + (rs.stderr or "")[:200])
        except Exception as e:
            log("ошибка цикла: " + str(e))
        time.sleep(60)


if __name__ == "__main__":
    main()
