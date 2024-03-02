#!/bin/sh

set -e
cd "$(dirname "$0")"

rm -rf "$(cd ~ && pwd)/.cache/"p10k-* || true

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
