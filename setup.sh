#!/bin/sh

set -e
cd "$(dirname "$0")"

# CHECK ZSH INSTALLED
if ! echo "${SHELL}" | grep -E 'zsh$' >/dev/null; then
    echo "Please install zsh and set it as your default shell."
    printf "\thttps://github.com/ohmyzsh/ohmyzsh/wiki/Installing-ZSH#install-and-set-up-zsh-as-default\n"
    return 1
fi

# CHECK OH-MY-ZSH INSTALLED
if [ ! -d ~/.oh-my-zsh ]; then
    echo "Please install oh-my-zsh."
    printf "\thttps://ohmyz.sh/#install\n"
    return 1
fi

./scripts/nix-uninstall.sh
for key in $(env | grep '^NIX_' | awk -F= '{print $1}'); do unset $key; done
./scripts/nix-install.sh
if [ -f '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh' ]; then . '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh'; fi
./scripts/create-symbolic-links.sh
./scripts/nix-packages-uninstall.sh
./scripts/nix-packages-install.sh

if ! command -v git | grep 'nix' >/dev/null 2>&1; then
    echo "The setup failed"
    exit 1
fi

echo "Successfully finished setup. Please reload your session."
