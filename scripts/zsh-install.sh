#!/bin/sh

set -e
cd "$(dirname "$0")"

# CHECK ZSH INSTALLED
if ! echo "${SHELL}" | grep -E 'zsh$' >/dev/null; then
	echo "Changing shell to zsh"
	if ! type chsh >/dev/null 2>&1; then
		echo "ERROR: Could not find 'chsh'"
		exit 1
	fi
	if ! cat /etc/shells | grep -E "$(command -v zsh)" >/dev/null; then
		sudo sh -c "echo $(command -v zsh) >> /etc/shells"
	fi
	sudo $(command -v chsh) -s $(command -v zsh) $(whoami)
fi
