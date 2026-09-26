#!/data/data/com.termux/files/usr/bin/bash
# 0004: ВЕЧНЫЙ БУДИЛЬНИК РУКИ
# Урок верховного сподвижника, 26.09: рука сама держит себя бодрой,
# а не просит человека. Android не должен убивать пульт и дозор.

termux-wake-lock 2>/dev/null && echo "будильник включён $(date +%d.%m_%H:%M)" || echo "wake-lock недоступен — проверить termux-api"
