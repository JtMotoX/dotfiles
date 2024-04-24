#!/bin/sh

set -e
cd "$(dirname "$0")"

# TEMPORARILY REMOVE TMPFS NOEXEC IT EXISTS
if mount | grep -E '\/tmp\s.*noexec' >/dev/null 2>&1; then
    sudo mount -o remount,exec /tmp
fi

# TRY A DIFFERENT UID IF ALREADY TAKEN
if [ "${NIX_FIRST_BUILD_UID}" = "" ]; then
    if getent passwd 30001 >/dev/null 2>&1; then
        if getent passwd 300001 >/dev/null 2>&1; then
            echo "UID's 30001 and 300001 both already exists"
            exit 1
        else
            export NIX_FIRST_BUILD_UID=300001
        fi
    fi
fi
if [ "${NIX_FIRST_BUILD_UID}" != "" ]; then
    echo "Using custom NIX UID RANGE: '${NIX_FIRST_BUILD_UID}'"
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

unset NIX_FIRST_BUILD_UID

if [ ! -f ~/.nix-profile/etc/profile.d/nix.sh ] && [ ! -f '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh' ]; then
    echo "Failed to install nix"
    exit 1
fi

echo "Finished nix install"
