#!/bin/bash
# kord-bridge: забирает свежий код с GitHub. Секреты здесь не живут никогда.
cd "$(dirname "$0")/.." || exit 1
git fetch origin || exit 1
git reset --hard origin/main
echo "bridge updated: $(date '+%Y-%m-%d %H:%M:%S')"
