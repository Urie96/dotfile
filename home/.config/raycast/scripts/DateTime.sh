#!/usr/bin/env bash -l

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title Date Time
# @raycast.mode inline
# @raycast.refreshTime 1m

# Optional parameters:
# @raycast.icon 🤖

# Documentation:
# @raycast.author Urie96
# @raycast.authorURL https://github.com/Urie96

set -euo pipefail

DATE="$(date "+%-m月%-d日 周%u %H:%M" | sed -e "s/周1/周一/" -e "s/周2/周二/" -e "s/周3/周三/" -e "s/周4/周四/" -e "s/周5/周五/" -e "s/周6/周六/" -e "s/周7/周日/")"
echo -e "\033[1;33m${DATE}\033[0m"
