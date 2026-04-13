#!/usr/bin/env bash -l

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title Log Keyword PPE
# @raycast.mode silent

# Optional parameters:
# @raycast.icon https://cloud.bytedance.net/logo.png

# Documentation:
# @raycast.author Urie96
# @raycast.authorURL https://github.com/Urie96

set -euo pipefail

active-arc-tab "https://cloud.bytedance.net/argos/streamlog/info_overview/keyword_search" || open "https://cloud.bytedance.net/argos/streamlog/info_overview/keyword_search"
