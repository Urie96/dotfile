#!/usr/bin/env bash -l

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title Google Search
# @raycast.mode silent

# Optional parameters:
# @raycast.icon https://www.google.com/favicon.ico
# @raycast.argument1 {"optional":false,"placeholder":"Keyword","type":"text"}

# Documentation:
# @raycast.author Urie96
# @raycast.authorURL https://github.com/Urie96

set -euo pipefail

open "https://www.google.com/search?q=$1"
