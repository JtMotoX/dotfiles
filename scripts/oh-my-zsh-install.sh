#!/bin/sh

set -e
cd "$(dirname "$0")"

rm -rf "$(cd ~ && pwd)/.cache/"p10k-* || true

# GET ZSH SITE FUNCTIONS DIRECTORY FOR COMPAUDIT FIX
if [ -d /usr/share/zsh/site-functions ]; then
	zsh_site_functions_dir="/usr/share/zsh/site-functions"
elif [ -d "" ]; then
	zsh_site_functions_dir="/usr/local/share/zsh/site-functions"
else
	echo "WARN: Unable to determine zsh site functions directory"
fi

# ATTEMPT TO FIX COMPAUDIT ERRORS IF EXISTS
if [ "${zsh_site_functions_dir}" != "" ]; then
	if ! zsh --no-rcs -c "autoload -Uz compinit && compinit && compaudit" >/dev/null 2>&1; then
		echo "Attempting to fix compaudit errors"
		sudo chmod 755 "${zsh_site_functions_dir}"
		sudo chown root:root "${zsh_site_functions_dir}"
		zsh --no-rcs -c "autoload -Uz compinit && compinit && compaudit" 2>/dev/null | while read -r p; do
			sudo chmod g-w "$p"
		done
	fi
fi

# INSTALL OR UPDATE OH-MY-ZSH
if [ -d ~/.oh-my-zsh ]; then
	echo "Updating oh-my-zsh"
	git -C ~/.oh-my-zsh pull
else
	echo "Installing oh-my-zsh"
	sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended --keep-zshrc
fi

# FUNCTION TO INSTALL OR UPDATE OH-MY-ZSH CUSTOM PLUGINS AND THEMES
install_omz_custom() {
	cd ~/.oh-my-zsh/custom/$1
	git_dir=$(basename "$2" | sed 's/\.git$//')
	if [ -d "${git_dir}" ]; then
		echo "Updating '$2'"
		git -C "${git_dir}" checkout .
		git -C "${git_dir}" pull
	else
		echo "Installing '$2'"
		git clone "$2"
	fi
}

# LIST OF OH-MY-ZSH CUSTOM PLUGINS AND THEMES
install_omz_custom plugins https://github.com/zsh-users/zsh-autosuggestions
install_omz_custom plugins https://github.com/zsh-users/zsh-completions
install_omz_custom plugins https://github.com/zsh-users/zsh-syntax-highlighting.git
install_omz_custom themes https://github.com/romkatv/powerlevel10k.git
install_omz_custom themes https://github.com/JtMotoX/zsh-jt-themes.git
