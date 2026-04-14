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

## 注意事项

- 仓库中部分文件通过 **git-crypt** 加密，`git-crypt unlock` 需要对应的 GPG 密钥。
- 如果没有密钥，安装脚本会询问是否继续。
