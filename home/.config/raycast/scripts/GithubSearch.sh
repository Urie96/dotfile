#!/usr/bin/env bash -l

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title Github Search
# @raycast.mode silent

# Optional parameters:
# @raycast.icon https://cdn.jsdelivr.net/gh/walkxcode/dashboard-icons/png/github-light.png
# @raycast.argument1 {"optional":false,"placeholder":"Repository","type":"text"}

# Documentation:
# @raycast.author Urie96
# @raycast.authorURL https://github.com/Urie96

set -euo pipefail

open "https://github.com/search?q=$1&type=repositories"
