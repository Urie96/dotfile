#!/usr/bin/env bash -l

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title Rust Doc Search
# @raycast.mode silent

# Optional parameters:
# @raycast.icon https://docs.rs/-/static/favicon.ico
# @raycast.argument1 {"optional":false,"placeholder":"Keyword","type":"text"}

# Documentation:
# @raycast.author Urie96
# @raycast.authorURL https://github.com/Urie96

set -euo pipefail

active-arc-tab "^https://docs.rs/$1/" || open "https://docs.rs/releases/search?query=$1"
