#!/usr/bin/env bash -l

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title ChatGPT
# @raycast.mode silent

# Optional parameters:
# @raycast.icon 🕰
# @raycast.argument1 {"placeholder":"Prompt","type":"text"}

# Documentation:
# @raycast.author Urie96
# @raycast.authorURL https://github.com/Urie96

set -euo pipefail

open "https://chatgpt.com/?q=$(echo $1 | jq -sRr @uri)"
