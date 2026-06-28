#!/usr/bin/env bash
set -euo pipefail
export PATH="/run/current-system/sw/bin:/etc/profiles/per-user/$USER/bin:$HOME/.local/state/nix-profiles/profile/bin:$HOME/.nix-profile/bin:$PATH"

WALL="${1:?Usage: wallpaper.sh <path>}"
LOGFILE="/tmp/wallpaper-sh.log"
exec > "$LOGFILE" 2>&1

t() { echo "[$(date +%s.%N)] $*"; }

t "start"
LUMINANCE=$(magick "$WALL" -colorspace Gray -format "%[fx:mean*100]" info:)
MODE=$(awk "BEGIN{print ($LUMINANCE+0 > 55) ? \"light\" : \"dark\"}")
t "luminance done: $LUMINANCE → $MODE"

script -q -c "matugen -t scheme-content --contrast 0.5 image \"$WALL\" --mode \"$MODE\" --source-color-index 0" /dev/null
t "matugen done"

wallust run -s "$WALL"
pkill -SIGUSR1 kitty 2>/dev/null || true
t "wallust done"

awww img "$WALL" \
  --transition-type grow \
  --transition-pos 0.5,0.5 \
  --transition-duration 1.5 \
  --transition-fps 60
t "awww done"

hyprctl reload
t "hyprctl done"

CACHE="${XDG_CACHE_HOME:-$HOME/.cache}"
mkdir -p "$CACHE"
echo "$WALL" > "$CACHE/current-wallpaper"
echo "$MODE"  > "$CACHE/current-theme-mode"

echo "Wall: $WALL  Mode: $MODE  Luminance: $LUMINANCE"
echo "Done!"
