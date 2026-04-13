#!/usr/bin/env bash -l

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title Date To Unix Timestamp
# @raycast.mode silent

# Optional parameters:
# @raycast.icon 🕰
# @raycast.argument1 {"optional":true,"placeholder":"Date","type":"text"}

# Documentation:
# @raycast.author Urie96
# @raycast.authorURL https://github.com/Urie96

set -euo pipefail

DATE="$1"
if [ -z "$DATE" ]; then
  date +%s
else
  date -d "$DATE" +%s
fi | tr -d '\n' | tee >(pbcopy)
