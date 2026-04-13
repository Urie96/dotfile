#!/usr/bin/env bash -l

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title Toggle Mac Bar
# @raycast.mode silent

# Optional parameters:
# @raycast.icon 🤖

# Documentation:
# @raycast.author Urie96
# @raycast.authorURL https://github.com/Urie96

set -euo pipefail

osascript <<EOF
tell application "System Events"
    if autohide menu bar of dock preferences then
        set autohide menu bar of dock preferences to false
        return "false"
    else
        set autohide menu bar of dock preferences to true
        return "true"
    end if
end tell
EOF
