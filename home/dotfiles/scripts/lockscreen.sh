#!/usr/bin/env bash
set -euo pipefail
exec kitty --title lockscreen-test bash -c 'echo "LOCKED — press Enter to unlock"; read _'
