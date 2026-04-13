#!/usr/bin/env bash -l

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title OCR
# @raycast.mode fullOutput

# Optional parameters:
# @raycast.icon 🤖

# Documentation:
# @raycast.author Urie96
# @raycast.authorURL https://github.com/Urie96

set -euo pipefail

tmp="$TMPDIR"/pngpaste.png
pngpaste "$tmp"
mac-ocr "$tmp"
rm "$tmp"
