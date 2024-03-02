#!/bin/sh

set -e
cd "$(dirname "$0")"

changed="false"

if [ "$(whoami)" = "root" ]; then
    echo "This script should not be run as root."
    exit 1
fi

# MAKE SURE WE HAVE SUDO
if [ "$(sudo whoami)" != "root" ]; then
    echo "You do not seem to have sudo rights."
    exit 1
fi

# FUNCTION TO REMOVE FILE OR FOLDER
remove_nix_thing() {
    if ! echo "$1" | grep 'nix' >/dev/null 2>&1; then
        echo "ERROR: Unable to remove non-nix directory '$1'"
        exit 1
    fi
    sudo sh -c "ls -d "$1" 2>/dev/null"  | while read -r i; do
        echo "Removing '$i'"
        sudo rm -rf "$i"
        changed="true"
    done
}

if [ "$(uname)" = "Darwin" ]; then
    echo "not yet supported"
	exit 1

else
    # UNINSTALL NIX SERVICE IF ALREADY EXISTS
    if [ "$(systemctl list-unit-files | grep -c nix-daemon.service)" -eq 1 ]; then
        echo "Removing nix-daemon.service"
        sudo systemctl stop nix-daemon.service
        sudo systemctl disable nix-daemon.socket nix-daemon.service
        sudo systemctl daemon-reload
        changed="true"
    fi

    # REMOVE NIX USERS IF EXISTS
    for i in $(seq 1 32); do
        if id "nixbld$i" >/dev/null 2>&1; then
            echo "Removing user 'nixbld$i'"
            sudo userdel "nixbld$i"
            changed="true"
        fi
    done
    # REMOVE NIX GROUP IF EXISTS
    if getent group nixbld >/dev/null 2>&1; then
        echo "Removing group 'nixbld'"
        sudo groupdel nixbld
        changed="true"
    fi
fi

# REMOVE NIX FILES THAT EXIST
remove_nix_thing "/etc/bash.bashrc.backup-before-nix"
remove_nix_thing "/etc/bashrc.backup-before-nix"
remove_nix_thing "/etc/zsh/zshrc.backup-before-nix"
remove_nix_thing "/etc/zshrc.backup-before-nix"
remove_nix_thing "/etc/nix"
remove_nix_thing "/etc/profile.d/nix.sh"
remove_nix_thing "/etc/tmpfiles.d/nix-daemon.conf"
remove_nix_thing "/nix"
remove_nix_thing "/root/.nix-*"
remove_nix_thing "/root/.cache/nix"
remove_nix_thing "/root/.cache/cached-nix-shell"
remove_nix_thing "/root/.local/state/nix"
remove_nix_thing "$(cd ~ && pwd)/.nix-*"
remove_nix_thing "$(cd ~ && pwd)/.cache/nix"
remove_nix_thing "$(cd ~ && pwd)/.cache/cached-nix-shell"
remove_nix_thing "$(cd ~ && pwd)/.local/state/nix"

# REMOVE ENVIRONMENT VARIABLES
for key in $(env | grep '^NIX_' | awk -F= '{print $1}'); do
    unset $key
    changed="true"
done

if [ "$changed" = "true" ]; then
    echo "Finished nix uninstall"
else
    echo "Nix not found. Nothing to uninstall."
fi
