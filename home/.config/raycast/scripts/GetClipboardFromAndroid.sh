#!/usr/bin/env bash -l

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title Get Clipboard From Android
# @raycast.mode fullOutput

# Optional parameters:
# @raycast.icon 🤖

# Documentation:
# @raycast.author Urie96
# @raycast.authorURL https://github.com/Urie96

set -euo pipefail

TERMUX_IP="termux.lan"

get_clipboard_by_takser() {
  curl -s "http://${TERMUX_IP}:1821/clipboard"
}

get_clipboard_by_termux() {
  ssh -o ConnectTimeout=3 "$TERMUX_IP" termux-clipboard-get
}

android_clipboard_text="$(get_clipboard_by_termux)"

if [ -n "$android_clipboard_text" ]; then
  echo -n "$android_clipboard_text" | pbcopy
  echo "Copied from Android: $android_clipboard_text"
fi
