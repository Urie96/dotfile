#!/usr/bin/env bash -l

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title Search Nix Function
# @raycast.mode silent

# Optional parameters:
# @raycast.icon https://noogle.dev/favicon.png
# @raycast.argument1 {"optional":false,"placeholder":"Keyword","type":"text"}

# Documentation:
# @raycast.author Urie96
# @raycast.authorURL https://github.com/Urie96

set -euo pipefail

open "https://noogle.dev/q?term=$1"
