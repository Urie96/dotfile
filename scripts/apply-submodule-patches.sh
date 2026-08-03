#!/usr/bin/env bash
# 为 submodule 应用补丁（在"不 fork 上游"的前提下修改 submodule 源码）。
#
# 约定（详见 README）：
#   补丁文件: patches/<submodule>/<base-commit>.patch
#   <base-commit> = 父仓库 pin 的 submodule commit；应用前会校验。
#
# 行为（幂等，可安全重复运行）：
#   1. 把有补丁的 submodule reset 到 HEAD（丢弃已应用的补丁）
#   2. git submodule update --init --recursive（对齐 pin 的 commit）
#   3. 逐个应用补丁：基准不匹配 -> 警告跳过；已应用 -> 跳过；否则 git apply --3way
#
# 注意：脚本会 reset 有补丁的 submodule 工作区。若有未落盘的修改，
#       请先运行 ./scripts/regenerate-submodule-patch.sh <name> 把修改固化成补丁。
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

msg() { printf "\033[1;34m>>> %s\033[0m\n" "$*"; }
warn() { printf "\033[1;33m!!! %s\033[0m\n" "$*"; }
err() { printf "\033[1;31m!!! %s\033[0m\n" "$*" >&2; }

# 1. 有补丁的 submodule 先恢复干净（补丁本身已提交到父仓库，reset 不丢东西）
shopt -s nullglob
for dir in patches/*/; do
  name="$(basename "$dir")"
  if git -C "submodules/$name" rev-parse --git-dir >/dev/null 2>&1; then
    git -C "submodules/$name" reset --hard -q
  fi
done

# 2. 对齐 pin 的 commit
git submodule update --init --recursive

# 3. 应用补丁（幂等）
applied=false
for patchfile in patches/*/*.patch; do
  name="$(basename "$(dirname "$patchfile")")"
  base="$(basename "$patchfile" .patch)"
  subdir="submodules/$name"

  if ! git -C "$subdir" rev-parse --git-dir >/dev/null 2>&1; then
    err "submodule $name 不存在，跳过补丁 $patchfile"
    continue
  fi

  if ! actual="$(git -C "$subdir" rev-parse HEAD 2>/dev/null)"; then
    err "$name: 无法读取 submodule HEAD（${subdir}）"
    exit 1
  fi
  if [ "$actual" != "$base" ]; then
    warn "$name 当前在 ${actual}，但补丁基于 $base —— 补丁已过期，需要重新生成："
    warn "  git -C $subdir reset --hard && 手动把修改搬到新版本"
    warn "  ./scripts/regenerate-submodule-patch.sh $name"
    continue
  fi

  # 反向 apply 成功 => 补丁已应用 => 跳过（幂等）
  if git -C "$subdir" apply --reverse --check "$ROOT/$patchfile" >/dev/null 2>&1; then
    msg "$name: 补丁已应用，跳过"
    applied=true
    continue
  fi

  msg "$name: 应用 $patchfile"
  if ! git -C "$subdir" apply --3way "$ROOT/$patchfile"; then
    err "$name: 补丁应用失败。请手动解决冲突后重新生成补丁。"
    exit 1
  fi
  applied=true
done

if [ "$applied" = true ]; then
  msg "submodule 补丁处理完成"
else
  msg "没有需要应用的 submodule 补丁"
fi
