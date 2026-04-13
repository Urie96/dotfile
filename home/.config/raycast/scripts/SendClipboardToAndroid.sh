#!/usr/bin/env bash -l

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title Send Clipboard To Android
# @raycast.mode silent

# Optional parameters:
# @raycast.icon 🤖

# Documentation:
# @raycast.author Urie96
# @raycast.authorURL https://github.com/Urie96

set -euo pipefail

android_run() {
  ssh -o ConnectTimeout=3 termux.lan "$@" || exit
}

this_pc_clipboard_text="$(pbpaste)"

if [ -n "$this_pc_clipboard_text" ]; then
  echo -n "$this_pc_clipboard_text" | android_run bash -ec "termux-clipboard-set && echo 'Copied from remote' | termux-toast"
  echo "Pasted to Android: $this_pc_clipboard_text"
fi
