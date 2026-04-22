#!/usr/bin/env bash
set -euo pipefail

REPO="https://github.com/Urie96/dotfile.git"
DEST="$HOME/dotfile"

# ── Arguments ────────────────────────────────────────────────────────
SKIP_PROMPTS=false
while [[ $# -gt 0 ]]; do
  case "$1" in
  --yes|-y)
    SKIP_PROMPTS=true
    shift
    ;;
  *)
    echo "Usage: $0 [--yes|-y]"
    exit 1
    ;;
  esac
done

msg() { printf "\033[1;34m>>> %s\033[0m\n" "$*"; }
warn() { printf "\033[1;33m!!! %s\033[0m\n" "$*"; }
err() { printf "\033[1;31m!!! %s\033[0m\n" "$*" >&2; }

# ── 1. Clone / Pull ───────────────────────────────────────────────────
if [ -d "$DEST/.git" ]; then
  msg "仓库已存在: $DEST — 执行 pull"
  cd "$DEST"
  git pull --ff-only || {
    err "存在冲突，请手动解决后再运行本脚本"
    exit 1
  }
else
  msg "克隆 $REPO → $DEST"
  git clone "$REPO" "$DEST"
  cd "$DEST"

  chmod 700 "$DEST"

  # ── 2. git-crypt unlock ──────────────────────────────────────────────
  if ! git-crypt unlock; then
    warn "git-crypt unlock 失败（可能缺少密钥）"
    if [[ "$SKIP_PROMPTS" == true ]]; then
      msg "--yes 已指定，自动继续"
    else
      read -rp "是否继续安装？[y/N] " answer
      case "$answer" in
      [yY] | [yY][eE][sS]) ;;
      *)
        err "用户取消"
        exit 1
        ;;
      esac
    fi
  fi

fi

# ── 3. Install ───────────────────────────────────────────────────────
msg "运行 install.py"
python3 ./install.py

msg "安装完成 ✓"
