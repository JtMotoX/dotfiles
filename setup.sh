#!/bin/sh

set -e
cd "$(dirname "$0")"

reload_needed="false"

# UPDATE THIS REPO
current_commit="$(git rev-parse HEAD)"
git pull
new_commit="$(git rev-parse HEAD)"
if [ "$current_commit" != "$new_commit" ]; then
    echo "Some changes were made to this repo. Please run the script again."
    exit 1
fi

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
    reload_needed="true"
fi

if [ -f '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh' ]; then . '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh'; fi
# ./scripts/nix-packages-uninstall.sh
./scripts/nix-packages-install.sh

if ! command -v git | grep 'nix' >/dev/null 2>&1; then
    echo "The setup failed"
    exit 1
fi

echo
printf "Successfully finished setup."
if [ "$reload_needed" = "true" ]; then
    printf " Please reload your session."
fi
printf "\n"
