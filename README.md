# dotfile

个人点文件，通过 symlink 管理所有配置文件。

## 一键安装

```bash
bash <(curl -fsSL https://raw.githubusercontent.com/urie96/dotfile/main/bootstrap.sh)
```

> 需要预先安装 `git`、`git-crypt` 和 `python3`。

## 手动安装

```bash
git clone https://github.com/urie96/dotfile.git ~/dotfile
chmod 700 ~/dotfile
cd ~/dotfile
git-crypt unlock          # 如果有加密文件
python3 ./install.py
```

## 工作原理

`install.py` 会将 `home/` 目录下的文件以软链接形式映射到 `$HOME` 对应路径，并在 `.symlink_record` 中记录。再次运行时，会自动清理已失效的旧链接并创建新链接。

```
~/dotfile/home/.bashrc → ~/.bashrc
~/dotfile/home/.config/nvim/init.vim → ~/.config/nvim/init.vim
```

## 修改 submodule 源码（不 fork 上游）

不想 fork 上游时，用「补丁 + 脚本」的方式修改 submodule：

- 补丁存放在 `patches/<submodule>/<base-commit>.patch`，`base-commit` 是当前 pin 的 submodule commit，应用时会校验
- `bootstrap.sh`（`scripts/apply-submodule-patches.sh`）会在拉取/安装时自动应用，幂等

改一个 submodule 的流程：

```bash
# 1. 进入 submodule 改代码
vim submodules/catppuccin-tmux/xxx.tmux
# 2. 把改动固化成补丁（不传名字 = 批量生成所有有修改的 submodule）
./scripts/regenerate-submodule-patch.sh
#    或只处理单个: ./scripts/regenerate-submodule-patch.sh catppuccin-tmux
git add patches/ && git commit -m "patch: catppuccin-tmux 自定义"
```

升级 submodule 到新版本：

```bash
git -C submodules/catppuccin-tmux reset --hard   # 丢弃旧补丁
git submodule update --remote catppuccin-tmux    # 或手动 checkout 新 commit
# 在新版本上重新做修改（旧 patches/xxx.patch 可作参考），然后：
./scripts/regenerate-submodule-patch.sh catppuccin-tmux
git add submodules/catppuccin-tmux patches/ && git commit
```

注意：

- 应用补丁后 submodule 会显示为 dirty（`git status` 里的 `m`），这是正常现象，改动已经以补丁形式提交在 `patches/` 里
- `apply-submodule-patches.sh` 会先把有补丁的 submodule reset 干净再重新应用 —— 有未落盘的修改请先 regenerate
- 改动大、要长期维护的话，还是建议 fork + 定期合上游 + 提 PR；补丁方案适合少量、个性化、不想维护 fork 的情况

## 注意事项

- 仓库中部分文件通过 **git-crypt** 加密，`git-crypt unlock` 需要对应的 GPG 密钥。
- 如果没有密钥，安装脚本会询问是否继续。
