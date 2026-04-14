#!/usr/bin/env bash
set -euo pipefail

REPO="git@github.com:Urie96/dotfile.git"
DEST="$HOME/dotfile"

msg() { printf "\033[1;34m>>> %s\033[0m\n" "$*"; }
warn() { printf "\033[1;33m!!! %s\033[0m\n" "$*"; }
err() { printf "\033[1;31m!!! %s\033[0m\n" "$*" >&2; }

# ── 1. Clone ─────────────────────────────────────────────────────────
if [ -d "$DEST/.git" ]; then
  msg "仓库已存在: $DEST — 跳过 clone"
else
  msg "克隆 $REPO → $DEST"
  git clone "$REPO" "$DEST"
fi

chmod 700 "$DEST"

cd "$DEST"

# ── 2. git-crypt unlock ──────────────────────────────────────────────
if ! git-crypt unlock; then
  warn "git-crypt unlock 失败（可能缺少密钥）"
  read -rp "是否继续安装？[y/N] " answer
  case "$answer" in
  [yY] | [yY][eE][sS]) ;;
  *)
    err "用户取消"
    exit 1
    ;;
  esac
fi

# ── 3. Install ───────────────────────────────────────────────────────
msg "运行 install.py"
python3 ./install.py

msg "安装完成 ✓"
