install:
    ./install.sh
    ./scripts/install-skills.sh

status:
    git-crypt status

patches:
    ./scripts/apply-submodule-patches.sh

regenerate-patch:
    ./scripts/regenerate-submodule-patch.sh

regenerate-patch-one name:
    ./scripts/regenerate-submodule-patch.sh {{ name }}

# 一键: 生成补丁 + 提交 submodule pin 和补丁（不传名字 = 批量处理所有有修改的）
pin-patch message="chore: 更新 submodule pin 与补丁":
    #!/usr/bin/env bash
    set -euo pipefail
    cd "{{ justfile_directory() }}"
    ./scripts/regenerate-submodule-patch.sh
    for patch in patches/*/*.patch; do
      [ -f "$patch" ] || continue
      sub="$(basename "$(dirname "$patch")")"
      git add "submodules/$sub" "patches/$sub"
    done
    if git diff --cached --quiet; then
      echo "没有需要提交的变更"
    else
      git commit -m "{{ message }}"
    fi
