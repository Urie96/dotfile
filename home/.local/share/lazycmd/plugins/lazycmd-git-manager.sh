#!/usr/bin/env bash

# Lazycmd Git Manager
# 管理 plugins 目录下所有 .lazycmd git 仓库

PLUGINS_DIR="$HOME/.local/share/lazycmd/plugins"

# 切换 origin 从 HTTPS 到 SSH
switch_to_ssh() {
  echo "🔄 正在将所有仓库的 origin 切换为 SSH 协议..."

  find "$PLUGINS_DIR" -maxdepth 1 -type d -name "*.lazycmd" | while read -r dir; do
    if [ -d "$dir/.git" ]; then
      cd "$dir" || continue
      repo_name=$(basename "$dir")

      # 获取当前 origin URL
      origin_url=$(git remote get-url origin 2>/dev/null)
      if [ -n "$origin_url" ]; then
        # 转换 HTTPS -> SSH
        if [[ "$origin_url" == https://* ]]; then
          new_url=$(echo "$origin_url" | sed 's|https://github.com/|git@github.com:|g')
          git remote set-url origin "$new_url"
          echo "✅ $repo_name: $origin_url -> $new_url"
        elif [[ "$origin_url" == git@github.com:* ]]; then
          echo "⏭️  $repo_name: 已经是 SSH 协议"
        fi
      fi
    fi
  done

  echo ""
  echo "✅ 完成!"
}

# 查看有代码变化的仓库，通过 fzf 选择并预览 diff
browse_changes() {
  echo "🔍 查找有变化的仓库..."

  # 收集有变化的仓库信息
  declare -A changed_repos
  changes_found=0

  while IFS= read -r dir; do
    if [ -d "$dir/.git" ]; then
      cd "$dir" || continue
      repo_name=$(basename "$dir")

      # 检查是否有未暂存的更改
      if git diff --quiet 2>/dev/null; then
        unstaged=""
      else
        unstaged="[unstaged]"
      fi

      # 检查是否有已暂存但未提交的更改
      if git diff --cached --quiet 2>/dev/null; then
        staged=""
      else
        staged="[staged]"
      fi

      # 检查是否有未推送的提交
      unpushed=""
      if git log --oneline origin/$(git branch --show-current 2>/dev/null || echo "main")..HEAD 2>/dev/null | grep -q .; then
        unpushed="[unpushed]"
      fi

      # 如果有任一变化
      if [ -n "$unstaged" ] || [ -n "$staged" ] || [ -n "$unpushed" ]; then
        changed_repos["$repo_name"]="$dir"
        echo "$repo_name: $staged $unstaged $unpushed"
        changes_found=$((changes_found + 1))
      fi
    fi
  done < <(find "$PLUGINS_DIR" -maxdepth 1 -type d -name "*.lazycmd")

  if [ $changes_found -eq 0 ]; then
    echo "没有发现任何变化的仓库"
    return
  fi

  echo ""
  read -p "是否通过 fzf 查看详细 diff? (y/n) " -n 1 -r
  echo

  if [[ $REPLY =~ ^[Yy]$ ]]; then
    # 使用 fzf 选择仓库并预览 diff
    selected=$(for name in "${!changed_repos[@]}"; do
      echo "$name"
    done | fzf --height=40% --border --preview="
            cd $PLUGINS_DIR/{}/.git/..
            echo '=== Staged Changes ==='
            git diff --cached --stat 2>/dev/null || echo 'No staged changes'
            echo ''
            echo '=== Unstaged Changes ==='
            git diff --stat 2>/dev/null || echo 'No unstaged changes'
            echo ''
            echo '=== Unpushed Commits ==='
            git log origin/$(git branch --show-current 2>/dev/null || echo 'main')..HEAD --oneline 2>/dev/null || echo 'No unpushed commits'
        " --preview-window=right:60%:wrap)

    if [ -n "$selected" ]; then
      cd "${changed_repos[$selected]}"
      echo ""
      echo "📦 仓库: $selected"
      echo ""
      echo "=== 已暂存更改 ==="
      git diff --cached
      echo ""
      echo "=== 未暂存更改 ==="
      git diff
      echo ""
      echo "=== 未推送提交 ==="
      git log origin/$(git branch --show-current 2>/dev/null || echo 'main')..HEAD --oneline 2>/dev/null || echo "无"
    fi
  fi
}

# 一键暂存、提交并推送所有仓库
commit_all() {
  echo "🚀 准备提交并推送所有有变化的仓库..."

  # 首先检查 SSH 连接
  echo "检查 SSH 连接..."
  if ! ssh -T git@github.com 2>&1 | grep -q "successfully"; then
    echo "⚠️  SSH 连接可能有问题，请确保 SSH key 已配置"
  fi

  changed_count=0

  while IFS= read -r dir; do
    if [ -d "$dir/.git" ]; then
      cd "$dir" || continue
      repo_name=$(basename "$dir")

      # 检查是否有更改
      if git diff --quiet && git diff --cached --quiet; then
        echo "⏭️  $repo_name: 没有变化，跳过"
        continue
      fi

      changed_count=$((changed_count + 1))
      echo ""
      echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
      echo "📦 处理: $repo_name"
      echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

      # 暂存所有更改
      echo "📦 暂存更改..."
      git add -A

      # 显示将要提交的更改
      echo ""
      echo "📋 更改摘要:"
      git diff --cached --stat

      # 输入提交信息
      echo ""
      read -p "📝 输入提交信息 (留空自动生成): " commit_msg

      if [ -z "$commit_msg" ]; then
        # 自动生成提交信息
        staged_count=$(git diff --cached --name-only | wc -l | tr -d ' ')
        commit_msg="Update $repo_name: $staged_count file(s) changed"
      fi

      # 提交
      echo "💾 提交..."
      if git commit -m "$commit_msg"; then
        # 推送
        echo "📤 推送到远程..."
        current_branch=$(git branch --show-current 2>/dev/null || echo "main")
        if git push origin "$current_branch" 2>&1; then
          echo "✅ $repo_name 完成!"
        else
          echo "❌ $repo_name 推送失败!"
        fi
      else
        echo "❌ $repo_name 提交失败!"
      fi
    fi
  done < <(find "$PLUGINS_DIR" -maxdepth 1 -type d -name "*.lazycmd")

  echo ""
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo "✅ 完成! 共处理 $changed_count 个仓库"
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
}

# 显示菜单
show_menu() {
  echo ""
  echo "╔════════════════════════════════════════╗"
  echo "║     Lazycmd Git Manager                 ║"
  echo "╠════════════════════════════════════════╣"
  echo "║  1. 🔄 切换所有仓库 origin 到 SSH      ║"
  echo "║  2. 🔍 浏览有变化的仓库 (fzf)          ║"
  echo "║  3. 🚀 暂存、提交并推送所有仓库         ║"
  echo "║  4. 📊 查看所有仓库状态                 ║"
  echo "║  5. 🚪 退出                            ║"
  echo "╚════════════════════════════════════════╝"
  echo ""
}

# 查看所有仓库状态
show_status() {
  echo "📊 所有仓库状态:"
  echo ""

  while IFS= read -r dir; do
    if [ -d "$dir/.git" ]; then
      cd "$dir" || continue
      repo_name=$(basename "$dir")

      # 获取当前分支
      branch=$(git branch --show-current 2>/dev/null || echo "main")

      # 获取 origin URL
      origin_url=$(git remote get-url origin 2>/dev/null | sed 's|git@github.com:|https://github.com/|g' | sed 's|\.git$||')

      # 检查状态
      status=""
      if ! git diff --quiet 2>/dev/null; then
        status+="[unstaged] "
      fi
      if ! git diff --cached --quiet 2>/dev/null; then
        status+="[staged] "
      fi
      if git log --oneline origin/$branch..HEAD 2>/dev/null | grep -q .; then
        status+="[unpushed] "
      fi

      if [ -z "$status" ]; then
        status="✅ clean"
      fi

      printf "%-30s [%s] %s %s\n" "$repo_name" "$branch" "$status" "$origin_url"
    fi
  done < <(find "$PLUGINS_DIR" -maxdepth 1 -type d -name "*.lazycmd")
}

# 主程序
main() {
  # 确保在正确目录
  cd "$PLUGINS_DIR" || exit 1

  # 检查 fzf 是否安装
  if ! command -v fzf &>/dev/null; then
    echo "⚠️  fzf 未安装，部分功能可能无法使用"
    echo "   安装: brew install fzf"
  fi

  while true; do
    show_menu
    read -p "选择操作 (1-5): " choice

    case $choice in
    1)
      switch_to_ssh
      ;;
    2)
      browse_changes
      ;;
    3)
      commit_all
      ;;
    4)
      show_status
      ;;
    5)
      echo "👋 再见!"
      exit 0
      ;;
    *)
      echo "❌ 无效选择，请输入 1-5"
      ;;
    esac

    echo ""
    read -p "按 Enter 继续..." dummy
  done
}

# 根据参数执行相应功能
case "${1:-}" in
switch | 1)
  switch_to_ssh
  ;;
browse | diff | 2)
  browse_changes
  ;;
commit | push | 3)
  commit_all
  ;;
status | 4)
  show_status
  ;;
*)
  main
  ;;
esac
