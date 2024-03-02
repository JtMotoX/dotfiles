#!/bin/sh

set -e
cd "$(dirname "$0")"

# INSTALL BREW IF macOS
if [ "$(uname)" = "Darwin" ]; then ./scripts/brew-install.sh; fi

./scripts/pyenv-install.sh "3.10.3"
./scripts/zsh-install.sh
./scripts/oh-my-zsh-install.sh
./scripts/tmux-configure.sh
./scripts/create-symbolic-links.sh

# INSTALL NIX IF NOT EXISTS
if ! command -v nix >/dev/null 2>&1 || [ ! -f '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh' ] || ! grep nixbld /etc/group >/dev/null 2>&1; then
    ./scripts/nix-uninstall.sh
    for key in $(env | grep '^NIX_' | awk -F= '{print $1}'); do unset $key; done
    ./scripts/nix-install.sh
fi

if [ -f '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh' ]; then . '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh'; fi
# ./scripts/nix-packages-uninstall.sh
./scripts/nix-packages-install.sh

if ! command -v git | grep 'nix' >/dev/null 2>&1; then
    echo "The setup failed"
    exit 1
fi

echo "Successfully finished setup. Please reload your session."
