#!/usr/bin/env bash -l

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title Upload Image
# @raycast.mode fullOutput

# Optional parameters:
# @raycast.icon 🤖

# Documentation:
# @raycast.author Urie96
# @raycast.authorURL https://github.com/Urie96

set -euo pipefail

img_path="$HOME/workspace/images/"

if [ ! -d "$img_path" ]; then
  mkdir -p "$img_path"
  cd "$img_path" || exit 1
  git init
  git config pull.rebase true
  git checkout -b main
fi

cd "$img_path" || exit 1
git remote -v | grep github || git remote add github git@github.com:Urie96/images.git
git remote -v | grep gitea || git remote add gitea https://git.home.lubui.com:8443/urie/images.git
git pull gitea main
git pull github main

name=$1$(date +"%Y%m%d%H%M%S").png
pngpaste "$name"
# /Applications/kitty.app/Contents/MacOS/kitten clipboard -g "$name"

git add "$name"
git commit -m "upload $name"
git push gitea main
git push github main

github_url=https://cdn.jsdelivr.net/gh/Urie96/images/$name
gitea_url=https://git.home.lubui.com:8443/urie/images/raw/branch/main/$name
echo ""
echo "Github: $github_url"
echo "Gitea: $gitea_url"
echo "$gitea_url" | pbcopy
