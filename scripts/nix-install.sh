#!/bin/sh

set -e
cd "$(dirname "$0")"

# TEMPORARILY REMOVE TMPFS NOEXEC IT EXISTS
if mount | grep -E '\/tmp\s.*noexec' >/dev/null 2>&1; then
    sudo mount -o remount,exec /tmp
fi

# INSTALL NIX
echo "Installing nix . . ."
if [ "$(uname)" = "Darwin" ]; then
    curl -L https://nixos.org/nix/install | sh -s -- --yes --no-modify-profile
elif [ "$(uname)" = "Linux" ]; then
    if ps --no-headers -o comm 1 2>/dev/null | grep -E '^systemd$' >/dev/null 2>&1; then
        curl -L https://nixos.org/nix/install | sh -s -- --daemon --yes --no-modify-profile
    else
        echo "WARN: systemd not found, installing nix without daemon"
        curl -L https://nixos.org/nix/install | sh -s -- --yes --no-modify-profile
    fi
else
    echo "This is not macOS or Linux"
fi

if [ ! -f ~/.nix-profile/etc/profile.d/nix.sh ] && [ ! -f '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh' ]; then
    echo "Failed to install nix"
    exit 1
fi

echo "Finished nix install"
