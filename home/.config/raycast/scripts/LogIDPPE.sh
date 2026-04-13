#!/usr/bin/env bash -l

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title LogID PPE
# @raycast.mode silent

# Optional parameters:
# @raycast.icon https://cloud.bytedance.net/logo.png

# Documentation:
# @raycast.author Urie96
# @raycast.authorURL https://github.com/Urie96

set -euo pipefail

open "https://cloud.bytedance.net/argos/streamlog/info_overview/log_id_search?logId=$(pbpaste)&psm=aurora.doctor.workstation&region=cn"
