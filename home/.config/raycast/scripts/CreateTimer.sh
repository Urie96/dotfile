#!/usr/bin/env bash -l

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title Create Timer
# @raycast.mode silent

# Optional parameters:
# @raycast.icon 🕰
# @raycast.argument1 {"optional":true,"placeholder":"Hours","type":"text"}
# @raycast.argument2 {"optional":true,"placeholder":"Minutes","type":"text"}
# @raycast.argument3 {"optional":true,"placeholder":"Seconds","type":"text"}

# Documentation:
# @raycast.author Urie96
# @raycast.authorURL https://github.com/Urie96

set -euo pipefail

hours=${1:-0}
mins=${2:-0}
secs=${3:-0}
time=$((hours * 3600 + mins * 60 + secs))

notify() {
  /usr/bin/osascript -e "display notification \"$2\" with title \"$1\""
}

notify "Timer Start" "${hours} Hours ${mins} Minutes ${secs} Seconds"
sleep "$time"
open raycast://confetti
notify "Timer Complete" "${hours} Hours ${mins} Minutes ${secs} Seconds"
say timer complete
