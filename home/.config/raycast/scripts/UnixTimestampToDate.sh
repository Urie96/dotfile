#!/usr/bin/env bash -l

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title Unix Timestamp To Date
# @raycast.mode compact

# Optional parameters:
# @raycast.icon 🕰

# Documentation:
# @raycast.author Urie96
# @raycast.authorURL https://github.com/Urie96

set -euo pipefail

unixTime=$(pbpaste)
length=${#unixTime}

if [[ $length == "13" ]]; then
  unixTime=$((unixTime / 1000))
elif [[ $length != "10" ]]; then
  echo "Unix Time is not found"
  exit 1
fi
readable="$(date -d "@$unixTime" "+%F %T")"

current_time=$(date +%s)
time_since=$((unixTime - current_time))
if [ $time_since -lt 0 ]; then
  suffix="前"
  time_since=$((0 - time_since))
else
  suffix="后"
fi

secs=$time_since
mins=$((secs / 60))
hours=$((mins / 60))
days=$((hours / 24))
months=$((days / 30))
years=$((days / 365))

since=""
if [ $years -gt 0 ]; then
  since="${years} 年"
elif [ $months -gt 0 ]; then
  since="${months} 月"
elif [ $days -gt 0 ]; then
  since="${days} 天"
elif [ $hours -gt 0 ]; then
  since="${hours} 小时"
elif [ $mins -gt 0 ]; then
  since="${mins} 分钟"
else
  since="${secs} 秒"
fi

echo "$readable ($since$suffix)"
