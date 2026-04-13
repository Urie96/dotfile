#!/usr/bin/env bash -l

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title Generate QR Code
# @raycast.mode silent

# Optional parameters:
# @raycast.icon 🤖

# Documentation:
# @raycast.author Urie96
# @raycast.authorURL https://github.com/Urie96

set -euo pipefail

temp="$(mktemp -t XXXXX.png)"
pbpaste | qrencode -o "$temp"
open "$temp"

open -a Preview "$temp"
/usr/bin/osascript -e 'tell application "Preview"' -e "activate" -e 'tell application "System Events"' -e 'keystroke "9" using { command down}' -e "end tell" -e "end tell"
