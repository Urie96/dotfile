#!/usr/bin/env bash -l

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title Paste PNG To File
# @raycast.mode silent

# Optional parameters:
# @raycast.icon 🤖

# Documentation:
# @raycast.author Urie96
# @raycast.authorURL https://github.com/Urie96

set -euo pipefail

dir="$HOME/Documents/pngpaste"
mkdir -p "$dir"
path="$dir/$(date "+%Y%m%d%H%M%S").png"
pngpaste "$path"
launch-terminal-tab yazi "$path"
echo -n "$path"
