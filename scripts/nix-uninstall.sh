#!/bin/sh

set -e
cd "$(dirname "$0")"

changed="false"

# MAKE SURE WE ARE NOT ROOT
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
    sudo sh -c "ls -d "$1" 2>/dev/null"  | while read -r i; do
        if ! echo "$i" | grep 'nix' >/dev/null 2>&1; then
            echo "ERROR: Unable to remove non-nix directory '$i'"
            exit 1
        fi
        echo "Removing '$i'"
        sudo rm -rf "$i"
        changed="true"
    done
}

if [ "$(uname)" = "Darwin" ]; then 
    # SOURCE NIX CONFIGS
    if [ -f ~/.nix-profile/etc/profile.d/nix.sh ]; then . ~/.nix-profile/etc/profile.d/nix.sh; fi
    if [ -f '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh' ]; then . '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh'; fi

    # REMOVE NIX SERVICES IF EXISTS
    if [ -f /Library/LaunchDaemons/org.nixos.nix-daemon.plist ]; then
        echo "Removing service 'org.nixos.nix-daemon.plist'"
        sudo launchctl unload /Library/LaunchDaemons/org.nixos.nix-daemon.plist
        sudo rm /Library/LaunchDaemons/org.nixos.nix-daemon.plist
        changed="true"
    fi
    if [ -f /Library/LaunchDaemons/org.nixos.darwin-store.plist ]; then
        echo "Removing service 'org.nixos.darwin-store.plist'"
        sudo launchctl unload /Library/LaunchDaemons/org.nixos.darwin-store.plist
        sudo rm /Library/LaunchDaemons/org.nixos.darwin-store.plist
        changed="true"
    fi

    # REMOVE NIX GROUP IF EXISTS
    if dscl . list /Groups | grep -E '^nixbld$' >/dev/null 2>&1; then
        echo "Removing group 'nixbld'"
        sudo dscl . -delete /Groups/nixbld
        changed="true"
    fi

    # REMOVE NIX USERS IF EXISTS
    for u in $(sudo dscl . -list /Users | grep _nixbld); do
        echo "Removing user '$u'"
        sudo dscl . -delete /Users/$u
        changed="true"
    done

    # REMOVE NIX VOLUME MOUNT CONFIG
    if grep -E 'nix' /etc/fstab >/dev/null 2>&1; then
        echo "Removing '/nix' volume mount config"
        sudo sed -i '/\/nix/d' /etc/fstab
        changed="true"
    fi

    # REMOVE NIX VOLUME MOUNTPOINT CREATION CONFIG
    if grep -E '^nix$' /etc/synthetic.conf >/dev/null 2>&1; then
        echo "Removing 'nix' mountpoint creation config"
        sudo sed -i -E '/^nix$/d' /etc/synthetic.conf
        changed="true"
    fi

    # REMOVE NIX VOLUME
    if diskutil info -all | grep -E "^\s*Volume Name:\s*${NIX_VOLUME_LABEL:-Nix Store}$" >/dev/null 2>&1; then # this doesn't work on dual boot systems
    # if mount | grep -E ' \/nix ' >/dev/null 2>&1; then
        echo "Removing 'Nix Store' volume"
        sudo diskutil apfs deleteVolume /nix
        changed="true"
    fi

    # MAKE SURE NIX VOLUME WAS DELETED
    if diskutil info -all | grep -E "^\s*Volume Name:\s*${NIX_VOLUME_LABEL:-Nix Store}$" >/dev/null 2>&1; then # this doesn't work on dual boot systems
    # if mount | grep -E ' \/nix ' >/dev/null 2>&1; then
        echo "There was an error removing the 'Nix Store' volume"
        exit 1
    fi

else
    # UNINSTALL NIX SERVICE IF ALREADY EXISTS
    if command -v systemctl >/dev/null 2>&1; then
        if [ "$(systemctl list-unit-files | grep -c nix-daemon.service)" -eq 1 ]; then
            echo "Removing nix-daemon.service"
            sudo systemctl stop nix-daemon.service
            sudo systemctl disable nix-daemon.socket nix-daemon.service
            sudo systemctl daemon-reload
            changed="true"
        fi
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

    # REMOVE NIX STORE DIRECTORY
    remove_nix_thing "/nix"
fi

# REMOVE NIX FILES THAT EXIST
remove_nix_thing "/var/root/.nix-*"
remove_nix_thing "/etc/bash.bashrc.backup-before-nix"
remove_nix_thing "/etc/bashrc.backup-before-nix"
remove_nix_thing "/etc/zsh/zshrc.backup-before-nix"
remove_nix_thing "/etc/zshrc.backup-before-nix"
remove_nix_thing "/etc/nix"
remove_nix_thing "/etc/profile.d/nix.sh"
remove_nix_thing "/etc/tmpfiles.d/nix-daemon.conf"
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
