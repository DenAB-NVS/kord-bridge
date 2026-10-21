#!/data/data/com.termux/files/usr/bin/bash
echo '=== 0121 ПРОВЕРКА ЦИКЛОВ ==='
pgrep -af 'kord-webtunnel|ssh -N -R.*244' | head -5 || echo 'ЦИКЛЫ МЕРТВЫ'
echo '=== КОНЕЦ 0121 ==='
