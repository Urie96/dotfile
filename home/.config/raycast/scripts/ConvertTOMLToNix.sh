#!/usr/bin/env bash -l

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title Convert TOML To Nix
# @raycast.mode fullOutput

# Optional parameters:
# @raycast.icon 🤖

# Documentation:
# @raycast.author Urie96
# @raycast.authorURL https://github.com/Urie96

set -euo pipefail

FROM_LANG=toml

tmp="$(mktemp)"
case "$FROM_LANG" in
json)
  pbpaste >"$tmp"
  ;;
yaml)
  pbpaste | yq -o=json . >"$tmp"
  ;;
toml)
  pbpaste | yq -p toml -o=json . >"$tmp"
  ;;
*)
  echo "$FROM_LANG not supported"
  exit 1
  ;;
esac

nix_string="$(nix-instantiate --eval --expr "builtins.fromJSON (builtins.readFile $tmp)" | fmt-file -l nix)"
rm "$tmp"

echo "$nix_string" | pbcopy
echo "$nix_string" | bat --color=always --paging=never --style=plain -l nix
