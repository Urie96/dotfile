#!/usr/bin/env bash
# 生成 submodule 补丁。
#
# 用法:
#   ./scripts/regenerate-submodule-patch.sh             # 批量：为所有有修改的 submodule 生成补丁
#   ./scripts/regenerate-submodule-patch.sh <submodule名>  # 只处理单个
#
# 前提: 修改已做在 submodules/<name> 里（工作区或已暂存均可，基于 pin 的 commit）
# 产出: patches/<name>/<当前HEAD>.patch，并删除该 submodule 的旧补丁
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

regenerate_one() {
  local name="$1"
  local subdir="submodules/$name"

  if ! git -C "$subdir" rev-parse --git-dir >/dev/null 2>&1; then
    echo "!!! 跳过 $name: 不是有效的 git 仓库 ($subdir)" >&2
    return 1
  fi

  # 无修改（含未跟踪文件都不算）则跳过
  if ! git -C "$subdir" status --porcelain | grep -q .; then
    echo "跳过 $name: 无修改"
    return 0
  fi

  local base outdir out
  base="$(git -C "$subdir" rev-parse HEAD)"
  outdir="patches/$name"
  mkdir -p "$outdir"
  out="$outdir/$base.patch"

  # 防坑提示：补丁 base 必须与提交时主仓库记录的 submodule pin 一致，
  # 否则下次 apply 会报"补丁过期"（regenerate 后漏 git add 了 submodule 指针）。
  local pin_head pin_index
  pin_head="$(git ls-tree HEAD "$subdir" 2>/dev/null | awk '{print $3}')"
  pin_index="$(git ls-files -s "$subdir" 2>/dev/null | awk '{print $2}')"
  if { [ -n "$pin_head" ] && [ "$pin_head" != "$base" ]; } || \
     { [ -n "$pin_index" ] && [ "$pin_index" != "$base" ]; }; then
    echo "!!! 提醒: 当前 HEAD ${base:0:12}，但主仓库 HEAD 记录 ${pin_head:0:12} / index 记录 ${pin_index:0:12}" >&2
    echo "    提交时请把 submodule pin 一起更新，否则下次 apply 会报补丁过期:" >&2
    echo "    git add '$subdir' '$outdir' && git commit" >&2
  fi

  # 清理旧补丁（约定: 每个 submodule 只保留基于当前 base 的一个补丁）
  rm -f "$outdir"/*.patch

  # diff HEAD 同时包含已暂存和未暂存的修改；--binary 兼容二进制文件
  git -C "$subdir" diff HEAD --binary > "$out"
  if [ ! -s "$out" ]; then
    if git -C "$subdir" status --porcelain | grep -q '^??'; then
      echo "!!! $name: 只有未跟踪文件，git diff 无法生成补丁，请先 git add" >&2
    else
      echo "!!! $name: 相对于 HEAD 没有可生成的内容，补丁为空（已删除旧补丁）" >&2
    fi
    rm -f "$out"
    return 1
  fi

  echo "✔ 补丁已生成: $out"
  echo "  提交: git add '$outdir' && git commit"
}

if [ $# -eq 0 ]; then
  # 批量：为所有有修改的 submodule 生成补丁
  shopt -s nullglob
  for subdir in submodules/*/; do
    regenerate_one "$(basename "$subdir")" || true
  done
else
  regenerate_one "$1"
fi
