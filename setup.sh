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
echo "Make sure we have root access . . ."
if ! sudo -v; then
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

# CREATE SOME REQUIRED DIRECTORIES
required_directories="$HOME/.cache $HOME/.local/bin"
echo "Create required directories . . ."
sudo mkdir -p ${required_directories}
sudo chown $(id -u):$(id -g) ${required_directories}

# INSTALL SOME DEPENDENCIES
install_package curl
install_package git
install_package bash

# CONFIGURE LOCALES
if [ "$(uname)" = "Linux" ]; then
    if ! locale-gen --help >/dev/null 2>&1; then
        install_package locales || install_package glibc-langpack-en || true
    fi
    if locale-gen --help >/dev/null 2>&1; then
        if ! cat /etc/locale.gen 2>/dev/null | grep -q '^en_US.UTF-8 UTF-8'; then
            sudo sed -i -E '/^#\s*en_US.UTF-8 UTF-8/s/^#\s*//' /etc/locale.gen
            sudo locale-gen
        fi
    fi
fi

# INSTALL PACKAGE REPOS
./scripts/repos-install.sh

# INSTALL BREW
. ./scripts/brew-source.sh
./scripts/brew-install.sh
. ./scripts/brew-source.sh

if [ "${HOMEBREW_PREFIX}" != "$(brew --prefix)" ]; then
    echo "ERROR: Failed to source Homebrew."
    exit 1
fi

# ALLOW SUDO TO USE BREW PACKAGES
echo "Allow sudo to use brew packages . . ."
if [ -d "${HOMEBREW_PREFIX}/bin" ] && ! sudo grep -q "${HOMEBREW_PREFIX}/bin" /etc/sudoers; then sudo sed -i.bak 's#\(Defaults\s*secure_path=".*\)"#\1:'${HOMEBREW_PREFIX}'/bin"#' /etc/sudoers; fi
if [ -d "${HOMEBREW_PREFIX}/sbin" ] && ! sudo grep -q "${HOMEBREW_PREFIX}/sbin" /etc/sudoers; then sudo sed -i.bak 's#\(Defaults\s*secure_path=".*\)"#\1:'${HOMEBREW_PREFIX}'/sbin"#' /etc/sudoers; fi

# INSTALL XCODE COMMAND LINE TOOLS NEEDED FOR BREW
if [ "$(uname)" = "Darwin" ]; then
    if ! xcode-select -p >/dev/null 2>&1; then
        xcode-select --install
    fi
fi

# RESTORE BREW PACKAGES
./scripts/brew-restore.sh

# INSTALL BOURNE SHELL
install_package dash
./scripts/bourne-sh-install.sh

install_package zsh
if ! type chsh >/dev/null 2>&1; then
    install_package util-linux-user || true 
fi
./scripts/zsh-install.sh
./scripts/oh-my-zsh-install.sh
./scripts/tmux-configure.sh
./scripts/create-symbolic-links.sh --override
./scripts/dcomp-install.sh
./scripts/kubernetes-tools.sh
./scripts/pyenv-configure.sh "3.10.3"

echo
echo "Successfully finished dotfiles setup."
echo "Launching zsh session . . ."
cd "${ORIGINAL_DIR}"
NO_ZSH_CLEAR=true zsh
