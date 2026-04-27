# Guard: only execute once
if set -qg __fish_01_env_ran
    return
end
set -gx __fish_01_env_ran 1

set -gx FZF_DEFAULT_OPTS "--bind='page-up:preview-page-up,page-down:preview-page-down' --cycle"
set -gx HF_ENDPOINT 'https://hf-mirror.com'
set -gx LANG 'zh_CN.UTF-8'
set -gx MANPAGER 'nvim +Man!'
# set -gx PAGER '/nix/store/hkknbz4dhckmg55zlbpsypg68001rf32-custom_pager'
set -gx PNPM_HOME ~/.local/share/pnpm
set -gx XDG_CACHE_HOME ~/.cache
set -gx XDG_CONFIG_HOME ~/.config
set -gx XDG_DATA_HOME ~/.local/share
set -gx XDG_STATE_HOME ~/.local/state

fish_add_path -g -m ~/.local/bin ~/.local/state/nix/profile/bin /run/wrappers/bin /run/current-system/sw/bin /nix/var/nix/profiles/default/bin "$PNPM_HOME" /opt/homebrew/bin /opt/homebrew/sbin

if command -q flatnvim
    set -gx EDITOR flatnvim
else
    set -gx EDITOR nvim
end
