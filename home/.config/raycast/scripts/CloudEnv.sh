#!/usr/bin/env bash -l

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title Cloud Env
# @raycast.mode silent

# Optional parameters:
# @raycast.icon https://cloud.bytedance.net/logo.png

# Documentation:
# @raycast.author Urie96
# @raycast.authorURL https://github.com/Urie96

set -euo pipefail

open "https://bits.bytedance.net/env/life/list?active_tab=manage&env_type=ppe"
