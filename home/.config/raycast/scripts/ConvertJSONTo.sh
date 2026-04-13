#!/usr/bin/env bash -l

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title Convert JSON To
# @raycast.mode fullOutput

# Optional parameters:
# @raycast.icon 🤖

# Documentation:
# @raycast.author Urie96
# @raycast.authorURL https://github.com/Urie96

set -euo pipefail

dest="$1"

convert() {
  case "$dest" in
  js)
    node /nix/store/4pil8j0igb2fmvl2gsci2jd055brrbn8-json-to-jsdoc.js
    ;;
  go | ts)
    quicktype -l "$dest" --just-types
    ;;
  *)
    quicktype -l "$dest"
    ;;
  esac
}

pbpaste | convert | tee >(pbcopy) | bat -l "$dest" --color=always --paging=never --style=plain
