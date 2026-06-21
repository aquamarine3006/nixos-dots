#!/usr/bin/env bash
set -euo pipefail

export PATH="/run/current-system/sw/bin:/etc/profiles/per-user/$USER/bin:$HOME/.local/state/nix-profiles/profile/bin:$HOME/.nix-profile/bin:$PATH"

LOGFILE="/tmp/wallpaper-sh.log"
exec > "$LOGFILE" 2>&1

WALL="${1:?Usage: wallpaper.sh <path> [dark|light]}"
MODE="${2:-dark}"

echo "Starting wallpaper.sh"
echo "Path: $WALL"
echo "Mode: $MODE"

[ -f "$WALL" ] || { echo "File not found"; exit 1; }

echo "Running awww..."
awww img "$WALL" --transition-type grow --transition-pos 0.5,0.5 --transition-duration 1.5 --transition-fps 60

echo "Running matugen..."
matugen image "$WALL" --mode "$MODE" --color source < /dev/null

echo "Reloading hyprland..."
hyprctl reload

echo "Notifying kitty..."
pkill -SIGUSR1 kitty 2>/dev/null || true

echo "Updating gsettings..."
if [ "$MODE" = "dark" ]; then
  gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark'
  gsettings set org.gnome.desktop.interface gtk-theme 'adw-gtk3-dark'
else
  gsettings set org.gnome.desktop.interface color-scheme 'default'
  gsettings set org.gnome.desktop.interface gtk-theme 'adw-gtk3'
fi

echo "Notifying Quickshell..."
qs ipc call pill reloadColors 2>/dev/null || true

CACHE="${XDG_CACHE_HOME:-$HOME/.cache}"
mkdir -p "$CACHE"
echo "$WALL" > "$CACHE/current-wallpaper"
echo "$MODE" > "$CACHE/current-theme-mode"

echo "Done!"
