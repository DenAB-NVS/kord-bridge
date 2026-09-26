#!/bin/bash
# 0001: проверка петли — первое слово пульта
uname -a
date
echo "ПУЛЬТ ЖИВ: терминальный мост Кординапс -> Termux работает"
ls ~/рассылка | head -12
pgrep -f mon-pozhar.py >/dev/null && echo "монитор: на посту" || echo "монитор: НЕ ВИЖУ"
