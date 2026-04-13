#!/usr/bin/env bash -l

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title Overpass
# @raycast.mode silent

# Optional parameters:
# @raycast.icon https://cloud.bytedance.net/logo.png

# Documentation:
# @raycast.author Urie96
# @raycast.authorURL https://github.com/Urie96

set -euo pipefail

active-arc-tab "https://cloud.bytedance.net/overpass/idl" || open "https://cloud.bytedance.net/overpass/idl"
