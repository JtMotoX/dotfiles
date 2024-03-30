#!/bin/sh

set -e
ORIGINAL_DIR="$(pwd)"
cd "$(dirname "$0")"

# SET SOME DEFAULTS
checkout="main"

# PARSE ARGUMENTS
while [ $# -gt 0 ]; do
    key="$1"
    case $key in
        --checkout)
            checkout="$2"
            shift
            ;;
        --help)
            echo "Usage: setup.sh [--checkout <branch or commit>] [--help]"
            exit 0
            ;;
        *)
            echo "Invalid argument: ${key}"
            exit 1
            ;;
    esac
    shift
done

# FUNCTION TO CHECK IF A COMMAND EXISTS
check_command() {
    command -v $1 >/dev/null 2>&1
}

# FUNCTION TO INSTALL A PACKAGE IF NOT EXISTS ALREADY
install_package() {
    if ! command -v $1 >/dev/null 2>&1; then
        echo "Installing $1"
        if command -v apt-get >/dev/null 2>&1; then
            install_command="sudo apt-get update && sudo apt-get install -y "$1""
        elif command -v pacman >/dev/null 2>&1; then
            install_command="sudo pacman -Syu --noconfirm "$1""
        elif command -v dnf >/dev/null 2>&1; then
            install_command="sudo dnf install -y "$1""
        elif command -v brew >/dev/null 2>&1; then
            install_command="brew install "$1""
        elif command -v port >/dev/null 2>&1; then
            install_command="sudo port install "$1""
        elif command -v zypper >/dev/null 2>&1; then
            install_command="sudo zypper install "$1""
        elif command -v yum >/dev/null 2>&1; then
            install_command="sudo yum install -y "$1""
        elif command -v apk >/dev/null 2>&1; then
            install_command="sudo apk add "$1""
        else
            echo "Please install $1 with your package manager"
            exit 1
        fi
        if [ "${install_command}" != "" ]; then
            echo "Executing: ${install_command}"
            sh -c "${install_command}"
        fi
    fi
}

# FUNCTION TO LOAD NIX ENVIRONMENT
load_nix_env() {
    if [ -f '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh' ]; then
        . '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh'
    elif [ -f ~/.nix-profile/etc/profile.d/nix.sh ]; then
        . ~/.nix-profile/etc/profile.d/nix.sh
    fi
}

# MAKE SURE WE ARE NOT ROOT
if [ "$(whoami)" = "root" ]; then
    echo "This script should not be run as root."
    exit 1
fi

if ! command -v sudo >/dev/null 2>&1; then
    echo "Please install sudo with your package manager."
    exit 1
fi

# MAKE SURE WE HAVE SUDO
if [ "$(sudo whoami)" != "root" ]; then
    echo
    echo "You do not seem to have sudo rights."
    suders_file=""
    if [ -f "/etc/sudoers" ]; then
        suders_file="/etc/sudoers"
    fi
    if [ -d "/etc/sudoers.d" ]; then
        suders_file="/etc/sudoers.d/$(whoami)"
    fi
    if [ "${suders_file}" != "" ]; then
        echo "You may need to add yourself to the sudoers file."
        printf "\tExample: sudo echo \"$(whoami) ALL=(ALL) NOPASSWD: ALL\" >>/etc/sudoers.d/$(whoami)\n"
    fi
    exit 1
fi

# DETERMINE IF THIS WAS RUN FROM ONLINE SCRIPT
if [ "$0" = "sh" ]; then
    git_url="https://github.com/JtMotoX/dotfiles"
    git_dir="$(cd ~ && pwd)/dotfiles"
    install_package git
    if [ -d "${git_dir}" ]; then
        existing_remote_url="$(git -C "${git_dir}" config --get remote.origin.url)"
        if [ "${existing_remote_url}" != "${git_url}" ] && [ "${existing_remote_url}" != "${git_url}.git" ]; then
            echo "The directory '${git_dir}' is not a clone of the dotfiles repo. Please remove it and run the script again."
            exit 1
        fi
        echo "Updating dotfiles"
        git -C "${git_dir}" pull
    else
        echo "Cloning dotfiles"
        git clone "${git_url}" "${git_dir}"
    fi
    git -C ~/dotfiles checkout ${checkout}
    echo "Execute the setup script locally"
    ~/dotfiles/setup.sh
    exit $?
fi

# UPDATE THIS REPO
if [ "${run_remote}" = "false" ]; then
    current_commit="$(git rev-parse HEAD)"
    git pull
    new_commit="$(git rev-parse HEAD)"
    if [ "$current_commit" != "$new_commit" ]; then
        echo "Some changes were made to this repo. Please run the script again."
        exit 1
    fi
fi

reload_needed="false"

# INSTALL PACKAGE REPOS
./scripts/repos-install.sh

# INSTALL NIX DEPENDENCIES
install_package xz || install_package xz-utils
install_package curl

# INSTALL NIX IF NOT EXISTS
load_nix_env
if ! nix-shell -p --run true >/dev/null 2>&1; then
    ./scripts/nix-uninstall.sh
    for key in $(env | grep '^NIX_' | awk -F= '{print $1}'); do unset $key; done
    ./scripts/nix-install.sh
    reload_needed="true"
fi
load_nix_env
# ./scripts/nix-packages-uninstall.sh
./scripts/nix-packages-install.sh

# MAKE SURE GIT WAS INSTALLED
if ! command -v git | grep 'nix' >/dev/null 2>&1; then
    echo "ERROR: It looks like packages were not installed successfully."
    exit 1
fi

if [ "$(uname)" = "Darwin" ]; then
    ./scripts/brew-install.sh
    if ! xcode-select -p >/dev/null 2>&1; then
        xcode-select --install
    fi
fi
# ./scripts/bourne-sh-install.sh
install_package zsh
./scripts/zsh-install.sh
./scripts/oh-my-zsh-install.sh
./scripts/tmux-configure.sh
./scripts/create-symbolic-links.sh --override
./scripts/pyenv-configure.sh "3.10.3"

echo
echo "Successfully finished dotfiles setup."
echo "Launching zsh session . . ."
cd "${ORIGINAL_DIR}"
NO_ZSH_CLEAR=true zsh
