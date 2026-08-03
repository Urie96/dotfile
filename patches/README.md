# patches

submodule 补丁目录（不 fork 上游就能修改 submodule 源码）。

约定：

- 每个 submodule 最多一个补丁：`patches/<submodule>/<base-commit>.patch`
- `<base-commit>` 是父仓库 pin 的 submodule commit，应用脚本会校验
- 由 `scripts/apply-submodule-patches.sh` 在 clone / pull / 安装时自动应用

流程：

- 修改 submodule → `./scripts/regenerate-submodule-patch.sh`（不传名字 = 批量生成所有有修改的 submodule；传名字只处理单个）→ 提交补丁
- 升级 submodule → 手动把修改搬到新版本 → 重新生成补丁（旧补丁会被删除）
