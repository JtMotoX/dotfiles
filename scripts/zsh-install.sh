#!/bin/sh

set -e
cd "$(dirname "$0")"

if command -v zsh >/dev/null 2>&1; then
	echo "zsh is already installed"
else
	echo "Installing zsh"
	if command -v apt-get >/dev/null 2>&1; then
		sudo apt-get update && apt-get install -y zsh
	elif command -v pacman >/dev/null 2>&1; then
		sudo pacman -S zsh
	elif command -v dnf >/dev/null 2>&1; then
		sudo dnf install -y zsh
	elif command -v brew >/dev/null 2>&1; then
		brew install zsh
	elif command -v port >/dev/null 2>&1; then
		sudo port install zsh zsh-completions
	elif command -v zypper >/dev/null 2>&1; then
		sudo zypper install zsh
	elif command -v yum >/dev/null 2>&1; then
		sudo yum install -y zsh
	elif comand -v apk >/dev/null 2>&1; then
		sudo apk add zsh
	else
		echo "Please install zsh with your package manager"
		exit 1
	fi
fi

# CHECK ZSH INSTALLED
if ! echo "${SHELL}" | grep -E 'zsh$' >/dev/null; then
	echo "Changing shell to zsh"
	sudo sh -c "echo $(which zsh) >> /etc/shells" && chsh -s $(which zsh)
fi
