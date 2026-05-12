#!/usr/bin/env bash
set -euo pipefail

ASSUME_YES=false
DO_STORAGE=true
DO_UPGRADE=true

usage() {
  cat <<'EOF'
Usage: termux-init.sh [options]

Options:
  -y, --yes         Do not ask pkg confirmation questions
      --no-storage Skip termux-setup-storage
      --no-upgrade Skip pkg upgrade
      --no-dotfiles Skip installing dotfiles symlinks
  -h, --help        Show this help
EOF
}

while [[ $# -gt 0 ]]; do
  case "$1" in
  -y | --yes)
    ASSUME_YES=true
    ;;
  --no-storage)
    DO_STORAGE=false
    ;;
  --no-upgrade)
    DO_UPGRADE=false
    ;;
  -h | --help)
    usage
    exit 0
    ;;
  *)
    echo "Unknown option: $1" >&2
    usage >&2
    exit 1
    ;;
  esac
  shift
done

msg() { printf '\033[1;34m>>> %s\033[0m\n' "$*"; }
warn() { printf '\033[1;33m!!! %s\033[0m\n' "$*"; }
err() { printf '\033[1;31m!!! %s\033[0m\n' "$*" >&2; }

require_termux() {
  if [[ -z "${TERMUX_VERSION:-}" && "${PREFIX:-}" != */com.termux/files/usr ]]; then
    err "This script is intended to run inside Termux."
    exit 1
  fi
  if ! command -v pkg >/dev/null 2>&1; then
    err "pkg command not found."
    exit 1
  fi
}

pkg_args() {
  if [[ "$ASSUME_YES" == true ]]; then
    printf '%s\n' -y
  fi
}

is_installed() {
  dpkg -s "$1" &>/dev/null
}

install_one() {
  local pkg_name="$1"

  if is_installed "$pkg_name"; then
    msg "$pkg_name already installed"
    return 0
  fi

  msg "Installing $pkg_name"
  if ! pkg install $(pkg_args) "$pkg_name"; then
    warn "Failed to install $pkg_name, skipped"
    return 1
  fi
}

# Install package groups.  Arguments may contain alternatives separated by '|'.
# The first successfully installed/already-present alternative wins.
install-pkg() {
  local spec alt installed

  for spec in "$@"; do
    installed=false
    IFS='|' read -r -a alts <<<"$spec"
    for alt in "${alts[@]}"; do
      if is_installed "$alt"; then
        msg "$alt already installed"
        installed=true
        break
      fi
      if install_one "$alt"; then
        installed=true
        break
      fi
    done

    if [[ "$installed" != true ]]; then
      warn "No package alternative could be installed for: $spec"
    fi
  done
}

setup_storage() {
  if [[ "$DO_STORAGE" != true ]]; then
    return 0
  fi

  if command -v termux-setup-storage &>/dev/null && [[ ! -d "$HOME/storage" ]]; then
    msg "Requesting shared storage access"
    termux-setup-storage || warn "termux-setup-storage failed or was denied"
  fi
}

setup_shell() {
  if command -v fish &>/dev/null; then
    chsh -s fish
  fi
}

main() {
  require_termux

  msg "Updating package metadata"
  pkg update $(pkg_args)

  if [[ "$DO_UPGRADE" == true ]]; then
    msg "Upgrading installed packages"
    pkg upgrade $(pkg_args)
  fi

  install-pkg \
    openssh git \
    termux-api tsu \
    7zip bzip2 gzip tar unzip zip xz-utils zstd \
    aapt2 android-tools \
    atuin bat fd fzf ripgrep git-delta zoxide \
    curl wget netcat-openbsd ca-certificates lsof mosh \
    sed gawk bash fish grep jq tree tmux rsync cronie less \
    make just pkg-config \
    yazi file chafa imagemagick pandoc exiftool poppler \
    lazygit \
    neovim shfmt stylua lua-language-server \
    gh \
    diffutils coreutils dnsutils findutils debianutils util-linux inetutils net-tools \
    nodejs golang python

  setup_storage
  setup_shell

  msg "Termux initialization complete"
}

main "$@"
