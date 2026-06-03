#!/usr/bin/env bash -l

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title Copy From Termux
# @raycast.mode fullOutput

# Optional parameters:
# @raycast.icon 🤖

# Documentation:
# @raycast.author Urie96
# @raycast.authorURL https://github.com/Urie96

set -euo pipefail

adb-tools clipboard-get
